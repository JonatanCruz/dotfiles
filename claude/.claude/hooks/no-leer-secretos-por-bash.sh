#!/usr/bin/env bash
# PreToolUse (matcher: Bash). BLOQUEA (exit 2) leer por Bash un archivo que las
# reglas `deny` de ~/.claude/settings.json protegen de la herramienta `Read`.
#
# Las reglas `deny` gobiernan `Read`. Bash es otra puerta y no las respeta:
# sin este hook, `cat secrets/x.key` pasa mientras `Read` lo bloquea. Siete de
# las ocho reglas son de LECTURA, y los demás gates del sistema están hechos de
# verbos de ESCRITURA — ninguno las cubría.
#
# ── EL INVARIANTE: SE DECIDE POR TOKEN, NO POR COMANDO ─────────────────────
#
# Cada argumento del comando se evalúa por separado. Un token es "protegido" o
# no según SU PROPIA extensión y nombre; la presencia de otro token inocente no
# lo absuelve. Sin esto, agregar cualquier archivo `.md` al comando desarma el
# gate (`cat .env README.md`), y basta un comentario al final para lograrlo.
#
# ── LA PREGUNTA ESTÁ INVERTIDA ─────────────────────────────────────────────
#
# No se enumera "qué comandos leen" —lista ABIERTA, siempre falta uno—. Se
# pregunta si algún token nombra una ruta protegida, y sólo se exime cuando el
# comando es inequívocamente una operación que NO expone contenido (lista
# CERRADA: ls, stat, rm, test…). Lo que falte de esa lista queda BLOQUEADO,
# que es el lado seguro del error.
#
# ── LÍMITE CONOCIDO: la regla `*secret*` toca código legítimo ──────────────
#
# 25 archivos trackeados de este repo matchean (17 `.ts`, 4 `.tf`, 3 `.md`,
# 1 `.sh`): runbooks de rotación, módulos de Terraform, un `secret-loader`.
# Leerlos es trabajo normal. Por eso la extensión del TOKEN decide: un `.ts`
# llamado `reset-user-password.usecase.ts` no es un secreto. `.json` NO se
# exime: es el formato de las llaves de GCP.
#
# NO HAY OVERRIDE. Las reglas son del dueño; un agente no se auto-autoriza.
#
#   stdin: JSON { tool_input: { command } }   ·   exit 0 = permitir · 2 = bloquear
#   tests: bash ~/.claude/hooks/tests/correr.sh no-leer-secretos-por-bash

set -uo pipefail

# ── CARGA DE LA BIBLIOTECA — FALLA CERRADO (Regla #14) ─────────────────────
# Si no se puede cargar, se BLOQUEA: un gate sin su normalizador no puede
# decidir, y un control que no resuelve su contexto no debe rendirse en
# silencio.
#
# El hook y su biblioteca son UN SOLO CAMBIO: este hook corre en PreToolUse
# sobre Bash, asi que un `source` a un archivo inexistente se lleva puesta la
# herramienta con la que se arreglaria.
_lib="$(dirname "${BASH_SOURCE[0]}")/lib/normalizar-comando.sh"
if ! . "$_lib" 2>/dev/null || ! command -v normalizar_ejecutable >/dev/null 2>&1; then
  printf '\xf0\x9f\x9b\x91 BLOQUEADO (no-leer-secretos-por-bash): no se pudo cargar %s.\n' "$_lib" >&2
  printf '   Un gate sin su normalizador no puede decidir, y ante la duda no se abre.\n' >&2
  exit 2
fi

payload="$(cat 2>/dev/null || true)"
cmd="$(extraer_comando "$payload")"
[ -z "$cmd" ] && exit 0

# ── EJECUTAR != NOMBRAR ────────────────────────────────────────────────────
#
# Una palabra protegida que viaja en TEXTO no abre ningun archivo: el nombre de
# este mismo hook dentro de un patron de grep, una palabra dentro de una regex,
# un comentario al final del comando. La decision se toma sobre la parte
# EJECUTABLE, donde los strings ya son un marcador inerte y los comentarios se
# descartaron.
exec_part="$(colapsar_lineas "$(normalizar_ejecutable "$cmd")")"
[ -z "${exec_part//[[:space:]]/}" ] && exit 0

# ⚠️ PERO LA RUTA SUELE VIAJAR ENTRECOMILLADA POR SINTAXIS LEGITIMA.
# `cat "secrets/prod.key"` es la misma lectura que sin comillas, y borrar el
# string la haria desaparecer. Por eso las RUTAS se buscan sobre el comando con
# las comillas de UNA SOLA PALABRA desenvueltas (una ruta no lleva espacios), y
# los VERBOS sobre `exec_part`.
#
# La asimetria es deliberada: un falso positivo sobre un `echo "secrets/x.key"`
# es barato; un falso negativo sobre una lectura real no lo es.
#
# ⚠️ EL CUERPO DE UN HEREDOC SE DESCARTA TAMBIEN DE LA SONDA DE RUTAS. Un
# `cat > pr.md <<EOF … .env … EOF` ESCRIBE un documento que menciona la ruta;
# no abre nada. `normalizar_ejecutable` ya lo saco de `exec_part`, y la sonda
# de rutas tiene que partir del mismo texto o el gate vuelve a bloquear el
# trabajo de DOCUMENTARLO — que es como se desactiva un gate.
#
# Un heredoc dirigido a un INTERPRETE si es ejecucion, y la biblioteca lo
# respeta: en ese caso devuelve el comando entero.
cmd="$(desenvolver_palabra_sola "$(normalizar_heredoc "$cmd")")"

# Comillas fuera: `cat "secrets/x.key"` es la misma lectura.
probe="$(printf '%s' "$cmd" | tr -d "\"'")"

# Un comodín no se resuelve sin tocar disco (`.e*` ES `.env` para el shell), así
# que se normaliza al nombre protegido: el lado seguro.
probe="$(printf '%s' "$probe" | sed -E \
  's#(^|[^[:alnum:]_.-])\.e[a-z]*[*?][^[:space:]]*#\1.env#g;
    s#([^[:space:]]*)[*?]+([^[:space:]]*)\.(key|pem|p12|pfx|jks)#\1\2.\3#g;
    s#(^|[^[:alnum:]_.-])(secrets|\.ssh|\.aws)[*?]+#\1\2/#g')"

# Una ruta termina en cualquier carácter que no sea de nombre de archivo, no
# sólo en espacio: `open('.env')` la cierra con `)`.
FIN='([^[:alnum:]_.-]|$)'
PROTEGIDO="(^|[^[:alnum:]_.-])(secrets/|\.ssh/|\.aws/)|[^[:space:]]*\.(key|pem|p12|pfx|jks)${FIN}|[^[:space:]]*(credentials|password|passwd|secret)[^[:space:]/]*${FIN}|(^|[^[:alnum:]_.-])\.env${FIN}"

# Extensiones cuyo contenido es CÓDIGO o DOCUMENTACIÓN, no un secreto.
# Un `.tf` que declara `local.common_secrets` es CÓDIGO de infraestructura: lo
# que nombra es dónde vive el secreto, no su valor. Leerlo es trabajo normal y
# es la vía por la que se AUDITA que los secretos estén bien cableados.
# `.json` queda afuera a propósito: es el formato de las llaves de GCP.
# Sin `.txt` ni `.json` genéricos: un `db-password.txt` y un `credentials.json`
# SON el secreto, no código que lo menciona.
EXT_TEXTO='\.(ts|tsx|js|jsx|mjs|cjs|astro|vue|svelte|py|go|rs|java|kt|rb|php|swift|cs|scala|ex|exs|tf|tfvars|sql|prisma|md|ya?ml|toml|lock|snap|sh|bash|zsh|fish|Dockerfile|gitignore)$'

# Los archivos de CASOS de este gate nombran rutas protegidas por definición:
# son su suite de pruebas. Sin esta excepción, el gate bloquea escribir sus
# propios tests — un control que impide probarse no se puede mantener.
CASOS_DEL_GATE='/(tests?|__tests__)/[^/]*\.(txt|md)$'

# ── gcloud secrets: NOMBRAR el secreto no es LEERLO ────────────────────────
#
# `gcloud secrets` tiene dos clases de subcomando, y este gate las trataba
# igual porque la palabra `secrets` estaba en el comando:
#
#   list / versions list / describe  → devuelven NOMBRES, fechas, estados
#   versions access                  → devuelve el VALOR
#
# Inventariar secretos es trabajo de auditoría, y bloquearlo no protege nada:
# deja un punto ciego donde había una medición.
#
# La lista de lecturas es CERRADA y corta; `access` —y cualquier verbo que no
# esté— sigue bloqueando. Misma inversión de la pregunta que usa el guard de
# prod: enumerar lo que lee es finito, enumerar lo que expone no lo es.
#
# ⚠️ Se exige que `gcloud` sea el EJECUTABLE (inicio o tras separador) y se
# mira `exec_part`, para que `echo "gcloud secrets versions access ..."` no
# compre la exención por mencionarla.
# ⚠️ LA EXENCIÓN SE EVALÚA SOBRE EL SEGMENTO, NO SOBRE EL COMANDO ENTERO.
#
# Mirar el comando completo dejaba que un `gcloud secrets list` legítimo
# absolviera lo que viniera encadenado detrás:
#
#   gcloud secrets list && cat .env      ← la exención cubría el `cat .env`
#
# El invariante: una exención vale para el TRAMO que la justifica. Se parte por
# separadores (`;`, `&&`, `||`, `|`) y se exige que el tramo donde aparece el
# token protegido sea el del gcloud de metadatos. Cualquier otro tramo se
# evalúa por su cuenta.
es_gcloud_solo_metadatos() {
  local tok="$1" seg encontrado=1
  # Se recorre tramo por tramo; sólo interesa el que contiene el token.
  while IFS= read -r seg; do
    printf '%s' "$seg" | grep -qF -- "$tok" || continue
    encontrado=0
    # Ese tramo debe ser un gcloud de METADATOS, y nada más.
    printf '%s' "$seg" | grep -qE '(^|[[:space:]])gcloud([[:space:]]|$)' || return 1
    printf '%s' "$seg" | grep -qE '\baccess\b' && return 1
    printf '%s' "$seg" | grep -qE '\bsecrets\b' || return 1
    printf '%s' "$seg" \
      | sed -E 's/[[:space:]]-[^[:space:]]*//g' \
      | tr ' \t' '\n\n' \
      | grep -qxE 'list|describe|get-iam-policy|versions' || return 1
  done <<EOFSEG
$(printf '%s' "$exec_part" | sed -E 's/(\|\||&&|[|;&])/\n/g')
EOFSEG
  return $encontrado
}

# Un patrón de BÚSQUEDA no es una ruta: `logs | grep password` busca la palabra
# en una salida, no abre un archivo. Si el token protegido es el argumento de
# un buscador y no existe como ruta plausible, no hay archivo que proteger.
# ⚠️ EL PATRÓN ES POSICIONAL: en `grep [flags] PATRÓN [archivos...]` el primer
# argumento no-bandera es SIEMPRE el patrón, nunca un archivo. Esa es la prueba
# estructural, y reemplaza a la heurística de forma que había antes ("no tiene
# `/` ni `.`"), que descartaba patrones legítimos con punto:
#
#   grep -n "local.common_secrets" infra/terraform/shared/iam.tf
#
# Ahí `local.common_secrets` es el PATRÓN —el archivo es el `.tf` que viene
# después— y auditar cómo está cableado un secreto en Terraform es trabajo
# normal. La forma del token no distingue un patrón de una ruta; la POSICIÓN sí.
es_patron_de_busqueda() {
  printf '%s' "$probe" | grep -qE "(grep|egrep|fgrep|rg|ag|awk|sed)([[:space:]]+-[^[:space:]]+)*[[:space:]]+$1([[:space:]]|\$)" \
    || return 1
  # Sin `/` ni `.` no puede ser una ruta: pasa sin más análisis.
  printf '%s' "$1" | grep -qE '/|\.' || return 0
  # Con forma de ruta, sólo se exime si es el PRIMER no-bandera tras el
  # buscador — es decir, si ocupa la posición del patrón.
  local primero
  primero="$(printf '%s' "$probe" \
    | sed -E 's/.*(grep|egrep|fgrep|rg|ag|awk|sed)([[:space:]]+-[^[:space:]]+)*[[:space:]]+//' \
    | tr ' \t' '\n\n' | grep -v '^$' | head -1)"
  [ "$primero" = "$1" ]
}

# ── Se evalúa TOKEN POR TOKEN ──────────────────────────────────────────────
# Se descartan banderas y el texto tras `#` (un comentario no es un argumento).
#
# ⚠️ LA SONDA DE TOKENS SALE DE `exec_part`, NO DEL TEXTO CRUDO.
#
# Una palabra protegida que viaja en TEXTO no es un token: el nombre de este
# mismo hook dentro de un patrón de grep, una palabra dentro de una regex de
# python, un comentario al final del comando. Ninguno abre un archivo, y
# `exec_part` ya los descartó (strings → marcador inerte, comentarios fuera).
#
# Pero `exec_part` PIERDE las rutas entrecomilladas legítimas (`cat ".env"`),
# y ésas hay que seguir viéndolas. Por eso se sondean AMBAS fuentes y se unen:
#   · `exec_part`        → lo que el shell ejecuta sin comillas
#   · `probe_citado`     → las palabras que estaban entrecomilladas
# Una ruta no lleva espacios; la prosa, una regex o un mensaje sí — por eso un
# string con espacios no aporta ningún token que matchee una ruta.
probe_citado="$(printf '%s' "$probe" | sed -E 's/#.*$//')"
sonda="$(printf '%s\n%s' \
  "$(printf '%s' "$exec_part" | sed -E 's/#.*$//')" \
  "$probe_citado")"

# ── VETO DURO: `gcloud secrets … access` DEVUELVE EL VALOR ─────────────────
#
# Va ANTES del bucle de tokens, y no como una exención más, por una razón
# estructural: las exenciones absuelven TOKEN POR TOKEN, y el token `secrets`
# de `gcloud secrets versions access` no tiene forma de ruta —no lleva `/` ni
# `.`—, así que la exención de "una palabra no es una ruta" lo dejaba salir y
# el comando nunca llegaba a evaluarse.
#
# El invariante: una exención ANGOSTA no puede absolver a un comando que expone
# contenido. Lo que decide acá es el VERBO del comando, no la forma del token.
# ⚠️ BLOQUEA DIRECTO, sin pasar por la etapa INOCUOS/LECTORES de más abajo.
# Esa etapa decide mirando si el comando es un LECTOR de archivos conocido
# (`cat`, `head`, …), y `gcloud` no está en ninguna de sus dos listas: dejar que
# el veto cayera ahí lo absolvía. La etapa razona sobre RUTAS; acá el secreto no
# es un archivo del disco, es la respuesta de una API.
if printf '%s' "$exec_part" | grep -qE '(^|[|;&`]|&&|\|\||\$\()[[:space:]]*gcloud\b' \
   && printf '%s' "$exec_part" | grep -qE '\bsecrets\b' \
   && printf '%s' "$exec_part" | grep -qE '\baccess\b'; then
  cat >&2 <<'EOFG'
🛑 BLOQUEADO: `gcloud secrets … access` devuelve el VALOR del secreto.

Las reglas `deny` del dueño gobiernan la lectura de secretos, y este verbo las
esquivaba por la vía de la API en vez del disco.

NO hay override: un agente no se auto-autoriza.

QUÉ SÍ podés hacer — inventariar sin exponer:
  • gcloud secrets list
  • gcloud secrets versions list <nombre>
  • gcloud secrets describe <nombre>
Ésas devuelven NOMBRES, fechas y estados, que es lo que una auditoría necesita.
EOFG
  exit 2
fi

protegido=""
for tok in $(printf '%s' "$sonda" | tr '|;&()`' '\n' | tr ' \t' '\n\n'); do
  [ -n "$tok" ] || continue
  case "$tok" in -*|XSTRX) continue ;; esac
  printf '%s' "$tok" | grep -qE "$PROTEGIDO" || continue
  # La extensión del TOKEN decide: un .ts que se llama password no es secreto.
  printf '%s' "$tok" | grep -qE "$EXT_TEXTO" && continue
  printf '%s' "$tok" | grep -qE "$CASOS_DEL_GATE" && continue
  # Plantillas sin valores: el .gitignore las desmarca (`!.env.example`).
  printf '%s' "$tok" | grep -qE '\.env\.(example|sample|template|dev)$' && continue
  # ── UNA PALABRA NO ES UNA RUTA ──────────────────────────────────────────
  #
  # La rama `(credentials|password|secret)` de $PROTEGIDO matchea cualquier
  # token que CONTENGA la palabra, tenga o no forma de archivo. Un token sin
  # NINGUNA estructura de ruta —sin `/`, sin `.`— no puede ser un archivo que
  # el shell abra: es un argumento, un nombre de recurso remoto, un filtro.
  #
  # Casos reales que bloqueaba: el nombre de este propio hook pasado como
  # filtro a su suite de tests (`correr.sh no-leer-secretos-por-bash`), y el
  # nombre de un secreto de GCP pasado a `gcloud`.
  #
  # ⚠️ NO afloja nada con forma de archivo: `.env`, `secrets/x`, `a.key`,
  # `db-password.txt` tienen todos `/` o `.` y siguen su camino normal. Y si
  # el token es el ARGUMENTO de un lector con redirección, el archivo real
  # aparece como otro token y se evalúa por su cuenta.
  printf '%s' "$tok" | grep -qE '[/.]' || continue
  # `grep password <salida>` busca la palabra, no abre un archivo.
  es_patron_de_busqueda "$tok" && continue
  # `gcloud secrets list` / `versions list` devuelven NOMBRES, no valores.
  es_gcloud_solo_metadatos "$tok" && continue
  protegido="$tok"
  break
done
[ -z "$protegido" ] && exit 0

# ── ¿El comando sólo NOMBRA el archivo sin exponerlo? ──────────────────────
# Lista CERRADA. `cp`, `diff`, `git`, `docker` NO están: copian o muestran el
# contenido. Un verbo que falte queda bloqueado, que es el lado seguro.
# `find` y `wc` sólo nombran o cuentan; `find -exec`/`-delete` y un `wc` tras
# un pipe de lectura salen por la comprobación de LECTORES, que gana.
INOCUOS='ls|ll|stat|file|test|\[|rm|unlink|mv|touch|mkdir|chmod|chown|ln|basename|dirname|realpath|readlink|du|df|wc|find|pnpm|npm|tofu|terraform|echo|printf|export'
LECTORES='cat|head|tail|less|more|bat|nl|od|xxd|hexdump|strings|base64|openssl|grep|egrep|fgrep|rg|awk|sed|cut|sort|uniq|tr|tee|dd|cp|scp|rsync|curl|wget|diff|cmp|python[0-9.]*|perl|ruby|php|node|jq|xargs|vim|nano|emacs|git|docker|kubectl|zip|tar'
if printf '%s' "$probe" | grep -qE "(^|[|;&]|&&|\|\|)[[:space:]]*($INOCUOS)([[:space:]]|$)" \
   && ! printf '%s' "$probe" | grep -qE "(^|[|;&\`(]|&&|\|\||\\\$\()[[:space:]]*($LECTORES)\b" \
   && ! printf '%s' "$probe" | grep -qE '\-(exec|execdir|ok)\b'; then
  exit 0
fi

cat >&2 <<EOF
🛑 BLOQUEADO: leer por Bash un archivo que las reglas \`deny\` protegen.

   token: $protegido

Las reglas \`deny\` de ~/.claude/settings.json gobiernan \`Read\`. Bash es otra
puerta, y este hook cierra esa asimetría.

NO hay override: las reglas son del dueño y un agente no se auto-autoriza. Si
hace falta el contenido de un secreto, lo abre él.

QUÉ SÍ podés hacer:
  • existencia / tamaño / permisos  → ls -la, stat
  • operar sin leer                 → rm, mv, chmod
  • plantillas SIN valores          → .env.example, .env.dev
  • el CÓDIGO que menciona secretos → no se bloquea (un .ts/.tf/.sh/.md que se
    llame password o viva en secrets/ es código, no un secreto)
EOF
exit 2

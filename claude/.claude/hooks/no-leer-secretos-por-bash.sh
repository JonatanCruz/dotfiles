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

payload="$(cat 2>/dev/null || true)"
cmd=""
if command -v jq >/dev/null 2>&1; then
  cmd="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
fi
if [ -z "$cmd" ]; then
  cmd="$(printf '%s' "$payload" \
    | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(\([^"\\]\|\\.\)*\)".*/\1/p' | head -1)"
  [ -z "$cmd" ] && cmd="$payload"
fi
[ -z "$cmd" ] && exit 0

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
# `.json` queda afuera a propósito: es el formato de las llaves de GCP.
# Sin `.txt` ni `.json`: un `db-password.txt` y un `credentials.json` SON el
# secreto, no código que lo menciona.
EXT_TEXTO='\.(ts|tsx|js|jsx|mjs|cjs|astro|vue|svelte|py|go|rs|java|kt|rb|php|swift|cs|scala|ex|exs|tf|tfvars|sql|prisma|md|ya?ml|toml|lock|snap|sh|bash|zsh|fish|Dockerfile|gitignore)$'

# Un patrón de BÚSQUEDA no es una ruta: `logs | grep password` busca la palabra
# en una salida, no abre un archivo. Si el token protegido es el argumento de
# un buscador y no existe como ruta plausible, no hay archivo que proteger.
es_patron_de_busqueda() {
  printf '%s' "$probe" | grep -qE "(grep|egrep|fgrep|rg|ag|awk|sed)([[:space:]]+-[^[:space:]]+)*[[:space:]]+$1([[:space:]]|$)" \
    && ! printf '%s' "$1" | grep -qE '/|\.'
}

# ── Se evalúa TOKEN POR TOKEN ──────────────────────────────────────────────
# Se descartan banderas y el texto tras `#` (un comentario no es un argumento).
protegido=""
for tok in $(printf '%s' "$probe" | sed -E 's/#.*$//' | tr '|;&()`' '\n' | tr ' \t' '\n\n'); do
  [ -n "$tok" ] || continue
  case "$tok" in -*) continue ;; esac
  printf '%s' "$tok" | grep -qE "$PROTEGIDO" || continue
  # La extensión del TOKEN decide: un .ts que se llama password no es secreto.
  printf '%s' "$tok" | grep -qE "$EXT_TEXTO" && continue
  # Plantillas sin valores: el .gitignore las desmarca (`!.env.example`).
  printf '%s' "$tok" | grep -qE '\.env\.(example|sample|template|dev)$' && continue
  # `grep password <salida>` busca la palabra, no abre un archivo.
  es_patron_de_busqueda "$tok" && continue
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

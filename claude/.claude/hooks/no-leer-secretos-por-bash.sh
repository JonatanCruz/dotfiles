#!/usr/bin/env bash
# PreToolUse (matcher: Bash). BLOQUEA (exit 2) los comandos que nombran un
# secreto conocido de esta máquina: llaves privadas de ~/.ssh, ~/.aws/credentials,
# ~/.gnupg, secrets.zsh, .credentials.json de Claude Code y archivos .env; y los
# CLIs que devuelven el VALOR de un secreto (tabla SECRETOS_CLIS, ampliable por
# proyecto en .claude/hooks.json).
#
# ES UNA CAPA DE DEFENSA EN PROFUNDIDAD, NO LA DEFENSA. No es completa ni puede
# serlo: un filtro de texto no reimplementa el parser de bash (variables opacas,
# comodines, intérpretes que abren el archivo por su cuenta). La defensa real son
# las reglas `deny` de settings.json y los permisos 600 de los archivos.
#
# DISEÑO FAIL-CLOSED: si un fragmento protegido aparece en el comando, se
# BLOQUEA. Sólo se exime un caso estrecho: un único comando simple de una lista
# corta que no expone contenido (ls, stat, test, [, chmod, chown, touch,
# ssh-add, y ssh con la ruta SÓLO como valor de -i), sin redirecciones,
# sustituciones, pipes, `;`, `&`, backslashes ni `$'`.
#
# Lo único que se tolera como texto es un string entrecomillado de VARIAS
# palabras en un mensaje de `git commit`/`git tag` (`git commit -m "no leer
# .env"`), y sólo sin sustituciones, pipes, redirecciones ni encadenamiento. En
# cualquier otro comando el texto entrecomillado cuenta: una lista de intérpretes
# que "podrían ejecutarlo" nunca está completa (sudo, timeout, nohup, find -exec…).
# Las llaves públicas (.pub) y las plantillas (.env.example) no son secretos.
#
# Ofuscación, sin intentar decodificar nada:
#   - `$'…'` o `$"…"` en cualquier parte → bloquea siempre. `$'\x2e\x73\x73\x68'`
#     es `.ssh` sin ninguna letra en claro. Cuesta usos legítimos raros
#     (`IFS=$'\n'`, `printf $'\t'`): se reescriben con printf '%b' o comillas.
#   - `\` o comillas vacías en la MISMA palabra que un fragmento sensible (ssh,
#     aws, gnupg, env, credential, secret) → bloquea: ahí vive la ofuscación
#     (`.s\sh`, `.ss''h`). Mirar el comando entero bloqueaba `grep 'a\|b'
#     hook-de-secretos.sh`. Sigue el falso positivo `grep "process\.env"`.
#   - Expansión de llaves sin comillas (`{a,b}`, `{a..b}`) junto a una ruta
#     (`/`, `~`, `$HOME`) o un fragmento parcial (ss, sh, aws, gnupg, env, cred,
#     secret) → bloquea: `~/.s{s,}h/id_rsa` arma `.ssh` sin escribirlo. Cuesta
#     `mkdir -p src/{a,b}`, que se escribe como dos rutas.
# Son falsos positivos asumidos: el precio de no reimplementar bash.
#
# Sin jq o con JSON ilegible se evalúa el payload crudo con las mismas rutas
# (bloquea si nombra un secreto) en vez de bloquear todo Bash.
#
#   stdin: JSON { tool_input: { command } }  ·  exit 0 = permitir · 2 = bloquear

set -uo pipefail
# Sin globbing: el comando se parte en palabras y un `*` no debe tocar disco.
set -f

payload="$(cat 2>/dev/null || true)"
[ -n "${payload//[[:space:]]/}" ] || exit 0

M=$'\037'
# Bordes de una ruta: espacio, `=<>:(`, y también comillas y coma, porque dentro
# de código entrecomillado la ruta va pegada a ellas (`open('.env')`).
INI="(^|[[:space:]=<>:(,'\"])"
NR="[^[:space:]=<>:(,'\"${M}]"
# Rutas protegidas sobre texto normalizado. `~`, `$HOME` y `${HOME}` no hace
# falta resolverlos: se busca el sufijo que identifica al secreto. Ningún patrón
# cruza un \037 (el espacio de un string de varias palabras).
#   - Del home: llaves de ~/.ssh, ~/.aws/credentials, ~/.gnupg, secrets.zsh,
#     .credentials.json de Claude Code, y archivos .env.
#   - De proyecto: lo que vive en un directorio secrets/, las llaves y
#     certificados (.key .pem .p12 .pfx .jks), y los archivos cuyo NOMBRE dice
#     credentials/password/passwd/secret y llevan extensión (un `grep password`
#     busca la palabra; `db-password.txt` es el secreto).
SECRETO="${INI}${NR}*(\.ssh/id_[A-Za-z0-9_.-]*|\.aws/credentials|\.gnupg/[^[:space:]${M}]*|secrets\.zsh|\.credentials\.json)|${INI}(${NR}*/)?\.env(\.[A-Za-z0-9_-]+)*(\$|[^A-Za-z0-9_.-])|${INI}${NR}*secrets/${NR}+|${INI}${NR}*\.(key|pem|p12|pfx|jks)(\$|[^A-Za-z0-9_.-])|${INI}${NR}*(credentials|password|passwd|secret)[^[:space:]/=<>:(,'\"${M}]*\.[A-Za-z0-9]+"
# No son secretos: llaves públicas, plantillas de .env, y los casos versionados
# de los propios hooks (tests/*.txt|md nombran rutas para probarlas).
NO_SECRETO='\.pub$|\.env\.(example|sample|template|dist)$|(^|/)(tests?|__tests__)/[^/]*\.(txt|md)$'
# Un archivo de CÓDIGO no es un secreto aunque se llame password o viva en
# secrets/ (`reset-user-password.usecase.ts`, `secrets/secret-loader.service.ts`).
# Sin `.txt` ni `.json`: `db-password.txt` y `credentials.json` SON el secreto.
# Esta exención no alcanza a los secretos del home (secrets.zsh termina en .zsh).
EXT_CODIGO='\.(ts|tsx|js|jsx|mjs|cjs|astro|vue|svelte|py|go|rs|java|kt|rb|php|swift|cs|scala|ex|exs|tf|tfvars|sql|prisma|md|ya?ml|toml|lock|snap|sh|bash|zsh|fish|gitignore)$'
DEL_HOME='(\.ssh/id_|\.aws/credentials|\.gnupg/|secrets\.zsh$|\.credentials\.json$|(^|/)\.env)'
SUELTO='ssh|aws|gnupg|env|credential|secret'

# Imprime las rutas protegidas halladas que NO son públicas/plantilla/código.
# Sin `grep -q` en tuberías: con pipefail, su salida temprana puede matar por
# SIGPIPE al que escribe y la tubería daría el resultado contrario.
secretos_en() {
  local hallado ruta
  hallado="$(printf '%s' "$1" | grep -oE "$SECRETO" 2>/dev/null || true)"
  [ -n "$hallado" ] || return 0
  hallado="$(printf '%s\n' "$hallado" | sed -E "s/^[[:space:]=<>:(,'\"]//; s/[^A-Za-z0-9_.-]\$//")"
  while IFS= read -r ruta; do
    [ -n "$ruta" ] || continue
    [[ "$ruta" =~ $NO_SECRETO ]] && continue
    [[ "$ruta" =~ $EXT_CODIGO ]] && ! [[ "$ruta" =~ $DEL_HOME ]] && continue
    printf '%s\n' "$ruta"
  done <<<"$hallado"
}

# Texto FUERA de comillas (lo entrecomillado se descarta): ahí es donde bash
# expande llaves y comodines.
sin_comillas() {
  printf '%s' "$1" | awk 'BEGIN { RS = "\001" } {
    s = $0; out = ""; q = ""; n = length(s)
    for (i = 1; i <= n; i++) {
      c = substr(s, i, 1)
      if (q == "") {
        if (c == "\\" && i < n) { out = out substr(s, i + 1, 1); i++; continue }
        if (c == "\047" || c == "\"") { q = c; continue }
        out = out c
      } else if (c == q) { q = "" }
    }
    printf "%s", out
  }'
}

# Comodines sin comillas que pueden expandirse a un secreto: `cat .e*`,
# `cat .e?`, `cat secrets*/x`. No se expanden (sería tocar disco): se mira si
# lo literal ya delata el destino. `*.sh` o `src/**/*.ts` no delatan nada.
GLOB_FRAG='env|ssh|aws|gnupg|secret|cred|passw|\.pem|\.key|id_'
globs_sospechosos() {
  local palabra lit base
  for palabra in $(sin_comillas "$1" | tr '[:upper:]' '[:lower:]'); do
    case "$palabra" in *'*'* | *'?'* | *'['*) ;; *) continue ;; esac
    lit="${palabra//[*?\[\]]/}"
    base="${palabra##*/}"; base="${base%%[*?\[]*}"
    if [[ "$lit" =~ $GLOB_FRAG ]]; then
      printf '%s\n' "$palabra"
    elif [ "${#base}" -ge 2 ] && { [[ ".env" == "$base"* ]] || [[ ".ssh" == "$base"* ]] || [[ ".aws" == "$base"* ]] || [[ ".gnupg" == "$base"* ]]; }; then
      printf '%s\n' "$palabra"
    fi
  done
}

bloquear() {
  cat >&2 <<EOF
BLOQUEADO (no-leer-secretos-por-bash): $1
Los secretos no se vuelcan al contexto del modelo.

Si necesitás saber si existe o sus permisos: un único \`ls -l <ruta>\` o
\`stat <ruta>\`, sin pipes ni redirecciones. Si necesitás un valor concreto,
pedíselo al dueño; no lo leas.
EOF
  exit 2
}

PARCIAL='ss|sh|aws|gnupg|env|cred|secret'
LLAVES='\{[^{}]*(,|\.\.)[^{}]*\}'

# Devuelve 0 (y el motivo por stdout) si el comando está ofuscado.
ofuscado() {
  local texto="$1" bajo fuera
  case "$texto" in
    *"\$'"* | *"\$\""*)
      echo "el comando usa \$'…' o \$\"…\", que pueden codificar cualquier ruta."
      return 0 ;;
  esac
  bajo="$(printf '%s' "$texto" | tr '[:upper:]' '[:lower:]')"
  local palabra
  for palabra in $bajo; do
    case "$palabra" in
      *\\* | *"''"* | *'""'*)
        if [[ "$palabra" =~ $SUELTO ]]; then
          echo "el comando combina escapes o comillas vacías con un nombre sensible."
          return 0
        fi ;;
    esac
  done
  # Llaves FUERA de comillas: lo entrecomillado se descarta antes de mirar.
  fuera="$(sin_comillas "$texto")"
  # Un fragmento parcial no basta: `.s{s,}h` parte `ss` y `sh`. Por eso cuenta
  # también cualquier ruta (`/`, `~`, `$HOME`) en el comando.
  if [[ "$fuera" =~ $LLAVES ]] && { [[ "$bajo" =~ $PARCIAL ]] || [[ "$texto" == *[/~]* ]] || [[ "$texto" == *'$HOME'* ]]; }; then
    echo "expansión de llaves junto a una ruta o un fragmento de ruta sensible."
    return 0
  fi
  return 1
}

# CLIs que DEVUELVEN el valor de un secreto. Su argumento es un nombre, no una
# ruta: ninguna detección de rutas los ve. Veto directo cuando un tramo contiene
# la secuencia; los subcomandos de metadatos (list, describe, names…) pasan.
# Una entrada: ejecutable, subcomandos en orden (con lo que sea en medio) y, si
# empieza con `--`, una opción que tiene que estar. kubectl va aparte: sólo
# revela con -o/--output/--template.
# Cada proyecto puede AÑADIR entradas (secretos.clis en .claude/hooks.json),
# nunca quitarlas: la tabla de abajo siempre aplica.
SECRETOS_CLIS='gcloud secrets versions access
aws secretsmanager get-secret-value
aws secretsmanager batch-get-secret-value
aws ssm get-parameter --with-decryption
aws ssm get-parameters --with-decryption
aws ssm get-parameters-by-path --with-decryption
az keyvault secret show
az keyvault secret download
vault kv get
vault read
op read
op item get
op document get
doppler secrets get
doppler secrets download'
_cfg="$(dirname "${BASH_SOURCE[0]}")/lib/config.sh"
# shellcheck source=lib/config.sh
if [ -r "$_cfg" ] && . "$_cfg" 2>/dev/null && command -v config_secretos_clis >/dev/null 2>&1; then
  _dir_cfg="$(printf '%s' "$payload" | jq -r '.cwd // empty' 2>/dev/null || true)"
  [ -d "$_dir_cfg" ] || _dir_cfg="${CLAUDE_PROJECT_DIR:-$PWD}"
  _extra="$(config_secretos_clis "$_dir_cfg")"
  [ -z "$_extra" ] || SECRETOS_CLIS="$SECRETOS_CLIS"$'\n'"$_extra"
fi
# Se busca la secuencia como PALABRAS en cualquier posición del tramo (`aws` …
# `secretsmanager` … `get-secret-value`), no sólo al inicio tras una lista de
# envoltorios: cualquier envoltorio con argumentos (`sudo -u x`, `timeout -s
# KILL 5`, `env -u X`) la esquivaba. Un texto entrecomillado de varias palabras
# sigue siendo UNA palabra (lleva \037 en vez de espacios), así que `echo "aws
# secretsmanager get-secret-value"` no coincide; el string de un intérprete
# (`bash -c "…"`) se evalúa aparte, ya partido en palabras.
SEP=$'\036'
RE_INTERPRETE="(^|[[:space:];&|(${SEP}])(eval|(ba|z|k|da|fi)?sh|su|ssh|watch|xargs|parallel|script|python[0-9.]*|node|perl|ruby|php|deno|bun)([[:space:]]|\$)"
# es_palabra <palabra> <nombre>: `aws` o `/usr/local/bin/aws`.
es_palabra() { [ "$1" = "$2" ] || [[ "$1" == */"$2" ]]; }
# vetar_clis <texto>: bloquea si un tramo ejecuta un CLI de la tabla.
vetar_clis() {
  local tramo entrada w i n ok_kc tiene_get tiene_secret tiene_salida
  local -a palabras req
  while IFS= read -r tramo; do
    read -r -a palabras <<<"$tramo"
    n="${#palabras[@]}"
    [ "$n" -gt 0 ] || continue
    while IFS= read -r entrada; do
      [ -n "$entrada" ] || continue
      read -r -a req <<<"$entrada"
      # Subsecuencia ordenada de las palabras; las opciones `--x` pueden ir en
      # cualquier lugar después del ejecutable (también como `--x=valor`).
      local j=0 nw=0 opciones_ok=1 o
      for o in "${req[@]}"; do [[ "$o" == --* ]] || nw=$((nw+1)); done
      for ((i = 0; i < n && j < nw; i++)); do
        if { [ "$j" = 0 ] && es_palabra "${palabras[i]}" "${req[0]}"; } || { [ "$j" -gt 0 ] && [ "${palabras[i]}" = "${req[j]}" ]; }; then
          j=$((j+1))
        fi
      done
      [ "$j" = "$nw" ] || continue
      for o in "${req[@]:j}"; do
        [[ "$o" == --* ]] || { opciones_ok=0; break; }
        case " ${palabras[*]} " in *" $o "* | *" $o="*) ;; *) opciones_ok=0 ;; esac
      done
      [ "$opciones_ok" = 1 ] || continue
      bloquear "\`$entrada\` devuelve el valor de un secreto. Para metadatos usá el subcomando de listar o describir."
    done <<<"$SECRETOS_CLIS"
    # kubectl: dos condiciones independientes sobre el mismo tramo, en cualquier
    # orden: (a) kubectl + get + secret(s); (b) una salida que muestra los datos.
    ok_kc=0; tiene_get=0; tiene_secret=0; tiene_salida=0
    for w in "${palabras[@]}"; do
      es_palabra "$w" kubectl && ok_kc=1
      [ "$w" = get ] && tiene_get=1
      [[ "$w" =~ $RE_KUBE_SECRET ]] && tiene_secret=1
      [[ "$w" =~ $RE_KUBE_SALIDA ]] && tiene_salida=1
    done
    if [ "$ok_kc$tiene_get$tiene_secret$tiene_salida" = 1111 ]; then
      bloquear "\`kubectl get secret\` con -o/--output/--template devuelve los valores del secreto. Para metadatos: kubectl get secrets (sin -o) / describe secret."
    fi
  done < <(printf '%s\n' "$1" | tr ";&|()\`${SEP}" '\n\n\n\n\n\n\n')
}
RE_KUBE_SECRET='^(([a-z0-9.-]+,)*secrets?(,[a-z0-9.-]+)*)(/.*)?$'
RE_KUBE_SALIDA='^(-o.*|--output(=.*)?|--template(=.*)?|--go-template.*)$'

if ! command -v jq >/dev/null 2>&1; then
  [ -n "$(secretos_en "$payload")" ] && bloquear "nombra un secreto (jq no está instalado: se evaluó el payload crudo)."
  vetar_clis "$(printf '%s' "$payload" | tr '"' ';')"
  exit 0
fi
if ! cmd="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null)"; then
  [ -n "$(secretos_en "$payload")" ] && bloquear "nombra un secreto (JSON ilegible: se evaluó el payload crudo)."
  vetar_clis "$(printf '%s' "$payload" | tr '"' ';')"
  exit 0
fi
[ -n "$cmd" ] || exit 0

# `\` + salto de línea es una continuación: bash borra ambos y une las líneas,
# así que `~/.s\⏎sh` es `.ssh`. Se unen ANTES de cualquier otra comprobación.
# Dentro de comillas simples bash no las une; unirlas igual sólo puede añadir
# detecciones, nunca quitarlas (fail-closed). La unión sólo sirve para DETECTAR:
# las excepciones se evalúan sobre `original`, porque en `\\⏎` la barra está
# escapada y el salto es un separador real que la unión borraría.
original="$cmd"

# ── Heredoc que ESCRIBE texto: documentación, no lectura ───────────────────
# `cat > notas.md <<'EOF'` o `git commit -F - <<'EOF'` con un cuerpo que NOMBRA
# .env o ~/.ssh no abre nada: lo escribe. Se permite sólo si es eso y nada más:
# la cabecera es exactamente uno de esos dos comandos, tras el terminador no
# queda ningún comando, y el cuerpo no tiene `$(` ni backticks (con delimitador
# sin comillas bash los ejecutaría: `$(cat ~/.ssh/id_rsa)` en el cuerpo sí lee).
# Un heredoc a un intérprete (`bash <<EOF`) no entra aquí y se evalúa entero.
heredoc_que_escribe() {
  local cabecera delim resto linea visto=0 citado=0
  cabecera="${original%%$'\n'*}"
  [ "$cabecera" != "$original" ] || return 1
  local re_cat='^[[:space:]]*cat[[:space:]]*>[[:space:]]*[^[:space:]<>|;&$`]+[[:space:]]*<<-?[[:space:]]*'
  local re_git='^[[:space:]]*git[[:space:]]+(commit|tag)[[:space:]]([^<>|;&$`]*[[:space:]])?-F[[:space:]]*-[[:space:]]*<<-?[[:space:]]*'
  [[ "$cabecera" =~ ${re_cat}(.*)$ ]] || [[ "$cabecera" =~ ${re_git}(.*)$ ]] || return 1
  delim="${BASH_REMATCH[${#BASH_REMATCH[@]}-1]}"
  delim="${delim%"${delim##*[![:space:]]}"}"
  case "$delim" in
    \'*\' | \"*\") citado=1; delim="${delim:1:${#delim}-2}" ;;
  esac
  [[ "$delim" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || return 1
  resto="${original#*$'\n'}"
  local cuerpo=""
  while IFS= read -r linea; do
    if [ "$visto" = 1 ]; then
      [ -z "${linea//[[:space:]]/}" ] || return 1
      continue
    fi
    if [ "${linea#"${linea%%[!$'\t']*}"}" = "$delim" ]; then visto=1; continue; fi
    cuerpo+="$linea"$'\n'
  done <<<"$resto"
  [ "$visto" = 1 ] || return 1
  if [ "$citado" = 0 ]; then
    case "$cuerpo" in *'$('* | *'`'*) return 1 ;; esac
  fi
  return 0
}
heredoc_que_escribe && exit 0

cmd="${cmd//$'\\\n'/}"

if motivo_ofuscado="$(ofuscado "$cmd")"; then
  bloquear "$motivo_ofuscado No se intenta decodificarlo."
fi

# Normalización básica como la de bash: fuera de comillas, `\x` → `x`; las
# comillas se quitan y su contenido se conserva, con sus espacios y separadores
# marcados (\037/\036) para que un texto de varias palabras no forme tokens
# sueltos ni corte el comando.
normal="$(printf '%s' "$cmd" | awk 'BEGIN { RS = "\001" } {
  s = $0; out = ""; q = ""; n = length(s)
  for (i = 1; i <= n; i++) {
    c = substr(s, i, 1)
    if (q == "") {
      if (c == "\\" && i < n) { out = out substr(s, i + 1, 1); i++; continue }
      if (c == "\047" || c == "\"") { q = c; continue }
      out = out c
    } else if (c == q) {
      q = ""
    } else {
      if (q == "\"" && c == "\\" && i < n) { i++; c = substr(s, i, 1) }
      if (c == " " || c == "\t" || c == "\n") c = "\037"
      else if (c == ";" || c == "&" || c == "|") c = "\036"
      out = out c
    }
  }
  printf "%s", out
}')"

# El texto entrecomillado cuenta como tokens (sus espacios son bordes), salvo
# en el mensaje de un git commit/tag simple: ahí es prosa y no se ejecuta.
SIMPLE_RE='[`;&|<>]|\$\('
# Los CLIs de secretos se miran con el texto citado todavía en UNA palabra.
normal_citado="$normal"
if ! { [[ "$original" =~ ^[[:space:]]*git[[:space:]]+(commit|tag)([[:space:]]|$) ]] \
       && ! [[ "$original" =~ $SIMPLE_RE ]] && [[ "$original" != *$'\n'* ]] \
       && [[ "$original" != *\\* ]]; }; then
  normal="$(printf '%s' "$normal" | tr '\037\036' ' ;')"
fi

vetar_clis "$normal_citado"
if [[ "$normal_citado" =~ $RE_INTERPRETE ]]; then
  vetar_clis "$(printf '%s' "$normal_citado" | tr '\037\036' ' ;')"
fi

hallados="$(secretos_en "$normal"; globs_sospechosos "$cmd")"
[ -n "${hallados//[[:space:]]/}" ] || exit 0

# ── Única exención: un comando simple de la lista corta ────────────────────
motivo="nombra $(printf '%s\n' "$hallados" | head -1)."
case "$original" in
  *'<'* | *'>'* | *'|'* | *';'* | *'&'* | *'$('* | *'`'* | *\\* | *"\$'"* | *$'\n'*)
    bloquear "$motivo Con redirecciones, pipes, sustituciones o varios comandos no hay exención." ;;
esac

read -r -a palabras <<<"$normal"
ejecutable="${palabras[0]:-}"
case "${ejecutable##*/}" in
  # wc cuenta líneas/bytes: dice el tamaño, no el contenido. rm borra sin leer.
  ls | stat | test | '[' | chmod | chown | touch | ssh-add | wc | rm) exit 0 ;;
  find)
    # find sólo nombra rutas; con estas acciones ejecuta, borra o escribe.
    case " ${palabras[*]} " in
      *' -exec'* | *' -ok'* | *' -delete '* | *' -fprint'* | *' -fls '*)
        bloquear "$motivo find con -exec/-ok/-delete/-fprint no tiene exención." ;;
    esac
    exit 0 ;;
  ssh)
    # Cada ruta protegida tiene que ser exactamente el valor de un `-i`, y sin
    # -o/-F: ProxyCommand y LocalCommand ejecutan comandos locales.
    for ((k = 1; k < ${#palabras[@]}; k++)); do
      case "${palabras[k]}" in
        -o* | -F*) bloquear "$motivo En ssh con la llave no se admiten -o ni -F." ;;
      esac
      if [ -n "$(secretos_en "${palabras[k]}")" ] && [ "${palabras[k - 1]}" != "-i" ]; then
        bloquear "$motivo En ssh sólo se admite la llave como valor de -i."
      fi
    done
    exit 0 ;;
esac

bloquear "$motivo"

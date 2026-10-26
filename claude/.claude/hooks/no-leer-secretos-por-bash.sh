#!/usr/bin/env bash
# PreToolUse (matcher: Bash). BLOQUEA (exit 2) los comandos que nombran un
# secreto conocido de esta máquina: llaves privadas de ~/.ssh, ~/.aws/credentials,
# ~/.gnupg, secrets.zsh, .credentials.json de Claude Code y archivos .env.
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
INI="(^|[[:space:]=<>:(])"
# Rutas protegidas sobre texto normalizado. `~`, `$HOME` y `${HOME}` no hace
# falta resolverlos: se busca el sufijo que identifica al secreto. Ningún patrón
# cruza un \037 (el espacio de un string de varias palabras).
SECRETO="${INI}[^[:space:]=<>:(${M}]*(\.ssh/id_[A-Za-z0-9_.-]*|\.aws/credentials|\.gnupg/[^[:space:]${M}]*|secrets\.zsh|\.credentials\.json)|${INI}([^[:space:]=<>:(${M}]*/)?\.env(\.[A-Za-z0-9_-]+)*(\$|[^A-Za-z0-9_.-])"
NO_SECRETO='\.pub$|\.env\.(example|sample|template|dist)$'
SUELTO='ssh|aws|gnupg|env|credential|secret'

# Imprime las rutas protegidas halladas que NO son públicas/plantilla.
# Sin `grep -q` en tuberías: con pipefail, su salida temprana puede matar por
# SIGPIPE al que escribe y la tubería daría el resultado contrario.
secretos_en() {
  local hallado
  hallado="$(printf '%s' "$1" | grep -oE "$SECRETO" 2>/dev/null || true)"
  [ -n "$hallado" ] || return 0
  hallado="$(printf '%s\n' "$hallado" | sed -E 's/^[[:space:]=<>:(]//; s/[^A-Za-z0-9_.-]$//')"
  printf '%s\n' "$hallado" | grep -vE "$NO_SECRETO" 2>/dev/null || true
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
  fuera="$(printf '%s' "$texto" | awk 'BEGIN { RS = "\001" } {
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
  }')"
  # Un fragmento parcial no basta: `.s{s,}h` parte `ss` y `sh`. Por eso cuenta
  # también cualquier ruta (`/`, `~`, `$HOME`) en el comando.
  if [[ "$fuera" =~ $LLAVES ]] && { [[ "$bajo" =~ $PARCIAL ]] || [[ "$texto" == *[/~]* ]] || [[ "$texto" == *'$HOME'* ]]; }; then
    echo "expansión de llaves junto a una ruta o un fragmento de ruta sensible."
    return 0
  fi
  return 1
}

if ! command -v jq >/dev/null 2>&1; then
  [ -n "$(secretos_en "$payload")" ] && bloquear "nombra un secreto (jq no está instalado: se evaluó el payload crudo)."
  exit 0
fi
if ! cmd="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null)"; then
  [ -n "$(secretos_en "$payload")" ] && bloquear "nombra un secreto (JSON ilegible: se evaluó el payload crudo)."
  exit 0
fi
[ -n "$cmd" ] || exit 0

# `\` + salto de línea es una continuación: bash borra ambos y une las líneas,
# así que `~/.s\⏎sh` es `.ssh`. Se unen ANTES de cualquier otra comprobación.
# Dentro de comillas simples bash no las une; unirlas igual sólo puede añadir
# detecciones, nunca quitarlas (fail-closed).
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
if ! { [[ "$cmd" =~ ^[[:space:]]*git[[:space:]]+(commit|tag)([[:space:]]|$) ]] \
       && ! [[ "$cmd" =~ $SIMPLE_RE ]] && [[ "$cmd" != *$'\n'* ]]; }; then
  normal="$(printf '%s' "$normal" | tr '\037\036' ' ;')"
fi

hallados="$(secretos_en "$normal")"
[ -n "$hallados" ] || exit 0

# ── Única exención: un comando simple de la lista corta ────────────────────
motivo="nombra $(printf '%s\n' "$hallados" | head -1)."
case "$cmd" in
  *'<'* | *'>'* | *'|'* | *';'* | *'&'* | *'$('* | *'`'* | *\\* | *"\$'"* | *$'\n'*)
    bloquear "$motivo Con redirecciones, pipes, sustituciones o varios comandos no hay exención." ;;
esac

read -r -a palabras <<<"$normal"
ejecutable="${palabras[0]:-}"
case "${ejecutable##*/}" in
  ls | stat | test | '[' | chmod | chown | touch | ssh-add) exit 0 ;;
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

#!/usr/bin/env bash
# PreToolUse (matcher: Bash). BLOQUEA (exit 2) los comandos que LEEN un secreto
# conocido de esta máquina: llaves privadas de ~/.ssh, ~/.aws/credentials,
# secrets.zsh, .credentials.json de Claude Code y archivos .env.
#
# POR QUÉ: las reglas `deny` de settings.json cubren la herramienta Read y los
# comandos de archivo que Claude Code reconoce en Bash (cat, head, sed…), pero no
# un subproceso cualquiera (`base64`, `python3 -c`, `cp` a otro sitio). Este hook
# cierra parte de ese hueco. NO es la defensa principal: un filtro por regex nunca
# es completo (`bash -c '…'`, variables opacas, comodines, intérpretes que abren
# el archivo por su cuenta). La defensa real son el deny y los permisos 600.
#
# DISEÑO (lección de una versión anterior que bloqueó 157 comandos legítimos en una
# sesión por evaluar el TEXTO en vez de lo que se ejecuta):
#   - Un string entre comillas de VARIAS palabras es texto (`git commit -m "no leer
#     .env"`), no una ruta: no cuenta. Uno de UNA sola palabra sí cuenta, porque
#     `cat "$HOME/.ssh/id_rsa"` es la misma lectura que sin comillas.
#   - Se decide por TRAMO (separado por ; && || | y saltos de línea), y algunos
#     ejecutables que no exponen contenido quedan exentos en su tramo: ls, stat,
#     test, chmod, rm, echo, ssh… salvo que el tramo tenga $( ) o backticks.
#   - Las llaves públicas (.pub) y las plantillas (.env.example) no son secretos.
#
# FALLA CERRADO SÓLO DONDE IMPORTA: sin jq o con JSON ilegible no se puede aislar
# el comando, así que se busca sobre el payload crudo y se bloquea si nombra un
# secreto. Bloquear TODO Bash por falta de jq dejaría sin la herramienta con la
# que se arregla.
#
#   stdin: JSON { tool_input: { command } }  ·  exit 0 = permitir · 2 = bloquear

set -uo pipefail
# Sin globbing: los tramos se parten en palabras y un `*` no debe tocar disco.
set -f

payload="$(cat 2>/dev/null || true)"
[ -n "${payload//[[:space:]]/}" ] || exit 0

# Rutas protegidas, sobre texto ya normalizado. `~`, `$HOME` y `${HOME}` no hace
# falta resolverlos: se busca el sufijo, que es lo que identifica al secreto.
# Cada patrón exige empezar en un borde de token y no cruzar un \037 (el espacio
# de un string entrecomillado de varias palabras: eso es texto, no una ruta).
M=$'\037'
INI="(^|[[:space:]=<>:(])"
SECRETO="${INI}[^[:space:]=<>:(${M}]*(\.ssh/id_[A-Za-z0-9_.-]*|\.aws/credentials|secrets\.zsh|\.credentials\.json)|${INI}([^[:space:]=<>:(${M}]*/)?\.env(\.[A-Za-z0-9_-]+)*(\$|[^A-Za-z0-9_.-])"
NO_SECRETO='\.pub$|\.env\.(example|sample|template|dist)$'

nombra_secreto() {
  local hallado
  hallado="$(printf '%s' "$1" | grep -oE "$SECRETO" 2>/dev/null || true)"
  [ -n "$hallado" ] || return 1
  # Basta con UNA coincidencia que no sea pública/plantilla. Sin `grep -q`: con
  # pipefail, su salida temprana puede matar por SIGPIPE al que escribe y la
  # tubería daría "no es secreto" por accidente.
  hallado="$(printf '%s\n' "$hallado" | sed -E 's/[^A-Za-z0-9_.-]$//')"
  printf '%s\n' "$hallado" | grep -vE "$NO_SECRETO" >/dev/null
}

bloquear() {
  cat >&2 <<EOF
BLOQUEADO (no-leer-secretos-por-bash): el comando lee un archivo secreto
($1). Los secretos no se vuelcan al contexto del modelo.

Si necesitás saber si existe o sus permisos: ls -l / stat.
Si necesitás un valor concreto, pedíselo al dueño; no lo leas.
EOF
  exit 2
}

if ! command -v jq >/dev/null 2>&1; then
  nombra_secreto "$payload" && bloquear "jq no está instalado: se evaluó el payload crudo"
  exit 0
fi

if ! cmd="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null)"; then
  nombra_secreto "$payload" && bloquear "JSON ilegible: se evaluó el payload crudo"
  exit 0
fi
[ -n "$cmd" ] || exit 0

# Comillas: el contenido se conserva, pero los espacios y separadores de dentro se
# vuelven marcadores (\037 y \036). Así un string de varias palabras no forma
# tokens sueltos ni corta tramos, y uno de una sola palabra queda como ruta.
normal="$(printf '%s' "$cmd" | awk 'BEGIN { RS = "\001" } {
  s = $0; out = ""; q = ""; n = length(s)
  for (i = 1; i <= n; i++) {
    c = substr(s, i, 1)
    if (q == "") {
      if (c == "\\" && i < n) { out = out c substr(s, i + 1, 1); i++; continue }
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

EXENTOS='^(ls|stat|test|\[|file|chmod|chown|touch|rm|echo|printf|ssh|ssh-add)$'

while IFS= read -r tramo; do
  [ -n "${tramo//[[:space:]]/}" ] || continue
  nombra_secreto "$tramo" || continue
  # Primer ejecutable del tramo, saltando asignaciones VAR=valor.
  ejecutable=""
  for palabra in $tramo; do
    case "$palabra" in
      *=*) [ -z "$ejecutable" ] && continue ;;
    esac
    ejecutable="$palabra"
    break
  done
  case "$tramo" in
    *'$('* | *'`'*) ;;
    *) [[ "${ejecutable##*/}" =~ $EXENTOS ]] && continue ;;
  esac
  bloquear "$(printf '%s' "$tramo" | tr '\037\036' ' ;' | cut -c1-120)"
done < <(printf '%s\n' "$normal" | tr ';&|' '\n\n\n')

exit 0

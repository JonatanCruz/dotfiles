#!/usr/bin/env bash
# Tres eventos, un solo script, para que una indicación del dueño no se pierda:
#
#   UserPromptSubmit → si el mensaje trae lenguaje de indicación ("ya no", "nunca",
#                      "siempre", "de ahora en adelante", "te dije"…), deja un marcador
#                      para la sesión y avisa al modelo que la escriba en un CLAUDE.md.
#   PostToolUse      → (matcher Edit|Write|MultiEdit) borra el marcador SÓLO si lo
#                      editado es un CLAUDE.md. Guardar en Engram no lo borra.
#   Stop             → si el marcador sigue, BLOQUEA terminar el turno una vez
#                      (stop_hook_active evita el bucle).
#
# Por qué existe (2026-10-14): el dueño dio la indicación de no crear worktrees fuera
# del repo, no se guardó y se volvió a violar. Sus palabras: "ese es el detalle, que no
# lo guardas cuando fue una indicación mía". Un aviso solo no basta: el Stop impide
# cerrar el turno sin guardarla.
#
# Por qué el destino es CLAUDE.md y no Engram (2026-10-23): Engram sólo vuelve al
# contexto si engram-autorecall.sh acierta por coincidencia de palabras, y una regla
# tiene que estar presente cuando toca, no cuando el prompt la nombra. CLAUDE.md se
# carga en cada sesión. El dueño: "engram no sirve para estas reglas, porque no lo
# lees en cada prompt cuando toca". Engram queda para contexto y decisiones.
#
# Uso: indicacion-del-duenio.sh prompt|guardado|stop   (stdin: JSON del evento)

set -uo pipefail

modo="${1:-}"
payload="$(cat)"
command -v jq >/dev/null 2>&1 || exit 0

sesion="$(printf '%s' "$payload" | jq -r '.session_id // "sin-sesion"')"
dir="$HOME/.claude/state"
marcador="$dir/indicacion-pendiente-$sesion"

case "$modo" in
  prompt)
    texto="$(printf '%s' "$payload" | jq -r '.prompt // ""')"
    # Los avisos del sistema (resultados de agentes en segundo plano) llegan por el
    # mismo evento que un mensaje del dueño, pero no son indicaciones suyas.
    case "$texto" in
      *"<task-notification>"*|*"SYSTEM NOTIFICATION"*) exit 0 ;;
    esac
    patron='(\bya no\b|\bnunca\b|\bsiempre\b|de ahora en adelante|a partir de ahora|\bno vuelvas\b|\bdeja de\b|\bte dije\b|te di la indicaci|\bla regla es\b|\bque no se\b|\bno quiero que\b|\bprohibido\b|\bno se debe\b|\bno debes\b|lo m[aá]s importante|\bprioridad\b)'
    if printf '%s' "$texto" | grep -Eiq "$patron"; then
      mkdir -p "$dir"
      printf '%s\n' "$(printf '%s' "$texto" | head -c 400)" > "$marcador"
      jq -n '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:"INDICACIÓN DEL DUEÑO DETECTADA: si este mensaje fija una regla, prioridad o prohibición que debe gobernar lo que hagas después, escribila en un CLAUDE.md ANTES de terminar el turno: el del proyecto (en rama docs/ + PR) si es del proyecto, ~/.claude/CLAUDE.md si es global. Como invariante, con sus palabras textuales. Engram NO sirve para reglas: sólo vuelve si el prompt repite las mismas palabras. Si ya está en un CLAUDE.md, corregí ese texto en su lugar. Si el mensaje no era una indicación, decilo explícitamente."}}'
    fi
    ;;
  guardado)
    archivo="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // ""')"
    case "$archivo" in
      */CLAUDE.md) rm -f "$marcador" ;;
    esac
    ;;
  stop)
    activo="$(printf '%s' "$payload" | jq -r '.stop_hook_active // false')"
    if [ -f "$marcador" ] && [ "$activo" != "true" ]; then
      extracto="$(head -c 200 "$marcador")"
      jq -n --arg e "$extracto" '{decision:"block",reason:("El dueño dio una indicación en este turno y no quedó escrita en ningún CLAUDE.md. Si es una regla, escribila ahora (proyecto: rama docs/ + PR; global: ~/.claude/CLAUDE.md) y recién después terminá; si no era una regla, decilo explícitamente. Extracto: " + $e)}'
    fi
    ;;
esac
exit 0

#!/usr/bin/env bash
# Tres eventos, un solo script, para que una indicación del dueño no se pierda:
#
#   UserPromptSubmit → si el mensaje trae lenguaje de indicación ("ya no", "nunca",
#                      "siempre", "de ahora en adelante", "te dije"…), deja un marcador
#                      para la sesión y avisa al modelo que debe guardarla en Engram.
#   PostToolUse      → (matcher mem_save / mem_update) borra el marcador.
#   Stop             → si el marcador sigue, BLOQUEA terminar el turno una vez
#                      (stop_hook_active evita el bucle).
#
# Por qué existe (2026-10-14): el dueño dio la indicación de no crear worktrees fuera
# del repo, no se guardó en Engram y se volvió a violar. Sus palabras: "ese es el
# detalle, que no lo guardas cuando fue una indicación mía". Un aviso solo no basta:
# el Stop impide cerrar el turno sin guardarla.
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
    patron='(\bya no\b|\bnunca\b|\bsiempre\b|de ahora en adelante|a partir de ahora|\bno vuelvas\b|\bdeja de\b|\bte dije\b|te di la indicaci|\bla regla es\b|\bque no se\b|\bno quiero que\b|\bprohibido\b|\bno se debe\b|\bno debes\b)'
    if printf '%s' "$texto" | grep -Eiq "$patron"; then
      mkdir -p "$dir"
      printf '%s\n' "$(printf '%s' "$texto" | head -c 400)" > "$marcador"
      jq -n '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:"INDICACIÓN DEL DUEÑO DETECTADA: si este mensaje fija una regla, preferencia o prohibición, guardala en Engram (mem_save, type preference/decision, con sus palabras textuales y el cómo aplicarla) ANTES de terminar el turno. Si ya existe, actualizala con mem_update. Si el mensaje no era una indicación, decilo explícitamente y guardá igual una nota mínima."}}'
    fi
    ;;
  guardado)
    rm -f "$marcador"
    ;;
  stop)
    activo="$(printf '%s' "$payload" | jq -r '.stop_hook_active // false')"
    if [ -f "$marcador" ] && [ "$activo" != "true" ]; then
      extracto="$(head -c 200 "$marcador")"
      jq -n --arg e "$extracto" '{decision:"block",reason:("El dueño dio una indicación en este turno y no se guardó en Engram. Guardala ahora con mem_save (sus palabras textuales + cómo aplicarla) y recién después terminá. Extracto: " + $e)}'
    fi
    ;;
esac
exit 0

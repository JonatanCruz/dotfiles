#!/usr/bin/env bash
# UserPromptSubmit. Cuando el dueño expresa una regla de forma explícita ("la regla es",
# "de ahora en adelante", "no quiero que"…), recuerda clasificarla con la tabla de
# ~/.claude/CLAUDE.md (hook, CLAUDE.md, skill, ADR o Engram). No bloquea el turno ni
# obliga a escribir: lo que no admite excepciones va en un hook, no en prosa, y un
# CLAUDE.md sólo crece cuando la misma corrección se repite.
#
# Uso: indicacion-del-duenio.sh prompt   (stdin: JSON del evento)

set -uo pipefail

modo="${1:-}"
payload="$(cat)"
command -v jq >/dev/null 2>&1 || exit 0
[ "$modo" = prompt ] || exit 0

texto="$(printf '%s' "$payload" | jq -r '.prompt // ""')"
# Los avisos del sistema llegan por el mismo evento, pero no son indicaciones del dueño.
case "$texto" in
  *"<task-notification>"* | *"SYSTEM NOTIFICATION"*) exit 0 ;;
esac

# Sólo frases que fijan una regla. "siempre", "nunca" o "prioridad" solos son lenguaje
# cotidiano y disparaban en mensajes que no lo eran.
patron='(de ahora en adelante|a partir de ahora|\bla regla es\b|\bno quiero que\b|\bno vuelvas a\b|\bque nunca\b|\bque siempre\b|\bprohibido\b)'
if printf '%s' "$texto" | grep -Eiq "$patron"; then
  jq -n '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:"Indicación del dueño con forma de regla: clasifícala con la tabla de ~/.claude/CLAUDE.md antes de guardarla. No se copia textual."}}'
fi
exit 0

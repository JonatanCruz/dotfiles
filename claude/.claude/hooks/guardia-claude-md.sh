#!/usr/bin/env bash
# PreToolUse (matcher: Write|Edit|MultiEdit). BLOQUEA (exit 2) que un CLAUDE.md o AGENTS.md
# se llene de lo que la guía de Anthropic dice que no va ahí: fechas, citas del dueño,
# secciones vacías (MUDADA, DEROGADA, SIN OBJETO, VACANTE) o más de 200 líneas.
# La historia va a git y a los ADR; lo que no admite excepciones, a un hook.
#
#   stdin: JSON { tool_input: { file_path, content | new_string | edits } } · 0 = permitir · 2 = bloquear

set -uo pipefail

payload="$(cat 2>/dev/null || true)"
command -v jq >/dev/null 2>&1 || exit 0

archivo="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // ""')"
case "$archivo" in
  */CLAUDE.md | */AGENTS.md) ;;
  *) exit 0 ;;
esac

nuevo="$(printf '%s' "$payload" | jq -r '[.tool_input.content, .tool_input.new_string, (.tool_input.edits // [] | map(.new_string) | .[])] | map(select(. != null)) | join("\n")')"

bloquear() {
  echo "BLOQUEADO (guardia-claude-md): $1 La historia va a git o a un ADR; una regla sin excepciones, a un hook." >&2
  exit 2
}

printf '%s' "$nuevo" | grep -qE '\b20[0-9]{2}-[01][0-9]-[0-3][0-9]\b' && bloquear "trae una fecha."
printf '%s' "$nuevo" | grep -qiE 'el dueño:|el dueño \(20' && bloquear "trae una cita del dueño."
printf '%s' "$nuevo" | grep -qE '\b(MUDADA|DEROGADA|SIN OBJETO|VACANTE)\b' && bloquear "trae una sección vacía."

# Tamaño resultante: con Write es el contenido; con Edit, el archivo actual más lo que cambia.
herramienta="$(printf '%s' "$payload" | jq -r '.tool_name // ""')"
if [ "$herramienta" = Write ]; then
  lineas="$(printf '%s\n' "$nuevo" | wc -l)"
elif [ -f "$archivo" ]; then
  viejo="$(printf '%s' "$payload" | jq -r '[.tool_input.old_string, (.tool_input.edits // [] | map(.old_string) | .[])] | map(select(. != null)) | join("\n")')"
  actuales="$(wc -l <"$archivo")"
  lineas=$((actuales - $(printf '%s' "$viejo" | grep -c '') + $(printf '%s' "$nuevo" | grep -c '')))
else
  lineas=0
fi
[ "$lineas" -le 200 ] || bloquear "quedaría con $lineas líneas (máximo 200)."
exit 0

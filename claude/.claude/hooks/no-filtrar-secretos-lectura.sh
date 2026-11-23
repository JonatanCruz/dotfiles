#!/usr/bin/env bash
# PreToolUse (matcher: Read|Grep|NotebookRead). BLOQUEA (exit 2) que una herramienta
# de lectura vuelque el CONTENIDO de un secreto: archivos .env, llaves de ~/.ssh,
# ~/.aws/credentials, ~/.gnupg, secrets.zsh y .credentials.json.
#
# Es la contraparte de no-filtrar-secretos.sh (Bash). Reemplaza a la regla
# `deny: Read(//**/.env*)`, que también bloqueaba USAR la credencial desde Bash
# (`set -a; . ./.env.x`) y hasta un `ls -l`. Aquí se vigila el valor, no el uso.
# Las plantillas (.env.example/.sample/.template/.dist) y las llaves públicas no
# son secretos.
#
#   stdin: JSON { tool_input: { file_path | path | notebook_path } } · 0 = permitir · 2 = bloquear

set -uo pipefail

payload="$(cat 2>/dev/null || true)"
[ -n "${payload//[[:space:]]/}" ] || exit 0

if command -v jq >/dev/null 2>&1; then
  rutas="$(printf '%s' "$payload" | jq -r '.tool_input | [.file_path, .path, .notebook_path, .glob] | map(select(. != null)) | .[]' 2>/dev/null || true)"
else
  # Sin jq se evalúa el payload crudo: falla cerrado si nombra un secreto.
  rutas="$payload"
fi

SECRETO='(^|/)\.env(\.[A-Za-z0-9_-]+)*$|\.ssh/id_[^/]*$|\.aws/credentials$|\.gnupg/|secrets\.zsh$|\.credentials\.json$'
NO_SECRETO='\.pub$|\.env\.(example|sample|template|dist)$'

while IFS= read -r ruta; do
  [ -n "$ruta" ] || continue
  [[ "$ruta" =~ $NO_SECRETO ]] && continue
  if [[ "$ruta" =~ $SECRETO ]]; then
    cat >&2 <<EOF
BLOQUEADO (no-filtrar-secretos-lectura): $ruta contiene secretos.
Su valor no se vuelca al contexto. Para USAR una credencial de un .env, cárgalo en
el shell y pásalo como opción de conexión (ver no-filtrar-secretos.sh).
EOF
    exit 2
  fi
done <<<"$rutas"
exit 0

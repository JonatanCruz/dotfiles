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

SECRETO='(^|/)\.env[^/]*$|(^|/)\.ssh(/|$)|\.aws/credentials$|(^|/)\.gnupg(/|$)|secrets\.zsh$|\.credentials\.json$'
NO_SECRETO='\.pub$|\.env\.(example|sample|template|dist)$'

if ! command -v jq >/dev/null 2>&1; then
  # Sin jq no se puede saber qué ruta se lee: falla cerrado si el payload nombra
  # algo parecido a un secreto, sin anclar al final de la cadena.
  if printf '%s' "$payload" | grep -qE '\.env|\.ssh|\.aws/credentials|\.gnupg|secrets\.zsh|\.credentials\.json'; then
    echo "BLOQUEADO (no-filtrar-secretos-lectura): sin jq y el payload nombra un secreto." >&2
    exit 2
  fi
  exit 0
fi

rutas="$(printf '%s' "$payload" | jq -r '.tool_input | [.file_path, .path, .notebook_path] | map(select(. != null)) | .[]' 2>/dev/null || true)"

# Grep busca dentro de un directorio: un `glob` que alcance un secreto lo leería
# aunque la ruta sea inocente. Se bloquea si el glob nombra uno o es tan abierto
# que incluye archivos ocultos.
glob="$(printf '%s' "$payload" | jq -r '.tool_input.glob // empty' 2>/dev/null || true)"
# No se adivina si un glob es seguro mirando su texto: se expande igual que lo haría
# la búsqueda (incluidos ocultos e ignorados) y cada archivo resultante pasa por la
# misma comprobación de ruta.
if [ -n "$glob" ]; then
  raiz="$(printf '%s' "$payload" | jq -r '.tool_input.path // "."' 2>/dev/null || echo .)"
  if ! command -v rg >/dev/null 2>&1; then
    echo "BLOQUEADO (no-filtrar-secretos-lectura): sin rg no se puede expandir el glob \`$glob\`." >&2
    exit 2
  fi
  rutas="$rutas"$'\n'"$(rg --files --hidden --no-ignore -g "$glob" -- "$raiz" 2>/dev/null | head -20000)"
fi

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

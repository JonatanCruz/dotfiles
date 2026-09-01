#!/usr/bin/env bash
# ==============================================================================
# apply.sh - Genera los configs con colores desde la paleta única
# ==============================================================================
# Lee theme/palette.sh, expande los tokens {{ TOKEN }} de theme/templates/*.tpl
# y escribe cada resultado en su destino.
#
# Uso:
#   theme/apply.sh          # genera
#   theme/apply.sh --check  # falla si algo está desincronizado (para CI)
#
# Tokens soportados en las plantillas:
#   {{ ACCENT }}         -> #89b4fa   (cualquier variable de palette.sh)
#   {{ ACCENT|strip }}   -> 89b4fa    (sin almohadilla)
#   {{ ACCENT|rgb }}     -> 137,180,250
#   {{ BASE|mix CRUST 25% }} -> mezcla BASE con CRUST al 25%

set -euo pipefail

THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$THEME_DIR")"

source "$THEME_DIR/palette.sh"
source "$THEME_DIR/mix.sh"

CHECK_ONLY=0
[[ "${1:-}" == "--check" ]] && CHECK_ONLY=1

# plantilla -> destino (relativo al root del repo)
declare -a TARGETS=(
  "gitconfig-colors.tpl:git/.gitconfig-colors"
  "tmux-colors.tpl:tmux/.tmux-colors.conf"
  "claude-theme.tpl:claude/.claude/themes/catppuccin-mocha.json"
)

# Resuelve un token a su valor final.
resolve_token() {
  local token="$1" name filter rest

  # {{ NAME|mix OTHER 25% }}
  if [[ "$token" == *"|mix "* ]]; then
    name="${token%%|*}"
    rest="${token#*|mix }"
    local other="${rest%% *}" amount="${rest#* }"
    mix_color "${!name}" "${!other}" "$amount"
    return
  fi

  if [[ "$token" == *"|"* ]]; then
    name="${token%%|*}"; filter="${token#*|}"
  else
    name="$token"; filter=""
  fi

  # Falla ruidosamente ante un token inexistente en vez de emitir vacío
  if [[ -z "${!name+x}" ]]; then
    echo "apply.sh: token desconocido '{{ $token }}'" >&2
    exit 1
  fi

  case "$filter" in
    strip) strip_hash "${!name}" ;;
    rgb)   to_rgb "${!name}" ;;
    "")    echo "${!name}" ;;
    *)     echo "apply.sh: filtro desconocido '$filter'" >&2; exit 1 ;;
  esac
}

render() {
  local tpl="$1" line out token value
  out=""
  # read -r sin IFS conserva espacios; el || [[ -n ]] captura última línea sin \n
  while IFS= read -r line || [[ -n "$line" ]]; do
    while [[ "$line" =~ \{\{[[:space:]]*([^}]+)[[:space:]]*\}\} ]]; do
      token="${BASH_REMATCH[1]}"
      token="${token%"${token##*[![:space:]]}"}"   # rtrim
      # resolve_token corre en un subshell: su `exit 1` mata el subshell, no
      # este script. Hay que propagar el fallo a mano o se escribiría un
      # destino corrupto con el token sin resolver.
      if ! value="$(resolve_token "$token")"; then
        echo "apply.sh: fallo al renderizar $tpl" >&2
        exit 1
      fi
      # Sustitución literal: ${x/pattern/repl} no interpreta el reemplazo
      line="${line/"${BASH_REMATCH[0]}"/$value}"
    done
    out+="$line"$'\n'
  done < "$tpl"
  printf '%s' "$out"
}

status=0
for entry in "${TARGETS[@]}"; do
  tpl="$THEME_DIR/templates/${entry%%:*}"
  dest="$REPO_ROOT/${entry#*:}"

  [[ -f "$tpl" ]] || { echo "apply.sh: falta la plantilla $tpl" >&2; exit 1; }

  if ! rendered="$(render "$tpl")"; then
    exit 1
  fi

  if (( CHECK_ONLY )); then
    if [[ ! -f "$dest" ]] || ! diff -q <(printf '%s' "$rendered") "$dest" &>/dev/null; then
      echo "DESINCRONIZADO: ${entry#*:}" >&2
      status=1
    else
      echo "ok: ${entry#*:}"
    fi
  else
    printf '%s' "$rendered" > "$dest"
    echo "generado: ${entry#*:}"
  fi
done

if (( CHECK_ONLY && status )); then
  echo "" >&2
  echo "Corre theme/apply.sh para regenerar." >&2
fi
exit $status

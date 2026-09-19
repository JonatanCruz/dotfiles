#!/usr/bin/env bash
# Corre los casos versionados de los hooks globales.
#
# Existe porque la batería se venía reconstruyendo A MANO en cada ronda de
# auditoría — y una batería que se reescribe de memoria no detecta regresiones:
# detecta lo que el autor recordó ese día. El 2026-09-19 eso permitió que un
# arreglo introdujera un falso positivo (`cp` desde memory) que sólo apareció
# porque el caso estaba escrito.
#
#   uso:  bash ~/.claude/hooks/tests/correr.sh [nombre-del-hook]
#
# Cada archivo `casos-<hook>.txt` se aparea con `../<hook>.sh`.
# Formato de línea:  <exit esperado> <TAB> <descripción> <TAB> <comando>
# `@MEM@` se sustituye por el directorio de memoria del proyecto actual.

set -uo pipefail
cd "$(dirname "$0")" || exit 1

MEM="${CLAUDE_MEMORY_DIR:-/home/jonatan/.claude/projects/-home-usuario-proyecto/memory}"
filtro="${1:-}"
total_p=0; total_f=0

for casos in casos-*.txt; do
  [ -e "$casos" ] || continue
  hook_name="${casos#casos-}"; hook_name="${hook_name%.txt}"
  [ -n "$filtro" ] && [ "$hook_name" != "$filtro" ] && continue

  hook="../${hook_name}.sh"
  if [ ! -f "$hook" ]; then
    printf '⚠️  %s: no existe %s — ¿se renombró o se retiró el hook?\n' "$casos" "$hook"
    continue
  fi

  printf '\n══ %s ══\n' "$hook_name"
  p=0; f=0
  while IFS=$'\t' read -r esperado desc cmd; do
    case "$esperado" in ''|'#'*) continue ;; esac
    [ -z "${cmd:-}" ] && continue
    cmd="${cmd//@MEM@/$MEM}"
    real=$(jq -nc --arg c "$cmd" '{tool_input:{command:$c}}' \
      | CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}" bash "$hook" >/dev/null 2>&1; echo $?)
    if [ "$real" = "$esperado" ]; then
      p=$((p+1))
    else
      f=$((f+1))
      printf '  ❌ exit=%s esp=%s  %s\n     %s\n' "$real" "$esperado" "$desc" "$cmd"
    fi
  done < "$casos"
  printf '  %s pasan, %s fallan\n' "$p" "$f"
  total_p=$((total_p+p)); total_f=$((total_f+f))
done

printf '\n──────────────\nTOTAL: %s pasan, %s fallan\n' "$total_p" "$total_f"
[ "$total_f" -eq 0 ]

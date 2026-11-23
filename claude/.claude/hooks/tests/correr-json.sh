#!/usr/bin/env bash
# Corre los casos de un hook que recibe un payload JSON completo (Read, Grep, Write,
# Edit, UserPromptSubmit), no `{command}`.
#
#   uso:  bash correr-json.sh <hook>
#
# Formato de `casos-<hook>.txt`:  <exit esperado> <TAB> <descripción> <TAB> <payload JSON>
# Para hooks que sólo escriben en stdout (sin exit 2), `1` en la columna de exit
# significa "imprimió algo" y `0` "no imprimió nada".

set -uo pipefail
cd "$(dirname "$0")" || exit 1
hook="$1"
casos="casos-${hook}.txt"
p=0; f=0
printf '\n══ %s ══\n' "$hook"
while IFS=$'\t' read -r esperado desc json; do
  case "$esperado" in '' | '#'*) continue ;; esac
  salida="$(printf '%s' "$json" | bash "../${hook}.sh" ${ARG_HOOK:-} 2>/dev/null)"
  real=$?
  if [ "$esperado" = 1 ]; then
    [ -n "$salida" ] && real=1 || real=0
  fi
  if [ "$real" = "$esperado" ]; then
    p=$((p+1))
  else
    f=$((f+1))
    printf '  ❌ exit=%s esp=%s  %s\n' "$real" "$esperado" "$desc"
  fi
done <"$casos"
printf '  %s pasan, %s fallan\n' "$p" "$f"
[ $((p+f)) -gt 0 ] && [ "$f" -eq 0 ]

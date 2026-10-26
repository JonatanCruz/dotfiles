#!/usr/bin/env bash
# Corre los casos versionados de los hooks.
#
#   uso:  bash ~/.claude/hooks/tests/correr.sh [nombre-del-hook]
#
# Cada `casos-<hook>.txt` se aparea con `../<hook>.sh`.
# Formato de línea:  <exit esperado> <TAB> <descripción> <TAB> <comando>
# `@MEM@` se sustituye por el directorio de memoria del proyecto actual.
#
# Los casos se versionan porque una batería reescrita de memoria detecta lo que
# el autor recordó, no regresiones.

set -uo pipefail

# Sin CLAUDE_MEMORY_DIR se deriva como lo arma el harness: el cwd con `/` y `.`
# convertidos en `-`, bajo ~/.claude/projects. Los casos sólo necesitan la FORMA
# de la ruta; nada se escribe ahí (el hook recibe el comando como texto).
MEM="${CLAUDE_MEMORY_DIR:-$HOME/.claude/projects/$(printf '%s' "$PWD" | tr '/.' '--')/memory}"
cd "$(dirname "$0")" || exit 1
filtro="${1:-}"
total_p=0; total_f=0

for casos in casos-*.txt; do
  [ -e "$casos" ] || continue
  hook_name="${casos#casos-}"; hook_name="${hook_name%.txt}"
  [ -n "$filtro" ] && [ "$hook_name" != "$filtro" ] && continue

  # Un archivo con runner PROPIO no lo corre éste. Los hooks de Write/Edit
  # reciben `{tool_input:{file_path,content}}`, no `{command}`: pasarles el
  # payload de Bash daría exit 0 en todo y reportaría verde sobre nada medido.
  # ...pero tampoco se SALTA en silencio: se delega y su resultado cuenta en el
  # total. Saltarlo sería la otra cara del mismo defecto — un archivo de casos
  # que nadie ejecuta mientras el total dice "0 fallan".
  if [ -f "correr-${hook_name}.sh" ]; then
    if bash "correr-${hook_name}.sh"; then
      total_p=$((total_p+1))
    else
      total_f=$((total_f+1))
    fi
    continue
  fi

  hook="../${hook_name}.sh"
  if [ ! -f "$hook" ]; then
    printf '⚠️  %s: no existe %s — ¿se renombró o se retiró el hook?\n' "$casos" "$hook"
    continue
  fi

  printf '\n══ %s ══\n' "$hook_name"
  p=0; f=0; saltadas=0
  while IFS=$'\t' read -r esperado desc cmd; do
    case "$esperado" in ''|'#'*) continue ;; esac
    # Una línea que NO parsea se CUENTA como falla, no se ignora: un archivo en
    # otro formato daría "0 pasan, 0 fallan" —verde sobre nada ejecutado—.
    case "$esperado" in
      0|2) ;;
      *) saltadas=$((saltadas+1)); continue ;;
    esac
    [ -z "${cmd:-}" ] && { saltadas=$((saltadas+1)); continue; }
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
  if [ "$saltadas" -gt 0 ]; then
    printf '  ⚠️  %s línea(s) NO PARSEAN (formato esperado: <0|2><TAB>desc<TAB>cmd)\n' "$saltadas"
    total_f=$((total_f+saltadas))
  fi
  # Un archivo de casos que no ejecuta NADA es un control apagado, no un éxito.
  if [ $((p+f)) -eq 0 ]; then
    printf '  ❌ CERO casos ejecutados — este archivo no está probando nada.\n'
    total_f=$((total_f+1))
  fi
  total_p=$((total_p+p)); total_f=$((total_f+f))
done

printf '\n──────────────\nTOTAL: %s pasan, %s fallan\n' "$total_p" "$total_f"

# ── PARIDAD zsh/bash ───────────────────────────────────────────────────────
# El shebang de los hooks es `bash`, así que el harness los corre con bash sin
# importar el shell del usuario. Pero `${v//x/}`, `[[ ]]` y `<<<` son sintaxis
# de bash, y un hook que zsh no parsea moriría antes de decidir — un control
# que no puede arrancar deja pasar todo.
if command -v zsh >/dev/null 2>&1; then
  rotos=""
  for h in ../*.sh; do
    [ -f "$h" ] || continue
    zsh -n "$h" 2>/dev/null || rotos="${rotos}   · $(basename "$h")\n"
  done
  if [ -n "$rotos" ]; then
    printf '\n⚠️  zsh NO parsea estos hooks:\n'; printf "$rotos"
    total_f=$((total_f+1))
  fi
fi

[ "$total_f" -eq 0 ]

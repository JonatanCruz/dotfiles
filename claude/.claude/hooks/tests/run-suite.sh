#!/usr/bin/env bash
# run-suite.sh — corre los casos de un hook y compara contra el exit esperado.
#
# POR QUÉ EXISTE: los encabezados de estos hooks afirmaban cosas que no eran
# ciertas ("estructuralmente imposible", "el falso positivo es imposible por
# construcción"). Las dos sobrevivieron meses porque una afirmación absoluta
# justifica no volver a verificar. Esta suite convierte esas afirmaciones en algo
# que se corre, no que se lee.
#
# USO:
#   ./run-suite.sh <hook.sh> <casos.txt>
#   ./run-suite.sh            # sin argumentos: corre todos los casos-*.txt
#
# FORMATO de los casos (una línea por caso, separador `|`):
#   CLASE|descripción|comando
#
#   EVA  evasión medida que DEBE bloquear ahora        → espera exit 2
#   BLK  algo que ya bloqueaba y debe seguir igual     → espera exit 2
#   OK   uso legítimo que NO debe bloquearse jamás     → espera exit 0
#
# Las clases OK son la mitad que importa: un gate que sólo se prueba con lo que
# debe bloquear termina mordiendo el trabajo normal, y ahí se desactiva y se
# pierden también los bloqueos que sí servían.
#
# Sustituciones disponibles en el comando:
#   @M@  un archivo de memoria del harness (la ruta protegida)
#   @D@  el directorio de memoria del harness
#   \n   salto de línea (para probar continuación de línea)

set -uo pipefail

AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS="$(dirname "$AQUI")"

M='/home/jonatan/.claude/projects/-home-x-proj/memory/MEMORY.md'
D='/home/jonatan/.claude/projects/-home-x-proj/memory'

correr_uno() {
  local hook="$1" casos="$2" fails=0 total=0
  echo "── $(basename "$hook")  ←  $(basename "$casos")"
  while IFS='|' read -r clase desc cmd; do
    [ -z "${clase:-}" ] && continue
    case "$clase" in \#*) continue;; esac
    cmd="${cmd//@M@/$M}"
    cmd="${cmd//@D@/$D}"
    cmd="$(printf '%b' "$cmd")"
    local want code
    case "$clase" in
      EVA|BLK) want=2;;
      OK)      want=0;;
      *)       echo "  clase desconocida: $clase"; continue;;
    esac
    code=$(printf '%s' "$cmd" \
      | python3 -c 'import json,sys; print(json.dumps({"tool_input":{"command":sys.stdin.read()}}))' \
      | "$hook" >/dev/null 2>&1; echo $?)
    total=$((total+1))
    if [ "$code" = "$want" ]; then
      printf '  %-4s ok    %s\n' "$clase" "$desc"
    else
      printf '  %-4s FALLA (exit=%s, esperaba %s)  %s\n' "$clase" "$code" "$want" "$desc"
      fails=$((fails+1))
    fi
  done < "$casos"
  echo "  → $((total-fails))/$total"
  return $fails
}

total_fails=0
if [ $# -ge 2 ]; then
  correr_uno "$1" "$2" || total_fails=$?
else
  for casos in "$AQUI"/casos-*.txt; do
    [ -e "$casos" ] || continue
    nombre="$(basename "$casos")"; nombre="${nombre#casos-}"; nombre="${nombre%.txt}"
    hook="$HOOKS/$nombre.sh"
    if [ ! -x "$hook" ]; then
      echo "── $nombre: no hay hook ejecutable en $hook — salteado"
      continue
    fi
    correr_uno "$hook" "$casos" || total_fails=$((total_fails + $?))
    echo
  done
fi

if [ "$total_fails" -gt 0 ]; then
  echo "DESVÍOS: $total_fails"
  exit 1
fi
echo "sin desvíos"

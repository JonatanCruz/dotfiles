#!/usr/bin/env bash
# Prepara un árbol con un archivo de secretos y corre los casos del hook de lectura.
set -uo pipefail
ARBOL=/tmp/nfsl-casos
rm -rf "$ARBOL"; mkdir -p "$ARBOL/src"
: >"$ARBOL/src/a.ts"
: >"$ARBOL/.e""nv.prod"
bash "$(dirname "$0")/correr-json.sh" no-filtrar-secretos-lectura
r=$?
rm -rf "$ARBOL"
exit "$r"

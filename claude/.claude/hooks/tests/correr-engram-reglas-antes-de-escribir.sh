#!/usr/bin/env bash
# Casos de `engram-reglas-antes-de-escribir.sh`.
#
# CADA PATRÓN DE LA TABLA EXIGE DOS CASOS: el que BLOQUEA (la construcción que
# viola la regla) y su NEGATIVO (el mismo vocabulario en uso legítimo). El
# negativo es el que importa: un gate que muerde trabajo legítimo se rodea, y
# rodeado deja de existir. Agregar una regla a la tabla sin su negativo deja el
# falso positivo sin cubrir.
#
#   bash correr-engram-reglas-antes-de-escribir.sh   ·   exit 0 = todos pasan

set -uo pipefail
HOOK="$(cd "$(dirname "$0")/.." && pwd)/engram-reglas-antes-de-escribir.sh"
[ -x "$HOOK" ] || { echo "no ejecutable: $HOOK" >&2; exit 2; }
# Las reglas son del proyecto; estas pruebas usan una tabla de ejemplo.
export ENGRAM_REGLAS_ARCHIVO
ENGRAM_REGLAS_ARCHIVO="$(cd "$(dirname "$0")" && pwd)/reglas-escritura-ejemplo.tsv"

ok=0; fail=0
caso() { # caso <esperado> <desc> <file_path> <texto>
  local esp="$1" desc="$2" ruta="$3" txt="$4"
  local p; p="$(jq -nc --arg p "$ruta" --arg c "$txt" '{tool_input:{file_path:$p,new_string:$c}}')"
  printf '%s' "$p" | "$HOOK" >/dev/null 2>&1
  local got=$?
  if [ "$got" = "$esp" ]; then ok=$((ok+1)); printf '  ✓ %s\n' "$desc"
  else fail=$((fail+1)); printf '  ✗ %s (esperado %s, dio %s)\n' "$desc" "$esp" "$got"; fi
}

echo "── BLOQUEAN: las construcciones que violan una regla ──"
caso 2 "frase libre viaja como motivo"      /r/a.ts 'const humanMessage = `No se pudo: ${motivo}`;'
caso 2 "JOIN/FROM a tabla legacy"           /r/q.ts 'const q = `SELECT n FROM legacy_catalogo`;'
caso 2 "proveedor resuelto contra identity"  /r/r.ts 'const v = await identityRepo.findProveedor(id);'

echo "── NEGATIVOS: mismo vocabulario, uso legítimo ──"
caso 0 "motivo como enum"                   /r/a.ts 'const motivo = MotivoRechazo.SALDO_INSUFICIENTE;'
caso 0 "la frase libre va al log"           /r/a.ts 'logger.warn(`falla: ${motivo}`);'
caso 0 "legacy nombrado en un comentario"   /r/a.ts '// migrado desde el legacy hace meses'
caso 0 "FROM a tabla propia"                /r/q.ts 'SELECT * FROM lineas JOIN clientes ON a=b'
caso 0 "identity resolviendo un usuario"    /r/r.ts 'const u = await identityRepo.findUser(id);'
caso 0 "proveedor en su propio registro"       /r/r.ts 'const v = await partnersRepo.findProveedor(tel);'

echo "── EXENTOS: nombrar la regla es el trabajo del archivo ──"
caso 0 "markdown (un ADR la discute)"       /r/ADR.md 'identityRepo.findProveedor y legacy_catalogo'
caso 0 "test (cita el texto gobernado)"     /r/x.test.ts 'identityRepo.findProveedor(id)'

echo "── BANALES ──"
caso 0 "bump de versión"                    /r/package.json '{"version":"1.4.2"}'
caso 0 "import"                             /r/a.ts 'import { debounce } from "lodash";'
caso 0 "css"                                /r/a.css '.btn{padding:4px}'

echo "── FALLA CERRADO ──"
D="$(mktemp -d)"; for b in cat printf grep sed tr head sqlite3 id; do
  ln -sf "$(command -v "$b" 2>/dev/null)" "$D/$b" 2>/dev/null || true; done
printf '%s' '{"tool_input":{"file_path":"/r/a.ts","new_string":"const x=1;"}}' \
  | PATH="$D" /bin/bash "$HOOK" >/dev/null 2>&1
if [ $? = 2 ]; then ok=$((ok+1)); echo "  ✓ sin jq bloquea (no se rinde en silencio)"
else fail=$((fail+1)); echo "  ✗ sin jq NO bloqueó"; fi

# Engram aporta el texto, no el veredicto: sin DB el patrón debe seguir cazando.
printf '%s' '{"tool_input":{"file_path":"/r/r.ts","new_string":"await identityRepo.findProveedor(i);"}}' \
  | ENGRAM_DB=/nonexistente/x.db "$HOOK" >/dev/null 2>&1
if [ $? = 2 ]; then ok=$((ok+1)); echo "  ✓ sin DB igual bloquea"
else fail=$((fail+1)); echo "  ✗ sin DB dejó pasar el cruce"; fi

echo "── REGLAS AJENAS: el archivo viene del repo, no se le confía ──"
# Un repo clonado puede traer un id que es SQL. Medido contra la versión que
# interpolaba el id: `7; DELETE FROM observations; --` vaciaba la base.
command -v sqlite3 >/dev/null 2>&1 && {
  X="$(mktemp -d)"; S="$(printf '\001')"
  sqlite3 "$X/e.db" "CREATE TABLE observations(id INTEGER PRIMARY KEY, content TEXT, deleted_at TEXT); INSERT INTO observations VALUES(7,'r',NULL);"
  printf 'prohibido%s7; DELETE FROM observations; --%st%se\n' "$S" "$S" "$S" > "$X/r.tsv"
  printf '%s' '{"tool_input":{"file_path":"/r/a.ts","new_string":"algo prohibido"}}' \
    | ENGRAM_DB="$X/e.db" ENGRAM_REGLAS_ARCHIVO="$X/r.tsv" "$HOOK" >/dev/null 2>&1
  if [ "$(sqlite3 "$X/e.db" 'select count(*) from observations')" = 1 ]; then
    ok=$((ok+1)); echo "  ✓ un id con SQL no toca la base"
  else fail=$((fail+1)); echo "  ✗ un id con SQL modificó la base"; fi
  rm -rf "$X"
}
echo "── SIN REGLAS: un repo que no usa el gate ──"
# Sin archivo de reglas no hay nada que aplicar: ni la construcción "prohibida"
# ni la falta de jq frenan una escritura.
SIN="$(mktemp -d)"; git -C "$SIN" init -q 2>/dev/null
printf '%s' '{"tool_input":{"file_path":"/r/r.ts","new_string":"await identityRepo.findProveedor(i);"}}' \
  | (cd "$SIN" && env -u ENGRAM_REGLAS_ARCHIVO CLAUDE_PROJECT_DIR="$SIN" "$HOOK") >/dev/null 2>&1
if [ $? = 0 ]; then ok=$((ok+1)); echo "  ✓ repo sin reglas: no bloquea"
else fail=$((fail+1)); echo "  ✗ repo sin reglas bloqueó"; fi
printf '%s' '{"tool_input":{"file_path":"/r/a.ts","new_string":"const x=1;"}}' \
  | (cd "$SIN" && PATH="$D" /usr/bin/env -u ENGRAM_REGLAS_ARCHIVO CLAUDE_PROJECT_DIR="$SIN" /bin/bash "$HOOK") >/dev/null 2>&1
if [ $? = 0 ]; then ok=$((ok+1)); echo "  ✓ repo sin reglas y sin jq: no bloquea"
else fail=$((fail+1)); echo "  ✗ repo sin reglas y sin jq bloqueó"; fi
# Las reglas del repo, en <raíz>/.claude/reglas-escritura.tsv, se aplican solas.
mkdir -p "$SIN/.claude" && cp "$ENGRAM_REGLAS_ARCHIVO" "$SIN/.claude/reglas-escritura.tsv"
printf '%s' '{"tool_input":{"file_path":"/r/r.ts","new_string":"await identityRepo.findProveedor(i);"}}' \
  | (cd "$SIN" && env -u ENGRAM_REGLAS_ARCHIVO CLAUDE_PROJECT_DIR="$SIN" "$HOOK") >/dev/null 2>&1
if [ $? = 2 ]; then ok=$((ok+1)); echo "  ✓ reglas del repo: se aplican"
else fail=$((fail+1)); echo "  ✗ reglas del repo: no se aplicaron"; fi
rm -rf "$SIN" "$D"
echo
echo "pasan: $ok · fallan: $fail"
[ "$fail" = 0 ] || exit 1

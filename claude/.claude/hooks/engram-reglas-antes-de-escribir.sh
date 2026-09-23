#!/usr/bin/env bash
# PreToolUse (matcher: Write|Edit|MultiEdit). BLOQUEA una escritura que cruza
# una regla ya dictada por el dueño, y muestra esa regla desde Engram.
#
# Cierra el momento sin cobertura: los otros dos hooks de Engram corren al
# hablar el usuario y al delegar. Escribir código no tenía ninguno.
#
# ── EL PATRÓN DECIDE; ENGRAM SÓLO APORTA EL TEXTO ───────────────────────────
#
# El bloqueo lo decide la tabla CERRADA de abajo, NO el ranking FTS. En esta DB
# las crónicas de sprint comparten `type: decision` con los invariantes, así
# que el mejor match de una query puede ser un registro de avance en vez de una
# regla. Un umbral sobre ese ranking bloquea por una crónica: falso positivo
# crónico, que entrena el bypass y desactiva el gate.
#
# Engram aporta el TEXTO de la regla citada, con su fecha, para leer la fuente
# y no un resumen que envejece dentro de este archivo.
#
# La tabla CRECE cuando el dueño dicta una regla, no cuando crece la DB. Cada
# entrada nueva exige su caso negativo en `tests/casos-engram-reglas.txt`.
#
# ── BLOQUEA, NO INYECTA ─────────────────────────────────────────────────────
#
# Un hook que informa se hojea; el que devuelve exit 2 obliga a actuar.
#
# ── SIN ESTADO, A PROPÓSITO ─────────────────────────────────────────────────
#
# No hay marca de "ya la leí": un hash del texto no prueba lectura, y mete
# estado con ciclo de vida en un hook que puede no tenerlo. Con patrón cerrado
# el bloqueo ya es idempotente — reintentar lo mismo vuelve a chocar, y la
# salida es corregir el texto, que es la acción que se quiere forzar.
#
# NO hay override: un gate que se rodea deja de existir.
#
# ── FALLA CERRADO ───────────────────────────────────────────────────────────
#
# Sin `jq` no se puede leer qué se escribe → frena. Si la DB falta, el patrón
# igual bloquea y se cita la regla por título: el veredicto no depende de que
# Engram esté disponible.
#
#   stdin: JSON { tool_input: { file_path, content|new_string|edits[] } }
#   exit 0 = pasa · exit 2 = bloquea

set -uo pipefail

# Sin esto grep declara "binary file matches" sobre texto no-UTF8 y deja de
# reportar la coincidencia: el gate quedaría ciego sobre el archivo raro.
export LC_ALL=C

DB="${ENGRAM_DB:-$HOME/.engram/engram.db}"

payload="$(cat 2>/dev/null || true)"
[ -z "${payload//[[:space:]]/}" ] && exit 0

if ! command -v jq >/dev/null 2>&1; then
  cat >&2 <<'EOF'
🛑 BLOQUEADO (engram-reglas-antes-de-escribir): falta `jq`.

Sin jq no se puede leer qué se está escribiendo, y por lo tanto no se puede
saber si cruza una regla ya dictada. No poder verificar es motivo para frenar,
no para seguir. Instalá jq y reintentá.
EOF
  exit 2
fi

ruta="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)"
texto="$(printf '%s' "$payload" | jq -r '
  (.tool_input.content // "") + "\n" +
  (.tool_input.new_string // "") + "\n" +
  ((.tool_input.edits // []) | map(.new_string // "") | join("\n"))' 2>/dev/null || true)"
[ -z "${texto//[[:space:]]/}" ] && exit 0

# EXENCIONES, cerradas: lugares donde NOMBRAR la regla es el trabajo del
# archivo. Un ADR la discute, un test cita el texto gobernado, y este hook y
# sus casos enuncian los patrones que cazan.
case "$ruta" in
  */engram-reglas-antes-de-escribir.sh|*/casos-engram-reglas*) exit 0 ;;
  *.md|*.mdx|*.markdown) exit 0 ;;
  */test/*|*/tests/*|*/__tests__/*|*/spec/*|*/testdata/*) exit 0 ;;
  *.test.*|*.spec.*|*_test.*|*-test.*|*/test_*|*.bats) exit 0 ;;
  *pnpm-lock.yaml|*package-lock.json|*.snap|*.lock) exit 0 ;;
esac

# ── LA TABLA ────────────────────────────────────────────────────────────────
# PATRÓN  id de Engram  título  qué exige la regla.
# El patrón describe la FORMA del cruce, no el tema: un tema dispara con
# cualquier mención, una forma sólo con la construcción que viola la regla.
# Separador: el byte 0x01, que no aparece en código ni en un patrón.
# NO se usa un caracter multibyte: IFS parte por BYTES y rompería los campos.
reglas() {
cat <<'TABLA'
(humanmessage|mensaje|texto|motivo|razon|razón|detalle)[a-z]*[[:space:]]*[:=][^=;]{0,80}\$\{[[:space:]]*(motivo|razon|razón|error|falla|detalle)1482Sólo viaja el enum: negativa, fallo Y validación. La frase va al logEntre servicios viaja el ENUM, no la frase. El texto para humanos se arma en el borde; la frase libre va al log, nunca al contrato.
(join|from)[[:space:]]+[a-z_."`]*(legacy|legacy_app|legacy_prod)1310El legacy es EVIDENCIA de qué significan sus valores, NO fuente de lógica de negocioEl legacy sirve para SABER qué significó un valor, no para que la plataforma dependa de él en runtime. Si la lógica lo consulta en vivo, se invirtió la relación.
(identity|users)[a-z_.]*\.(find|get|select|query|buscar)[a-z_]*(proveedor|socio|sub)1237EL CRITERIO de identidad: el proveedor NO es usuario de la plataformaLos proveedores no viven en identity: el registro está en svc-catalog, con su propia clave. Resolverlos contra identity.users es buscarlos donde no están.
TABLA
}

texto_low="$(printf '%s' "$texto" | tr '[:upper:]' '[:lower:]')"

CRUCE=""; FRAGMENTO=""
while IFS='' read -r PAT ID TITULO EXIGE; do
  [ -n "${PAT:-}" ] || continue
  if printf '%s' "$texto_low" | grep -aqE "$PAT" 2>/dev/null; then
    CRUCE="$ID$TITULO$EXIGE"
    FRAGMENTO="$(printf '%s' "$texto_low" | grep -aoE "$PAT" 2>/dev/null | head -1)"
    break
  fi
done <<EOF
$(reglas)
EOF

[ -n "$CRUCE" ] || exit 0

ID="${CRUCE%%*}"; RESTO="${CRUCE#*}"
TITULO="${RESTO%%*}"; EXIGE="${RESTO#*}"

CUERPO=""
if [ -f "$DB" ] && command -v sqlite3 >/dev/null 2>&1; then
  CUERPO="$(sqlite3 "$DB" "
    SELECT substr(replace(content, char(10), ' '), 1, 700)
    FROM observations WHERE id = $ID AND deleted_at IS NULL;" 2>/dev/null || true)"
fi

{
  echo "🛑 BLOQUEADO (engram-reglas-antes-de-escribir)."
  echo
  echo "ESTO SE ESTÁ ESCRIBIENDO:"
  echo "   ${FRAGMENTO:-<el patrón matcheó el texto del cambio>}"
  echo
  echo "LA REGLA (Engram #$ID):"
  echo "   $TITULO"
  if [ -n "$CUERPO" ]; then
    echo
    echo "   $CUERPO…"
  fi
  echo
  echo "LA DISCREPANCIA:"
  echo "   $EXIGE"
  echo
  cat <<'EOF'
DOS SALIDAS, las dos baratas:
  · Corregí el cambio para que respete la regla.
  · Si la regla ya no aplica, actualizá la memoria en Engram y volvé.

Reintentar el mismo texto vuelve a chocar: no hay override ni marca de "ya la
leí". Lo que abre el paso es cambiar el código o cambiar la regla.
EOF
} >&2

exit 2

#!/usr/bin/env bash
# engram-autorecall.sh — UserPromptSubmit hook
#
# QUÉ RESUELVE: las memorias existen pero no se consultan en el momento de
# actuar, y el agente termina afirmando desde memoria stale teniendo el dato real
# guardado. Una instrucción de prosa ("buscá antes de opinar") no previene ese
# error, porque el agente cree que ya sabe. Este hook pone el recall en la
# estructura: en cada prompt consulta el FTS de Engram e inyecta lo relevante al
# turno, sin depender de que alguien se acuerde de buscar.
#
# POR QUÉ NO BLOQUEA: inyectar contexto no tiene contraparte destructiva, y un
# recall vacío no es un error — es la mayoría de los turnos. Fail-open estricto:
# cualquier fallo (sin DB, sin sqlite3, sin jq) sale 0 y en silencio.

set -uo pipefail

# ── QUÉ TIPOS NO SE RECUERDAN (y por qué la lista es CONFIGURABLE) ──────────
#
# El ranking de Engram es `ORDER BY fts.rank` a secas: bm25 sobre title+content,
# sin pesos por columna, sin boost por tipo y sin decaimiento por fecha. MEDIDO
# leyendo el código (internal/store/store.go), y comprobado: retipar una fila y
# repetir la misma consulta devuelve EXACTAMENTE las mismas posiciones.
#
# Consecuencia práctica, que es lo único que importa acá: **el tipo NO puede
# subir ni bajar nada en el ranking. Sólo sirve para SACAR filas de la
# competencia con un WHERE.** Por eso esto es una exclusión y no un peso.
#
# Qué se excluye por defecto: los tipos del esquema de Engram que registran un
# INSTANTE (el resumen de una sesión que ya terminó) en vez de algo que siga
# siendo cierto mañana. Un resumen de sesión compite por las mismas palabras
# que una regla vigente y ocupa su lugar en una lista capada a 10-20.
#
# DESACOPLADO A PROPÓSITO: la lista son tipos del esquema de Engram, NO de un
# proyecto. Nada de nombres de servicios, rutas ni vocabulario de un repo: estos
# dotfiles se usan con cualquiera. Para ajustarla sin tocar la lógica:
#
#   export ENGRAM_RECALL_EXCLUDE_TYPES="session_summary,checkpoint"
#   export ENGRAM_RECALL_EXCLUDE_TYPES=""   # no excluir nada
#
# Con una base vacía, de otro proyecto, o sin ninguna fila de estos tipos, el
# efecto es NULO — el WHERE simplemente no saca nada. No hay nada que instalar.
ENGRAM_RECALL_EXCLUDE_TYPES="${ENGRAM_RECALL_EXCLUDE_TYPES-session_summary}"

# Convierte "a,b" en "'a','b'" para un IN (). Vacío ⇒ cadena vacía ⇒ sin filtro.
# Comillas simples duplicadas por si alguien pone un apóstrofo en la env var.
_engram_exclude_sql() {
  printf '%s' "${1-}" | tr ',' '\n' | sed "s/^[[:space:]]*//; s/[[:space:]]*$//" \
    | grep -v '^$' | sed "s/'/''/g; s/^/'/; s/$/'/" | paste -sd, - 2>/dev/null || true
}
EXCLUDE_LIST="$(_engram_exclude_sql "$ENGRAM_RECALL_EXCLUDE_TYPES")"
# Sin lista ⇒ predicado vacío (no `AND type NOT IN ()`, que es un error de SQL).
if [ -n "$EXCLUDE_LIST" ]; then
  TYPE_FILTER="AND o.type NOT IN ($EXCLUDE_LIST)"
else
  TYPE_FILTER=""
fi

DB="$HOME/.engram/engram.db"
[ -f "$DB" ] || exit 0
command -v sqlite3 >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

INPUT="$(cat 2>/dev/null || true)"
PROMPT="$(printf '%s' "$INPUT" | jq -r '.prompt // empty' 2>/dev/null || true)"
CWD="$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)"
[ -n "$PROMPT" ] || exit 0

# Proyecto = basename del cwd (convención de mem_session_start)

# Prompts muy cortos (acks tipo "ok", "sí") no ameritan recall
[ "${#PROMPT}" -ge 15 ] || exit 0

# Extraer keywords: minúsculas, solo alfanuméricos, palabras >=5 chars,
# sin stopwords comunes es/en, top 8 únicas.
KEYWORDS="$(printf '%s' "$PROMPT" \
  | tr '[:upper:]' '[:lower:]' \
  | tr -cs '[:alnum:]áéíóúñü' '\n' \
  | awk 'length($0) >= 5' \
  | grep -vxE 'para|pero|como|cuando|donde|entonces|porque|hacer|hacemos|puede|puedes|podemos|tiene|tienen|estamos|ahora|siempre|mientras|sigue|siguen|trabajando|quiero|necesito' \
  | sort -u \
  | awk '{ print length($0), $0 }' | sort -rn | head -8 | cut -d' ' -f2- \
  | tr '\n' ' ' | sed 's/ $//')"
[ -n "$KEYWORDS" ] || exit 0

# Query FTS5: OR de keywords, escapadas como frases entre comillas dobles
FTS_QUERY="$(printf '%s' "$KEYWORDS" | awk '{for(i=1;i<=NF;i++){printf "%s\"%s\"", (i>1?" OR ":""), $i}}')"
[ -n "$FTS_QUERY" ] || exit 0

RESULTS="$(sqlite3 -separator '|' "$DB" "
  SELECT o.type, o.title, substr(replace(replace(o.content, char(10), ' '), '|', '/'), 1, 600), substr(o.created_at, 1, 10)
  FROM observations_fts f
  JOIN observations o ON o.id = f.rowid
  WHERE observations_fts MATCH '$(printf '%s' "$FTS_QUERY" | sed "s/'/''/g")'
    AND o.deleted_at IS NULL
    $TYPE_FILTER
  ORDER BY rank
  LIMIT 4;
" 2>/dev/null || true)"

[ -n "$RESULTS" ] || exit 0

# ⚠️ EL ENCABEZADO IMPORTA, y el anterior causaba el daño que venía a evitar.
#
# Decía: "son contexto, NO medición". Medido el 2026-09-19: el agente lo leyó
# como "esto no es evidencia, seguí de largo" y las ignoró sistemáticamente. El
# caso testigo: una memoria del 05-sep decía textual *"culpar al SyncInventarioJob
# fue FALSO"*, llegó con ese encabezado, y el agente armó igual su diagnóstico
# sobre el SyncInventarioJob — repitiendo el error exacto que la memoria
# advertía. El dueño lo detectó y ordenó arreglarlo.
#
# La distinción correcta NO es "contexto vs medición": es que una memoria es un
# HECHO DATADO. Lo que dice fue cierto cuando se midió. Puede haber cambiado —
# por eso se verifica antes de actuar— pero ignorarla es descartar una medición
# que alguien ya pagó. Sobre todo cuando REFUTA algo: una hipótesis ya
# descartada es lo más caro de volver a recorrer.
echo "📚 ENGRAM — MEDICIONES PREVIAS que matchean este prompt. NO son ruido de fondo:"
echo "   · Cada una fue MEDIDA en su fecha. Si contradice lo que estás por afirmar, MEDÍ ANTES de afirmar."
echo "   · Si REFUTA una hipótesis, esa hipótesis ya se descartó una vez: no la repitas sin evidencia nueva."
echo "   · Pueden estar desactualizadas: verificá contra la fuente primaria antes de ACTUAR sobre ellas."
printf '%s\n' "$RESULTS" | while IFS='|' read -r TYPE TITLE EXCERPT DATE; do
  echo "- [$DATE·$TYPE] $TITLE — $EXCERPT…"
done
exit 0

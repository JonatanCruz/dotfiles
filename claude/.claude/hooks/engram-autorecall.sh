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

DB="$HOME/.engram/engram.db"
[ -f "$DB" ] || exit 0
command -v sqlite3 >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

INPUT="$(cat 2>/dev/null || true)"
PROMPT="$(printf '%s' "$INPUT" | jq -r '.prompt // empty' 2>/dev/null || true)"
CWD="$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)"
[ -n "$PROMPT" ] || exit 0

# Proyecto = basename del cwd (convención de mem_session_start)
PROJECT="$(basename "${CWD:-$PWD}" 2>/dev/null || echo "")"

# Prompts muy cortos (acks tipo "ok", "sí") no ameritan recall
[ "${#PROMPT}" -ge 15 ] || exit 0

# Extraer keywords: minúsculas, solo alfanuméricos, palabras >=5 chars,
# sin stopwords comunes es/en, top 8 únicas.
KEYWORDS="$(printf '%s' "$PROMPT" \
  | tr '[:upper:]' '[:lower:]' \
  | tr -cs '[:alnum:]áéíóúñü' '\n' \
  | awk 'length($0) >= 5' \
  | grep -vxE 'para|pero|como|cuando|donde|entonces|porque|hacer|hacemos|puede|puedes|podemos|tiene|tienen|estamos|ahora|siempre|mientras|sigue|siguen|trabajando|quiero|necesito' \
  | sort -u | head -8 | tr '\n' ' ' | sed 's/ $//')"
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
    $( [ -n "$PROJECT" ] && printf "AND o.project = '%s'" "$(printf '%s' "$PROJECT" | sed "s/'/''/g")" )
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

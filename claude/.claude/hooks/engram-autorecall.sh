#!/usr/bin/env bash
# engram-autorecall.sh — UserPromptSubmit hook
#
# PROBLEMA QUE RESUELVE (2026-07-13, feedback del dueño): las memorias de Engram
# existen pero no se consultan en el momento de actuar — el agente afirma desde
# memoria stale ("2 vendedores piloto") teniendo los datos reales guardados.
# Una instrucción de prosa ("busca antes de opinar") no previene el error
# competente; este hook pone el control en la ESTRUCTURA (Meadows): en cada
# prompt del usuario, consulta el FTS de Engram e inyecta las memorias
# relevantes al contexto del turno. El recall deja de depender de disciplina.
#
# Fail-open: cualquier error → exit 0 sin output (nunca bloquea el trabajo).

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
  SELECT o.type, o.title, substr(replace(replace(o.content, char(10), ' '), '|', '/'), 1, 220), substr(o.created_at, 1, 10)
  FROM observations_fts f
  JOIN observations o ON o.id = f.rowid
  WHERE observations_fts MATCH '$(printf '%s' "$FTS_QUERY" | sed "s/'/''/g")'
    AND o.deleted_at IS NULL
    $( [ -n "$PROJECT" ] && printf "AND o.project = '%s'" "$(printf '%s' "$PROJECT" | sed "s/'/''/g")" )
  ORDER BY rank
  LIMIT 4;
" 2>/dev/null || true)"

[ -n "$RESULTS" ] || exit 0

echo "📚 ENGRAM AUTO-RECALL (memorias que matchean este prompt — VERIFICA vigencia antes de usarlas como evidencia; son contexto, no medición):"
printf '%s\n' "$RESULTS" | while IFS='|' read -r TYPE TITLE EXCERPT DATE; do
  echo "- [$DATE·$TYPE] $TITLE — $EXCERPT…"
done
exit 0

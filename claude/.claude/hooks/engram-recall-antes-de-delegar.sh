#!/usr/bin/env bash
# engram-recall-antes-de-delegar.sh — PreToolUse sobre la herramienta de agentes.
#
# EL HUECO QUE CIERRA: el autorecall corre en `UserPromptSubmit`, o sea sólo
# cuando escribe el usuario. Al DELEGAR, ningún hook consulta la memoria — y ese
# es justo el momento en que el olvido cuesta caro: el encargo sale redactado
# desde el código, ignorando decisiones ya tomadas en sesiones anteriores. El
# agente delegado entonces investiga lo ya resuelto y lo reporta como hallazgo.
#
# POR QUÉ EN LA ESTRUCTURA: el recall no puede depender de que el agente recuerde
# buscar, porque el que olvidó la decisión no sabe que la olvidó. Acá la memoria
# relevante llega sola, ANTES de que el encargo se ejecute.
#
# FILTRO: sólo `decision`/`architecture`/`preference`/`feedback`. Al delegar
# importa lo que se DECIDIÓ, no el registro de un bugfix; filtrar es lo que
# separa la señal del ruido y evita que el aviso se vuelva ignorable.
#
# NO BLOQUEA: inyecta contexto y sale 0. Fail-open ante cualquier error.
#
set -uo pipefail

DB="$HOME/.engram/engram.db"
[ -f "$DB" ] || exit 0
command -v sqlite3 >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

INPUT="$(cat 2>/dev/null || true)"

# El texto del encargo es `tool_input.prompt`. Se le suma `description` porque
# suele nombrar el dominio en pocas palabras ("el bot pregunta a partners").
PROMPT="$(printf '%s' "$INPUT" | jq -r '
  [(.tool_input.description // empty), (.tool_input.prompt // empty)] | join(" ")
' 2>/dev/null || true)"
CWD="$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)"
[ -n "$PROMPT" ] || exit 0


[ "${#PROMPT}" -ge 40 ] || exit 0

# Mismas keywords que el hook hermano. Se agregan a las stopwords las palabras
# que abundan en un encargo pero no dicen nada del dominio ("verificá", "tests",
# "commit"): sin esto el recall trae memorias de proceso en vez de decisiones.
KEYWORDS="$(printf '%s' "$PROMPT" \
  | tr '[:upper:]' '[:lower:]' \
  | tr -cs '[:alnum:]áéíóúñü' '\n' \
  | awk 'length($0) >= 5' \
  | grep -vxE 'para|pero|como|cuando|donde|entonces|porque|hacer|hacemos|puede|puedes|podemos|tiene|tienen|estamos|ahora|siempre|mientras|sigue|siguen|trabajando|quiero|necesito|verifica|verificá|verificar|tarea|encargo|archivo|archivos|codigo|código|tests|test|commit|commits|rama|branch|worktree|reporta|reportá|reportar|entregable|deberia|debería|antes|despues|después' \
  | sort -u \
  | awk '{ print length($0), $0 }' | sort -rn | head -8 | cut -d' ' -f2- \
  | tr '\n' ' ' | sed 's/ $//')"
[ -n "$KEYWORDS" ] || exit 0

FTS_QUERY="$(printf '%s' "$KEYWORDS" | awk '{for(i=1;i<=NF;i++){printf "%s\"%s\"", (i>1?" OR ":""), $i}}')"
[ -n "$FTS_QUERY" ] || exit 0

# Ver el filtro explicado en el encabezado: decisiones, no bugfixes.
RESULTS="$(sqlite3 -separator '|' "$DB" "
  SELECT o.type, o.title, substr(replace(replace(o.content, char(10), ' '), '|', '/'), 1, 260), substr(o.created_at, 1, 10)
  FROM observations_fts f
  JOIN observations o ON o.id = f.rowid
  WHERE observations_fts MATCH '$(printf '%s' "$FTS_QUERY" | sed "s/'/''/g")'
    AND o.deleted_at IS NULL
    AND o.type IN ('decision','architecture','preference','feedback')
  ORDER BY rank
  LIMIT 4;
" 2>/dev/null || true)"

[ -n "$RESULTS" ] || exit 0

echo "🧠 ANTES DE DELEGAR — decisiones ya tomadas que matchean este encargo:"
printf '%s\n' "$RESULTS" | while IFS='|' read -r TYPE TITLE EXCERPT DATE; do
  echo "- [$DATE·$TYPE] $TITLE — $EXCERPT…"
done
echo ""
echo "Si alguna CONTRADICE el encargo que estás por lanzar, corregí el encargo ANTES de mandarlo:"
echo "el agente trabaja con lo que le diste, no con lo que se decidió en otra sesión."
exit 0

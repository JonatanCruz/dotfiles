#!/usr/bin/env bash
# engram-recall-antes-de-delegar.sh — PreToolUse hook sobre la herramienta de agentes
#
# PROBLEMA QUE RESUELVE (2026-08-13, feedback del dueño): `engram-autorecall.sh`
# corre en `UserPromptSubmit`, o sea SOLO cuando el dueño escribe. Cuando el
# agente principal DELEGA trabajo, ningún hook consulta la memoria — y ese es
# justo el momento en que el olvido cuesta caro: el encargo sale escrito desde
# el código, ignorando decisiones que el dueño ya tomó en sesiones anteriores.
#
# Costo medido ese día: se encargó mover el gate del bot preguntando un destino
# YA decidido, y se reportó como "hallazgo" la ubicación de una tabla que YA
# estaba deliberada. El dueño lo nombró: *"¿de qué sirve estar escribiendo en la
# memoria una y otra vez la misma regla?"* — porque escribir sin leer acumula.
#
# El recall no puede depender de que el agente recuerde buscar (es el mismo
# "error competente" de las Reglas #11/#13/#14: el agente que CREE que cumple).
# Este hook lo pone en la estructura: al delegar, la memoria relevante llega
# sola, ANTES de que el encargo se ejecute.
#
# NO bloquea: inyecta contexto y sale 0. Fail-open ante cualquier error.

set -uo pipefail

DB="$HOME/.engram/engram.db"
[ -f "$DB" ] || exit 0
command -v sqlite3 >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

INPUT="$(cat 2>/dev/null || true)"

# El texto del encargo es `tool_input.prompt`. Se le suma `description` porque
# suele nombrar el dominio en pocas palabras ("el bot pregunta a distributors").
PROMPT="$(printf '%s' "$INPUT" | jq -r '
  [(.tool_input.description // empty), (.tool_input.prompt // empty)] | join(" ")
' 2>/dev/null || true)"
CWD="$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)"
[ -n "$PROMPT" ] || exit 0

PROJECT="$(basename "${CWD:-$PWD}" 2>/dev/null || echo "")"

[ "${#PROMPT}" -ge 40 ] || exit 0

# Mismas keywords que el hook hermano. Se agregan a las stopwords las palabras
# que abundan en un encargo pero no dicen nada del dominio ("verificá", "tests",
# "commit"): sin esto el recall trae memorias de proceso en vez de decisiones.
KEYWORDS="$(printf '%s' "$PROMPT" \
  | tr '[:upper:]' '[:lower:]' \
  | tr -cs '[:alnum:]áéíóúñü' '\n' \
  | awk 'length($0) >= 5' \
  | grep -vxE 'para|pero|como|cuando|donde|entonces|porque|hacer|hacemos|puede|puedes|podemos|tiene|tienen|estamos|ahora|siempre|mientras|sigue|siguen|trabajando|quiero|necesito|verifica|verificá|verificar|tarea|encargo|archivo|archivos|codigo|código|tests|test|commit|commits|rama|branch|worktree|reporta|reportá|reportar|entregable|deberia|debería|antes|despues|después' \
  | sort -u | head -8 | tr '\n' ' ' | sed 's/ $//')"
[ -n "$KEYWORDS" ] || exit 0

FTS_QUERY="$(printf '%s' "$KEYWORDS" | awk '{for(i=1;i<=NF;i++){printf "%s\"%s\"", (i>1?" OR ":""), $i}}')"
[ -n "$FTS_QUERY" ] || exit 0

# Sólo `decision` y `architecture`: al delegar importa lo que el dueño DECIDIÓ,
# no el registro de un bugfix. Filtrar acá es lo que separa la señal del ruido.
RESULTS="$(sqlite3 -separator '|' "$DB" "
  SELECT o.type, o.title, substr(replace(replace(o.content, char(10), ' '), '|', '/'), 1, 260), substr(o.created_at, 1, 10)
  FROM observations_fts f
  JOIN observations o ON o.id = f.rowid
  WHERE observations_fts MATCH '$(printf '%s' "$FTS_QUERY" | sed "s/'/''/g")'
    AND o.deleted_at IS NULL
    AND o.type IN ('decision','architecture','preference','feedback')
    $( [ -n "$PROJECT" ] && printf "AND o.project = '%s'" "$(printf '%s' "$PROJECT" | sed "s/'/''/g")" )
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
echo "el agente trabaja con lo que le diste, no con lo que el dueño decidió en otra sesión."
exit 0

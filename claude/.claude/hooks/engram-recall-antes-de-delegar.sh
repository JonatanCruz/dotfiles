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
# NO BLOQUEA: inyecta contexto (additionalContext) y sale 0. Fail-open ante
# cualquier error, incluida la falta de jq o de sqlite3.
#
set -uo pipefail

# ── LA LISTA BLANCA YA EXCLUYE; ESTO LA HACE AJUSTABLE ──────────────────────
#
# Este hook ya filtraba por una lista BLANCA (`type IN (...)`), así que un
# `session_summary` nunca entró acá — a diferencia del autorecall, que no
# filtraba nada. Lo que cambia es que la lista deja de estar cableada.
#
# Importa por el mismo motivo medido en el hook hermano: el ranking de Engram es
# `ORDER BY fts.rank` a secas (bm25 sobre title+content), sin boost por tipo. El
# tipo NO reordena nada; sólo saca filas de la competencia con un WHERE. Una
# lista blanca es la forma más fuerte de ese WHERE.
#
# DESACOPLADO: son tipos del esquema de Engram, no de un proyecto. Ajustable sin
# tocar la lógica, p. ej. si tu base usa otro vocabulario de tipos:
#
#   export ENGRAM_DELEGATE_INCLUDE_TYPES="decision,architecture,preference,feedback,pattern"
#
# Vaciarla (="") desactiva el filtro y trae cualquier tipo. Con una base de otro
# proyecto o vacía no hay nada que configurar: si ningún tipo coincide, el hook
# no imprime nada y sale 0, que es su comportamiento normal en la mayoría de los
# turnos.
ENGRAM_DELEGATE_INCLUDE_TYPES="${ENGRAM_DELEGATE_INCLUDE_TYPES-decision,architecture,preference,feedback}"

_engram_include_sql() {
  printf '%s' "${1-}" | tr ',' '\n' | sed "s/^[[:space:]]*//; s/[[:space:]]*$//" \
    | grep -v '^$' | sed "s/'/''/g; s/^/'/; s/$/'/" | paste -sd, - 2>/dev/null || true
}
INCLUDE_LIST="$(_engram_include_sql "$ENGRAM_DELEGATE_INCLUDE_TYPES")"
# Lista vacía ⇒ sin predicado (nunca `IN ()`, que sería un error de sintaxis).
if [ -n "$INCLUDE_LIST" ]; then
  TYPE_FILTER="AND o.type IN ($INCLUDE_LIST)"
else
  TYPE_FILTER=""
fi

DB="$HOME/.engram/engram.db"
[ -f "$DB" ] || exit 0
command -v sqlite3 >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

INPUT="$(cat 2>/dev/null || true)"

# El texto del encargo es `tool_input.prompt`. Se le suma `description` porque
# suele nombrar el dominio en pocas palabras ("el servicio X consulta a Y").
PROMPT="$(printf '%s' "$INPUT" | jq -r '
  [(.tool_input.description // empty), (.tool_input.prompt // empty)] | join(" ")
' 2>/dev/null || true)"
[ -n "$PROMPT" ] || exit 0
CWD="$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)"

# SOLO decisiones de ESTE proyecto (ver lib/engram-proyecto.sh): las de otro repo
# en un encargo lo contaminan con un dominio que no es el suyo.
# shellcheck source=lib/engram-proyecto.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib/engram-proyecto.sh" 2>/dev/null || exit 0
PROYECTO_WHERE="$(engram_proyecto_where "${CWD:-$PWD}")"
[ -n "$PROYECTO_WHERE" ] || exit 0


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
    AND $PROYECTO_WHERE
    $TYPE_FILTER
  ORDER BY rank
  LIMIT 4;
" 2>/dev/null || true)"

[ -n "$RESULTS" ] || exit 0

# En PreToolUse el stdout plano con exit 0 sólo va al log de depuración: el
# modelo no lo ve. Para que llegue hay que emitirlo como `additionalContext`
# (code.claude.com/docs/en/hooks, "Add context for Claude"). El JSON se arma con
# `jq --arg`, nunca concatenando: los títulos de las memorias traen comillas.
LINEAS="$(printf '%s\n' "$RESULTS" | while IFS='|' read -r TYPE TITLE EXCERPT DATE; do
  printf -- '- [%s·%s] %s — %s…\n' "$DATE" "$TYPE" "$TITLE" "$EXCERPT"
done)"
MENSAJE="🧠 ANTES DE DELEGAR — decisiones ya tomadas que matchean este encargo:
$LINEAS

Si alguna CONTRADICE el encargo que estás por lanzar, corregí el encargo ANTES de mandarlo:
el agente trabaja con lo que le diste, no con lo que el dueño decidió en otra sesión."

jq -n --arg ctx "$MENSAJE" \
  '{hookSpecificOutput: {hookEventName: "PreToolUse", additionalContext: $ctx}}' 2>/dev/null || true
exit 0

#!/usr/bin/env bash
# engram-autorecall.sh — UserPromptSubmit hook
#
# PROBLEMA QUE RESUELVE (2026-07-13, feedback del dueño): las memorias de Engram
# existen pero no se consultan en el momento de actuar — el agente afirma desde
# memoria stale (una cifra vieja) teniendo los datos reales guardados.
# Una instrucción de prosa ("busca antes de opinar") no previene el error
# competente; este hook pone el control en la ESTRUCTURA (Meadows): en cada
# prompt del usuario, consulta el FTS de Engram e inyecta las memorias
# relevantes al contexto del turno. El recall deja de depender de disciplina.
#
# LÍMITE: esto recupera CONTEXTO por coincidencia de palabras. No sirve para reglas
# (una regla tiene que estar presente cuando toca, no cuando el prompt la nombra):
# las reglas van en CLAUDE.md (ver indicacion-del-duenio.sh).
#
# Calibración (2026-10-23, medido sobre prompts reales de una sesión):
#  - las palabras clave salían en orden ALFABÉTICO (`sort -u | head -8`), no por
#    aparición: con prompts largos se perdían las palabras del final;
#  - bastaba UNA palabra en común: "eso es lo mas importante, que ya no descargue todo
#    eso" → {descargue, importante} recuperó una memoria sobre "lo importante" de otro
#    tema;
#  - corría sobre los avisos de tareas en segundo plano, inyectando ruido que entrena a
#    ignorar el bloque.
# Ahora: orden de aparición, mínimo dos palabras clave en común (si el prompt tiene dos
# o más), y nada en avisos del sistema. Si nada pasa el filtro, no inyecta nada.
#
# Fail-open: cualquier error → exit 0 sin output (nunca bloquea el trabajo).

set -uo pipefail

DB="$HOME/.engram/engram.db"
[ -f "$DB" ] || exit 0
command -v sqlite3 >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

# Un solo jq para los dos campos. @sh los entrega como literales entre comillas simples
# (seguro para eval aunque el prompt traiga comillas, $() o saltos de línea; `read -d`
# sobre un pipe lee byte a byte y con prompts largos tardaba más que dos jq). Los saltos
# finales se quitan en jq, igual que hacía la sustitución $(...) anterior (en bash,
# ${x%"${x##*[!$'\n']}"} es cuadrático y costaba ~50 ms con prompts largos).
PROMPT="" CWD=""
eval "$(jq -r '@sh "PROMPT=\(.prompt // "" | tostring | sub("\n+\\z"; "")) CWD=\(.cwd // "" | tostring | sub("\n+\\z"; ""))"' 2>/dev/null)" 2>/dev/null || exit 0
[ -n "$PROMPT" ] || exit 0

# Avisos del sistema (resultados de agentes/shells en segundo plano): no son del dueño.
case "$PROMPT" in
  *"<task-notification>"*|*"SYSTEM NOTIFICATION"*) exit 0 ;;
esac

# Proyecto = basename del cwd (convención de mem_session_start)
PROJECT="$(basename "${CWD:-$PWD}" 2>/dev/null || echo "")"

# Prompts muy cortos (acks tipo "ok", "sí") no ameritan recall
[ "${#PROMPT}" -ge 15 ] || exit 0

# Palabras clave: minúsculas, alfanuméricos, >=5 letras o con dígitos (números de PR,
# issue), sin stopwords, únicas EN ORDEN DE APARICIÓN, hasta 8.
KEYWORDS="$(printf '%s' "$PROMPT" \
  | tr '[:upper:]' '[:lower:]' \
  | tr -cs '[:alnum:]áéíóúñü' '\n' \
  | awk 'length($0) >= 5 || ($0 ~ /[0-9]/ && length($0) >= 3)' \
  | grep -vxE 'para|pero|como|cuando|donde|entonces|porque|hacer|hacemos|puede|puedes|podemos|tiene|tienen|estamos|ahora|siempre|mientras|sigue|siguen|trabajando|quiero|necesito|todos|todas|todo|desde|hasta|sobre|entre|antes|despues|después|también|tambien|esto|esta|este|estos|estas|algo|nada|bien|mejor|hacia|cual|cuál|cuales|cuáles|porqué|ademas|además|creiste|hiciste|aquí|aqui|ahí|alla|allá|mucho|mucha|muchos|muchas|otra|otro|otros|otras' \
  | awk '!visto[$0]++' | head -8 | tr '\n' ' ' | sed 's/ $//')"
[ -n "$KEYWORDS" ] || exit 0
NKW="$(printf '%s' "$KEYWORDS" | wc -w)"
MIN=1; [ "$NKW" -ge 2 ] && MIN=2

# Query FTS5: OR de keywords, escapadas como frases entre comillas dobles
FTS_QUERY="$(printf '%s' "$KEYWORDS" | awk '{for(i=1;i<=NF;i++){printf "%s\"%s\"", (i>1?" OR ":""), $i}}')"
[ -n "$FTS_QUERY" ] || exit 0

# UNA sola apertura de la base para todo (antes eran 2 + una por palabra clave, ~10
# procesos sqlite3 por prompt). Cada fila lleva una etiqueta en la 1.ª columna:
#   C|…  candidatos (FTS, ORDER BY rank LIMIT 25)
#   T|n  total de memorias vivas del proyecto (base del IDF)
#   D|i|n  en cuántas memorias aparece la palabra clave i (IDF)
# Peso de cada palabra = qué tan rara es en las memorias del proyecto (IDF): una
# palabra que aparece en un tercio de las memorias ("staging") casi no pesa; una que
# aparece en pocas, sí; la que está en más del 15% no cuenta. Si el proyecto no
# resuelve, el total sale de todas.
# `.timeout`: si otra sesión está escribiendo, espera como mucho 1 s al lock en vez de
# fallar al instante o colgar el prompt. sqlite3 corta en el primer error, así que un
# fallo en los candidatos o en el total deja la salida vacía (fail-open, como antes).
sqlq() { printf '%s' "$1" | sed "s/'/''/g"; }
SQL_PROY="$( [ -n "$PROJECT" ] && printf "AND o.project = '%s'" "$(sqlq "$PROJECT")" )"
SQL="SELECT 'C', o.type, o.title, substr(replace(replace(o.content, char(10), ' '), '|', '/'), 1, 220), substr(o.created_at, 1, 10),
         lower(replace(replace(o.title || ' ' || o.content, char(10), ' '), '|', '/'))
  FROM observations_fts f
  JOIN observations o ON o.id = f.rowid
  WHERE observations_fts MATCH '$(sqlq "$FTS_QUERY")'
    AND o.deleted_at IS NULL
    $SQL_PROY
  ORDER BY rank
  LIMIT 25;
SELECT 'T', count(*) FROM observations o WHERE o.deleted_at IS NULL $SQL_PROY;"
i=0
for w in $KEYWORDS; do
  i=$((i + 1))
  SQL="$SQL
SELECT 'D', $i, count(*) FROM observations_fts f JOIN observations o ON o.id = f.rowid
  WHERE observations_fts MATCH '\"$(sqlq "$w")\"' AND o.deleted_at IS NULL $SQL_PROY;"
done
SALIDA="$(sqlite3 -cmd '.timeout 1000' -separator '|' "$DB" "$SQL" 2>/dev/null || true)"

# Separar secciones. La fila T marca el fin de los candidatos (un título con salto de
# línea seguiría saliendo tal cual, como antes).
CANDIDATOS="$(printf '%s\n' "$SALIDA" | awk '/^T\|[0-9]+$/ { exit } { sub(/^C\|/, ""); print }')"
[ -n "$CANDIDATOS" ] || exit 0
TOTAL="$(printf '%s\n' "$SALIDA" | awk '/^T\|[0-9]+$/ { print substr($0, 3); exit }')"
[ "${TOTAL:-0}" -gt 0 ] 2>/dev/null || exit 0
DF=()
while IFS='|' read -r idx n; do
  [ -n "$idx" ] && DF[idx]="$n"
done < <(printf '%s\n' "$SALIDA" | awk 'f && sub(/^D\|/, "") { print } /^T\|[0-9]+$/ { f = 1 }')
PESOS=""
i=0
for w in $KEYWORDS; do
  i=$((i + 1))
  PESOS="$PESOS $w:${DF[i]:-0}"
done

# Filtro de relevancia: al menos MIN palabras clave distintas en título+contenido Y
# suma de pesos >= UMBRAL (~dos palabras que están en menos del 3% de las memorias).
# Se compara por PALABRA COMPLETA y sin acentos ("corra" no es "correo"; "vinculacion"
# sí es "vinculación"). Las líneas normalizadas sólo deciden; se imprime la original.
UMBRAL=7
sinacento() { iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null || cat; }
PESOS_N="$(printf '%s' "$PESOS" | sinacento)"
ELEGIDAS="$(printf '%s\n' "$CANDIDATOS" | sinacento | awk -F'|' -v pesos="$PESOS_N" -v total="$TOTAL" -v min="$MIN" -v umbral="$UMBRAL" '
  BEGIN { n = split(pesos, p, " "); for (i = 1; i <= n; i++) { split(p[i], kv, ":"); k[i] = kv[1]; w[i] = (kv[2] > total * 0.15) ? 0 : log(total / (kv[2] + 1)) } }
  { t = " " tolower($5) " "; gsub(/[^a-z0-9]+/, " ", t); hits = 0; score = 0
    for (i = 1; i <= n; i++) if (index(t, " " k[i] " ") > 0) { hits++; score += w[i] }
    if (hits >= min && score >= umbral && shown < 4) { print NR; shown++ } }')"
[ -n "$ELEGIDAS" ] || exit 0
RESULTS="$(printf '%s\n' "$CANDIDATOS" | awk -F'|' -v sel="$(printf '%s' "$ELEGIDAS" | tr '\n' ' ')" '
  BEGIN { n = split(sel, s, " "); for (i = 1; i <= n; i++) ok[s[i]] = 1 }
  ok[NR] { print $1 "|" $2 "|" $3 "|" $4 }')"
[ -n "$RESULTS" ] || exit 0

echo "📚 ENGRAM AUTO-RECALL (contexto por coincidencia de palabras, NO reglas — las reglas están en CLAUDE.md; VERIFICA vigencia antes de usarlo como evidencia):"
printf '%s\n' "$RESULTS" | while IFS='|' read -r TYPE TITLE EXCERPT DATE; do
  echo "- [$DATE·$TYPE] $TITLE — $EXCERPT…"
done
exit 0

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

# Un solo jq. @sh los entrega como literales entre comillas simples
# (seguro para eval aunque el prompt traiga comillas, $() o saltos de línea; `read -d`
# sobre un pipe lee byte a byte y con prompts largos tardaba más que dos jq). Los saltos
# finales se quitan en jq, igual que hacía la sustitución $(...) anterior (en bash,
# ${x%"${x##*[!$'\n']}"} es cuadrático y costaba ~50 ms con prompts largos).
PROMPT="" CWD=""
eval "$(jq -r '@sh "PROMPT=\(.prompt // "" | tostring | sub("\n+\\z"; "")) CWD=\(.cwd // "" | tostring)"' 2>/dev/null)" 2>/dev/null || exit 0
[ -n "$PROMPT" ] || exit 0

# Avisos del sistema (resultados de agentes/shells en segundo plano): no son del dueño.
case "$PROMPT" in
  *"<task-notification>"*|*"SYSTEM NOTIFICATION"*) exit 0 ;;
esac

# SOLO memorias de ESTE proyecto: las de otro repo son contaminación aunque
# matcheen las palabras. El proyecto se deduce (repo principal, sus worktrees y
# los alias que el repo declare): ver lib/engram-proyecto.sh. Sin la biblioteca
# o sin proyecto deducible no se inyecta nada (fail-open: no hay recall).
# shellcheck source=lib/engram-proyecto.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib/engram-proyecto.sh" 2>/dev/null || exit 0
PROYECTO_WHERE="$(engram_proyecto_where "${CWD:-$PWD}")"
[ -n "$PROYECTO_WHERE" ] || exit 0

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
#   T|n  total de memorias vivas recordables del proyecto (base del IDF)
#   D|i|n  en cuántas memorias aparece la palabra clave i (IDF)
# Peso de cada palabra = qué tan rara es en las memorias del proyecto (IDF): una
# palabra que aparece en un tercio de las memorias ("staging") casi no pesa; una que
# aparece en pocas, sí; la que está en más del 15% no cuenta.
# `.timeout`: si otra sesión está escribiendo, espera como mucho 1 s al lock en vez de
# fallar al instante o colgar el prompt. sqlite3 corta en el primer error, así que un
# fallo en los candidatos o en el total deja la salida vacía (fail-open, como antes).
sqlq() { printf '%s' "$1" | sed "s/'/''/g"; }
SQL_TIPOS="$TYPE_FILTER AND $PROYECTO_WHERE"
SQL="SELECT 'C', replace(replace(replace(o.type, char(10), ' '), char(13), ' '), '|', '/'),
         replace(replace(replace(o.title, char(10), ' '), char(13), ' '), '|', '/'),
         substr(replace(replace(o.content, char(10), ' '), '|', '/'), 1, 220), replace(substr(o.created_at, 1, 10), char(10), ' '),
         lower(replace(replace(o.title || ' ' || o.content, char(10), ' '), '|', '/'))
  FROM observations_fts f
  JOIN observations o ON o.id = f.rowid
  WHERE observations_fts MATCH '$(sqlq "$FTS_QUERY")'
    AND o.deleted_at IS NULL
    $SQL_TIPOS
  ORDER BY rank
  LIMIT 25;
SELECT 'T', count(*) FROM observations o WHERE o.deleted_at IS NULL $SQL_TIPOS;"
i=0
for w in $KEYWORDS; do
  i=$((i + 1))
  SQL="$SQL
SELECT 'D', $i, count(*) FROM observations_fts f JOIN observations o ON o.id = f.rowid
  WHERE observations_fts MATCH '\"$(sqlq "$w")\"' AND o.deleted_at IS NULL $SQL_TIPOS;"
done
SALIDA="$(sqlite3 -cmd '.timeout 1000' -separator '|' "$DB" "$SQL" 2>/dev/null || true)"

# Separar secciones. La fila T marca el fin de los candidatos. Ningún dato almacenado
# puede falsificar una fila T o D: type, title y created_at llegan sin saltos de línea
# (arriba, en el SQL) y content ya venía aplanado.
CANDIDATOS="$(printf '%s\n' "$SALIDA" | awk '/^T\|[0-9]+$/ { exit } { sub(/^C\|/, ""); print }')"
[ -n "$CANDIDATOS" ] || exit 0
TOTAL="$(printf '%s\n' "$SALIDA" | awk '/^T\|[0-9]+$/ { print substr($0, 3); exit }')"
[ "${TOTAL:-0}" -gt 0 ] 2>/dev/null || exit 0
DF=()
while IFS='|' read -r idx n; do
  # El subíndice de un array indexado se evalúa como aritmética: `x[$(cmd)]` ejecutaría
  # cmd. Solo se aceptan números, aunque las filas D las genere este mismo SQL.
  [[ "$idx" =~ ^[0-9]+$ && "$n" =~ ^[0-9]+$ ]] || continue
  DF[idx]="$n"
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

# ⚠️ EL ENCABEZADO IMPORTA, y el anterior causaba el daño que venía a evitar.
#
# Decía: "son contexto, NO medición". Medido el 2026-09-19: el agente lo leyó
# como "esto no es evidencia, seguí de largo" y las ignoró sistemáticamente. El
# caso testigo: una memoria del 05-sep decía textual *"culpar al SyncJob
# fue FALSO"*, llegó con ese encabezado, y el agente armó igual su diagnóstico
# sobre el SyncJob — repitiendo el error exacto que la memoria
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
echo "   · Son contexto por coincidencia de palabras, NO reglas: las reglas del dueño están en CLAUDE.md."
printf '%s\n' "$RESULTS" | while IFS='|' read -r TYPE TITLE EXCERPT DATE; do
  echo "- [$DATE·$TYPE] $TITLE — $EXCERPT…"
done
exit 0

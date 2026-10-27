#!/usr/bin/env bash
# PreToolUse (Bash) — bloquea la búsqueda de CÓDIGO con grep/sed por Bash: un `grep`
# dentro de Bash esquiva los gates de Grep|Glob, y grep sobre código no ve una
# dependencia inyectada ni el docstring tres líneas arriba del match. Falla cerrado:
# un aviso sólo frena al que ya sabe que se equivoca.
#
# ALCANCE — bloquea sólo búsquedas recursivas o por comodín sobre CÓDIGO. Logs, JSON,
# YAML, configs, salidas de CLIs y UN archivo ya identificado pasan: bloquear de más
# entrena a saltarse el gate. La línea es UNO vs MUCHOS, no el binario.
#
# QUÉ ES CÓDIGO, sin nada escrito para ningún repo:
#   · un ARCHIVO decide por su extensión (un `.log` bajo `src/` no es código);
#   · un DIRECTORIO es código si lo contiene, y se MIDE: `git ls-files -- <dir>`
#     dentro de un repo, `find <dir> -maxdepth 3` fuera, con `timeout 2` y 200
#     archivos. Si no se puede medir, no abre: bloquea y dice por qué;
#   · un PATRÓN de búsqueda nunca es una ruta (`grep -rn services docs/` pasa);
#   · lo que el índice NUNCA cubre no es código para este gate: mandar ahí al
#     índice es un callejón sin salida (ver DIRS_FUERA_DEL_INDICE).
# Las extensiones son un valor por defecto amplio; cada proyecto las AMPLÍA (y suma
# directorios) en `.claude/hooks.json`, nunca las quita (ver lib/config.sh). Shell
# queda fuera por defecto: vive mezclado con configuración; quien lo quiera, lo suma.
#
# NO HAY OVERRIDE: una variable que el agente antepone se vuelve atajo sistemático.
# Si ninguna salida legítima cubre un caso real, lo decide el dueño.
#
#   stdin: JSON { tool_input: { command }, cwd }  ·  exit 0 permite · exit 2 bloquea

set -uo pipefail

# Sin su normalizador el gate no puede decidir: BLOQUEA. La configuración, en
# cambio, sólo suma: sin ella quedan los valores por defecto.
_dir="$(dirname "${BASH_SOURCE[0]}")"
_lib="$_dir/lib/normalizar-comando.sh"
# shellcheck source=lib/normalizar-comando.sh
if ! . "$_lib" 2>/dev/null || ! command -v normalizar_ejecutable >/dev/null 2>&1; then
  printf '\xf0\x9f\x9b\x91 BLOQUEADO (redirect-code-search-to-mcp): no se pudo cargar %s.\n' "$_lib" >&2
  printf '   Un gate sin su normalizador no puede decidir, y ante la duda no se abre.\n' >&2
  exit 2
fi
# shellcheck source=lib/config.sh
. "$_dir/lib/config.sh" 2>/dev/null || true
command -v config_timeout >/dev/null 2>&1 || config_timeout() { shift; "$@"; }

payload="$(cat)"
cmd="$(extraer_comando "$payload")"
if command -v jq >/dev/null 2>&1; then
  cwd="$(printf '%s' "$payload" | jq -r '.cwd // empty' 2>/dev/null || true)"
else
  cwd="$(printf '%s' "$payload" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"\\]*\)".*/\1/p' | head -1)"
fi
[ -z "$cmd" ] && exit 0
[ -d "${cwd:-}" ] || cwd="${CLAUDE_PROJECT_DIR:-$PWD}"
[ -d "$cwd" ] || cwd="$PWD"

# NORMALIZACIÓN, en este orden (el orden es parte del control):
# 1) comillas vacías: `gr''ep` ES `grep`; después de borrar strings ya no se ve.
cmd="$(printf '%s' "$cmd" | sed -E "s/''//g; s/\"\"//g")"
# 2) el string de un intérprete (`bash -c '…'`, `eval`) es CÓDIGO, no texto.
if printf '%s' "$cmd" | grep -qE '(^|[|;&`]|&&|\|\||\$\()[[:space:]]*(eval|(env[[:space:]]+)?(ba|z|k|da)?sh([[:space:]]+-[^[:space:]]+)*[[:space:]]+-[a-zA-Z]*c)\b'; then
  cmd="$(printf '%s' "$cmd" | tr -d "\"'")"
fi
# 3) `G=grep; $G -rn …`: sólo se expanden nombres de buscadores y lectores.
for _v in $(printf '%s' "$cmd" \
    | grep -oE '(^|[|;&[:space:]])[A-Za-z_][A-Za-z0-9_]*=(grep|rg|ag|ack|sed|awk|cat|head|tail|bat|less|more|nl)\b' \
    | sed -E 's/^[|;&[:space:]]+//'); do
  _name="${_v%%=*}"; _val="${_v#*=}"
  cmd="$(printf '%s' "$cmd" | sed -E "s/\\\$\{?${_name}\}?/${_val}/g")"
done
unset _v _name _val
# 4) EJECUTAR ≠ NOMBRAR: el argumento de echo/printf/git commit -m es texto.
if printf '%s' "$cmd" | grep -qE '(^|[|;&]|&&|\|\|)[[:space:]]*(echo|printf)\b' \
   || printf '%s' "$cmd" | grep -qE 'git[[:space:]]+(commit|tag)\b[^|;&]*-[a-zA-Z]*m\b'; then
  cmd="$(printf '%s' "$cmd" | sed -E "s/'[^']*'//g; s/\"[^\"]*\"//g")"
fi
# 5) el cuerpo de un heredoc es texto, salvo que vaya a un intérprete.
if ! printf '%s' "$cmd" | grep -qE '(^|[|;&]|&&|\|\|)[[:space:]]*((ba|z|k|da)?sh|python[0-9.]*|node|perl|ruby)\b[^|;&]*<<'; then
  cmd="$(normalizar_heredoc "$cmd")"
  [ -z "${cmd//[[:space:]]/}" ] && exit 0
fi

log="${HOME}/.claude/logs/cbm-blocked.log"
registrar() {
  mkdir -p "$(dirname "$log")" 2>/dev/null
  printf '%s\t%s\n' "$(date -Is)" "$(printf '%s' "$cmd" | head -c 300)" >> "$log" 2>/dev/null
}

# UNA SOLA LISTA de extensiones para todos los chequeos: dos listas divergen.
EXT_DEFECTO='ts tsx js jsx mjs cjs mts cts vue svelte astro
py pyi go rs java kt kts scala groovy clj cljs cljc ex exs erl hrl
rb php swift m mm c h cc cpp cxx hpp hh cs fs fsx vb dart lua zig nim
hs ml mli elm jl r pl pm sol tf tfvars hcl sql prisma graphql proto'
EXT_EXTRA=""
command -v config_extensiones >/dev/null 2>&1 && EXT_EXTRA="$(config_extensiones "$cwd")"
# shellcheck disable=SC2086
EXT_LISTA="$(printf '%s\n' $EXT_DEFECTO $EXT_EXTRA | sort -u | paste -sd'|' -)"
EXT_HINT="\\.($EXT_LISTA)\\b"
# Las regex van en variables: `[[ x =~ a|b ]]` literal no lo parsea zsh.
RE_EXT_FIN="\\.($EXT_LISTA)([^A-Za-z0-9]|\$)"
RE_EXT_LLAVE="\\{([^}]*,)?($EXT_LISTA)[,}]"
RE_EXT_EXACTA="^($EXT_LISTA)\$"
RE_TIENE_EXT='[^.]\.[A-Za-z0-9]{1,12}$'
RE_ALGUNA_EXT='\.[A-Za-z0-9]+$'
RE_GLOB_EXT='^\*\.([A-Za-z0-9]+)$'
RE_GREPS='^(e|f|u)?grep$'
RAIZ="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || true)"
DIRS_CODIGO=()
if command -v config_directorios >/dev/null 2>&1; then
  while IFS= read -r _d; do [ -n "$_d" ] && DIRS_CODIGO+=("$_d"); done < <(config_directorios "$cwd")
fi

# El indexador (codebase-memory, modo full) no entra en estos directorios, a
# cualquier profundidad; `index_repository` los devuelve en `excluded.dirs`. Lo que
# hay dentro se busca con grep. No es configurable: un repo sólo suma restricción.
# Siguiendo enlaces (`grep -R`, `rg -L`) la exención no vale: un enlace dentro de
# uno de ellos lleva a código que sí está indexado.
DIRS_FUERA_DEL_INDICE='.git .claude .claude-worktrees .worktrees .serena node_modules'
_d="${DIRS_FUERA_DEL_INDICE//./\\.}"
RE_FUERA_DEL_INDICE="(^|/)(${_d// /|})(/|\$)"
unset _d
DEREF=0

# fuera_del_indice <ruta> → 0 si, ya resuelta, cae dentro de un directorio que el
# índice no cubre. Cuenta lo que queda DEBAJO de la raíz de su repo: un repo que
# vive dentro de ~/.claude sí se indexa.
fuera_del_indice() {
  local abs real d raiz
  [ "$DEREF" = 0 ] || return 1
  case "$1" in *'$'* | *'`'*) return 1 ;; esac
  abs="$(ruta_abs "$1")"; real="$abs"
  if [ -e "$abs" ] || [ -L "$abs" ]; then
    real="$(realpath -- "$abs" 2>/dev/null || readlink -f -- "$abs" 2>/dev/null)"
    [ -n "$real" ] || return 1
  fi
  d="$real"; while [ -n "$d" ] && [ ! -d "$d" ]; do d="${d%/*}"; done
  raiz="$(git -C "${d:-/}" rev-parse --show-toplevel 2>/dev/null || true)"
  [ -n "$raiz" ] && [[ "$real" == "$raiz/"* ]] && real="${real#"$raiz"}"
  [[ "$real" =~ $RE_FUERA_DEL_INDICE ]]
}

tiene_ext() { [[ "${1##*/}" =~ $RE_TIENE_EXT ]]; }
minus() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }
glob_de_codigo() { # <glob> → 0 si pide extensiones de código (`*.ts`, `*.{ts,js}`)
  local g; g="$(minus "$1")"
  [[ "$g" =~ $RE_EXT_FIN ]] || [[ "$g" =~ $RE_EXT_LLAVE ]]
}

ruta_abs() { # <ruta> → absoluta y normalizada respecto de $cwd, sin tocar disco
  local p="$1" parte out=""
  # shellcheck disable=SC2088  # se compara el `~` literal que escribió el agente
  case "$p" in "~") p="$HOME" ;; "~/"*) p="$HOME/${p#\~/}" ;; esac
  [[ "$p" == /* ]] || p="$cwd/$p"
  local -a partes pila=()
  IFS=/ read -r -a partes <<<"$p"
  for parte in ${partes[@]+"${partes[@]}"}; do
    case "$parte" in
      '' | .) ;;
      ..) [ "${#pila[@]}" -gt 0 ] && unset 'pila[${#pila[@]}-1]' ;;
      *) pila+=("$parte") ;;
    esac
  done
  for parte in ${pila[@]+"${pila[@]}"}; do out="$out/$parte"; done
  printf '%s' "${out:-/}"
}

MEDIDA_RUTA=""
# medir_dir <ruta> → 0 contiene código · 1 no · 2 no se pudo medir.
# git es la medida rápida, pero sólo cuenta lo que git ve: un symlink, un
# directorio ignorado o un submódulo salen "vacíos". Por eso la ruta se resuelve
# antes de medir y, si git no encuentra código, se CONFIRMA con find (que ve los
# ignorados). Lo que no se puede medir no abre.
medir_dir() {
  local ruta="$1" abs real lista rc d rel
  MEDIDA_RUTA="$ruta"
  case "$ruta" in *'$'* | *'`'*) return 2 ;; esac
  abs="$(ruta_abs "$ruta")"; real="$abs"
  if [ -e "$abs" ] || [ -L "$abs" ]; then
    real="$(realpath -- "$abs" 2>/dev/null || readlink -f -- "$abs" 2>/dev/null)"
    [ -n "$real" ] || return 2
  fi
  for d in ${DIRS_CODIGO[@]+"${DIRS_CODIGO[@]}"}; do
    for rel in "$abs" "$real"; do
      if [ "$rel" = "$RAIZ/$d" ] || [[ "$rel" == "$RAIZ/$d/"* ]] || [[ "$RAIZ/$d" == "$rel/"* ]]; then return 0; fi
    done
  done
  # Lo que el índice no cubre se excluye EN la consulta, no después: filtrar una
  # muestra ya recortada deja fuera el código que sí está indexado.
  local -a fuera_git=() fuera_find=(-name .git)
  if [ "$DEREF" = 0 ]; then
    for d in $DIRS_FUERA_DEL_INDICE; do
      fuera_git+=(":(exclude,glob)**/$d/**"); fuera_find+=(-o -name "$d")
    done
  fi
  if [ -n "$RAIZ" ] && { [ "$real" = "$RAIZ" ] || [[ "$real" == "$RAIZ/"* ]]; }; then
    rel="${real#"$RAIZ"}"; rel="${rel#/}"
    lista="$(config_timeout 2 git -C "$RAIZ" ls-files -co --exclude-standard -- "${rel:-.}" ${fuera_git[@]+"${fuera_git[@]}"} 2>/dev/null \
      | grep -m1 -iE "\\.($EXT_LISTA)\$"; exit "${PIPESTATUS[0]}")"
    rc=$?
    # 141: grep ya encontró código y cerró el pipe. Otro error (124 = timeout): no se midió.
    [ "$rc" = 0 ] || [ "$rc" = 141 ] || return 2
    [ -n "$lista" ] && return 0
  fi
  [ -e "$real" ] || return 1
  lista="$(config_timeout 2 find "$real" -maxdepth 3 \( "${fuera_find[@]}" \) -prune -o -type f -print 2>/dev/null \
    | grep -m1 -iE "\\.($EXT_LISTA)\$"; exit "${PIPESTATUS[0]}")"
  # find sale 1 si algún subdirectorio no se pudo leer: la lista parcial vale.
  [ "$?" = 124 ] && return 2
  [ -n "$lista" ]
}

# clasificar <palabra> <recursivo 0|1> → 0 código · 1 no · 2 no se pudo medir.
clasificar() {
  local t="$1" rec="$2" pref
  if [[ "$t" == *[*?[]* ]]; then
    pref="${t%%[*?[]*}"; pref="${pref%/*}"
    [[ "$t" == */* ]] || pref="."
    fuera_del_indice "${pref:-/}" && return 1
    glob_de_codigo "${t##*/}" && return 0
    [[ "${t##*/}" =~ $RE_ALGUNA_EXT ]] && return 1
    medir_dir "${pref:-/}"; return $?
  fi
  [ "$rec" = 1 ] || return 1
  [ -f "$(ruta_abs "$t")" ] && return 1
  tiene_ext "$t" && [ ! -d "$(ruta_abs "$t")" ] && return 1
  fuera_del_indice "$t" && return 1
  medir_dir "$t"
}

# Volcado de contenido EN VOLUMEN con otros binarios (find -exec, xargs, rglob,
# awk/cat sobre comodines, bucles, llaves). Listar NOMBRES no entra.
READ_MANY='-exec[[:space:]]+(cat|head|tail|grep)\b'
READ_MANY="$READ_MANY"'|\|[[:space:]]*xargs[[:space:]]+([^|;&]*[[:space:]])?(cat|head|grep)\b'
READ_MANY="$READ_MANY"'|rglob|iglob|os\.walk|Files\.walk|glob\.glob'
READ_MANY="$READ_MANY"'|(awk|perl)[[:space:]]+[^|;&]*/[^/]*/[^|;&]*\*'
READ_MANY="$READ_MANY"'|(read_text\(\)|readFileSync|\.read\(\))[^|;&]*\*'
READ_MANY="$READ_MANY"'|\*\.[A-Za-z0-9]+\b[^|;&]*(read_text|readFileSync|\.read\(\))'
READ_MANY="$READ_MANY"'|for[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]]+in[[:space:]][^;]*\*'
READ_MANY="$READ_MANY"'|(cat|head|tail|bat|less|more|nl)[[:space:]][^|;&]*\{[^}]*,[^}]*\}'
READ_MANY="$READ_MANY"'|(cat|head|tail|bat|less|more|nl)[[:space:]][^|;&]*\*'

# Palabras del shell, una por línea y sin comillas. \036 separa comandos y \037
# marca que la palabra siguiente es el destino de una redirección.
tokenizar() {
  printf '%s' "$1" | awk '
  BEGIN { RS = "\001"; SEP = "\036"; RED = "\037" }
  function flush() { if (tok != "" || had) print tok; tok = ""; had = 0 }
  {
    s = $0; n = length(s); tok = ""; had = 0; q = ""
    for (i = 1; i <= n; i++) {
      c = substr(s, i, 1)
      if (q != "") {
        if (c == q) { q = ""; continue }
        if (q == "\"" && c == "\\" && i < n) { i++; c = substr(s, i, 1) }
        if (c == "\n") c = " "
        tok = tok c; continue
      }
      if (c == "\047" || c == "\"") { q = c; had = 1; continue }
      if (c == "\\" && i < n) { i++; c = substr(s, i, 1); if (c == "\n") { flush(); continue } tok = tok c; continue }
      if (c == " " || c == "\t") { flush(); continue }
      if (c == "\n" || c == ";" || c == "|" || c == "&" || c == "(" || c == ")" || c == "`") { flush(); print SEP; continue }
      if (c == ">" || c == "<") {
        if (tok ~ /^[0-9]+$/) { tok = ""; had = 0 } else flush()
        while (i < n && index("<>&", substr(s, i + 1, 1)) > 0) i++
        if (substr(s, i, 1) == "&" && i < n && substr(s, i + 1, 1) ~ /[0-9-]/) {
          while (i < n && substr(s, i + 1, 1) ~ /[0-9-]/) i++
          continue
        }
        print RED; continue
      }
      tok = tok c
    }
    flush()
  }'
}
SEP=$'\036'; RED=$'\037'
TOKENS=()
while IFS= read -r _t; do TOKENS+=("$_t"); done < <(tokenizar "$cmd")

BLOQUEO=""; BLOQUEO_RUTA=""
valor_grep=' -e -f -m -A -B -C -d -D --regexp --file --max-count --after-context --before-context --context --directories --devices --include --exclude --exclude-dir --exclude-from --label --binary-files '
valor_rg=' -e -f -g -t -T -m -A -B -C -j -M -r -E --regexp --file --glob --iglob --type --type-not --max-count --after-context --before-context --context --threads --max-columns --replace --encoding --max-depth --maxdepth --max-filesize --type-add --pre --pre-glob --sort --sortr --colors --color --path-separator --context-separator --field-match-separator --engine --ignore-file --dfa-size-limit --regex-size-limit '
valor_otros=' -e -f -m -A -B -C -g -G -t -T -j -M --regexp --file --max-count --after-context --before-context --context --ignore --ignore-dir --file-search-regex --depth --type '
valor_git=' -e -f -m -A -B -C -O --max-depth --threads --open-files-in-pager '
valor_sed=' -e -f -l --expression --file --line-length '
valor_awk=' -f -v -F --file --assign --field-separator '
# Un filtro (--include, -g, -t) sólo exime si TODOS los positivos son de esto:
# una extensión conocida de no-código, sin comodines en la extensión.
EXT_NOCODIGO=' md markdown mdx txt rst adoc log json jsonl yaml yml toml ini conf cfg csv tsv xml html htm css scss sass less svg lock env properties '
LARGAS_GREP=' --extended-regexp --fixed-strings --basic-regexp --perl-regexp --regexp --file --ignore-case --no-ignore-case --word-regexp --line-regexp --null-data --no-messages --invert-match --version --help --max-count --byte-offset --line-number --no-line-number --line-buffered --with-filename --no-filename --label --only-matching --quiet --silent --binary-files --text --directories --devices --recursive --dereference-recursive --include --exclude --exclude-from --exclude-dir --files-without-match --files-with-matches --count --initial-tab --null --before-context --after-context --context --group-separator --no-group-separator --color --colour --binary '
# larga_grep <--nombre> → la opción completa. GNU grep acepta cualquier prefijo
# único (`--rec` = --recursive); uno ambiguo o desconocido no se puede saber qué
# hace, y se trata como recursivo (falla cerrado).
larga_grep() {
  local o c=0 completa=""
  case "$LARGAS_GREP" in *" $1 "*) printf '%s' "$1"; return 0 ;; esac
  for o in $LARGAS_GREP; do
    case "$o" in "$1"*) c=$((c+1)); completa="$o" ;; esac
  done
  [ "$c" = 1 ] && printf '%s' "$completa"
}
TIPOS_CODIGO=' rust python ruby kotlin csharp cpp typescript javascript java swift scala elixir haskell ocaml erlang clojure dart lua php perl sql terraform protobuf go golang c objc '

opcion_con_valor() { # <herramienta> <opción> <valor>: aplica su efecto
  case "$2" in
    -e | -f | --regexp | --file | --expression) [[ "$1" != awk* ]] || [ "$2" = -f ] && patron_dado=1 ;;
    --include | --glob | --iglob) incluye+=("$3"); recursivo=1 ;;
    -g) [[ "$1" == rg || "$1" == ripgrep ]] && incluye+=("$3") ;;
    -t | --type) [[ "$1" != sed && "$1" != awk ]] && incluye+=("tipo:$3") ;;
    -d | --directories) [[ "$3" == rec* ]] && recursivo=1 ;;
    # Redefinen qué archivos o cómo se leen: un filtro ya no dice nada.
    --type-add | --pre | --pre-glob) filtro_dudoso=1 ;;
  esac
}

# analizar_busqueda <herramienta> <args…>: deja BLOQUEO si lee código en volumen.
analizar_busqueda() {
  local h="$1"; shift
  local valores a v i k letra resto t rc g es_git=0 git_c="" visto=0 fin=0
  local inc_codigo=0 inc_nocodigo=0
  patron_dado=0; recursivo=0; incluye=(); filtro_dudoso=0; DEREF=0
  local nombre
  local -a objetivos=() args=("$@")
  case "$h" in
    git-grep) valores="$valor_git"; recursivo=1; es_git=1; git_c="${GIT_C:-}" ;;
    grep | egrep | fgrep | ugrep) valores="$valor_grep" ;;
    rg | ripgrep) valores="$valor_rg"; recursivo=1 ;;
    ag | ack | pt | sift) valores="$valor_otros"; recursivo=1 ;;
    sed) valores="$valor_sed" ;;
    awk | gawk | mawk | nawk) valores="$valor_awk" ;;
    *) return 0 ;;
  esac
  for ((i = 0; i < ${#args[@]}; i++)); do
    a="${args[i]}"
    if [ "$fin" = 0 ] && [[ "$a" == -?* ]]; then
      if [ "$a" = "--" ]; then fin=1
      elif [[ "$a" == --* ]]; then
        nombre="${a%%=*}"
        if [[ "$h" =~ $RE_GREPS ]]; then
          nombre="$(larga_grep "$nombre")"
          [ -n "$nombre" ] || { recursivo=1; filtro_dudoso=1; continue; }
        fi
        case "$nombre" in
          --recursive) recursivo=1 ;;
          --dereference-recursive) recursivo=1; DEREF=1 ;;
          --follow) DEREF=1 ;;
        esac
        if [[ "$a" == *=* ]]; then opcion_con_valor "$h" "$nombre" "${a#*=}"
        elif [[ "$valores" == *" $nombre "* ]]; then i=$((i+1)); opcion_con_valor "$h" "$nombre" "${args[i]:-}"; fi
      else
        for ((k = 1; k < ${#a}; k++)); do
          letra="${a:k:1}"; resto="${a:k+1}"
          case "$h:$letra" in grep:[rR] | egrep:[rR] | fgrep:[rR] | ugrep:[rR]) recursivo=1 ;; esac
          case "$h:$letra" in *grep:R | rg:L | ripgrep:L | ag:f) DEREF=1 ;; esac
          if [[ "$valores" == *" -$letra "* ]]; then
            if [ -n "$resto" ]; then v="$resto"; else i=$((i+1)); v="${args[i]:-}"; fi
            opcion_con_valor "$h" "-$letra" "$v"; break
          fi
        done
      fi
      continue
    fi
    # El primer posicional es el PATRÓN (o el programa de sed/awk): nunca una ruta.
    if [ "$patron_dado" = 0 ] && [ "$visto" = 0 ] && { [ "$fin" = 0 ] || [ "$es_git" = 1 ]; }; then
      visto=1; continue
    fi
    objetivos+=("$a")
  done
  if [ "$es_git" = 1 ]; then
    # git grep <patrón> [<revisión>…] [-- <ruta>…]: lo que va antes de `--`, o lo
    # que no existe en disco, es una revisión; la búsqueda cubre el árbol.
    local -a rutas=()
    for t in ${objetivos[@]+"${objetivos[@]}"}; do
      [ -e "$(ruta_abs "${git_c:+$git_c/}$t")" ] || [[ "$t" == *[*?[]* ]] || continue
      rutas+=("${git_c:+$git_c/}$t")
    done
    objetivos=(${rutas[@]+"${rutas[@]}"})
    [ "${#objetivos[@]}" -gt 0 ] || objetivos=("${git_c:-.}")
  fi
  [ "${#objetivos[@]}" -gt 0 ] || [ "$recursivo" = 0 ] || objetivos=(".")
  for g in ${incluye[@]+"${incluye[@]}"}; do
    case "$g" in '!'*) continue ;; esac
    if [[ "$g" == tipo:* ]]; then
      g="$(minus "${g#tipo:}")"
      if [[ "$TIPOS_CODIGO" == *" $g "* ]] || [[ "$g" =~ $RE_EXT_EXACTA ]]; then inc_codigo=1
      elif [[ "$EXT_NOCODIGO" == *" $g "* ]]; then inc_nocodigo=1
      else filtro_dudoso=1
      fi
    elif glob_de_codigo "$g"; then inc_codigo=1
    elif [[ "${g##*/}" =~ $RE_GLOB_EXT ]] && [[ "$EXT_NOCODIGO" == *" $(minus "${BASH_REMATCH[1]}") "* ]]; then inc_nocodigo=1
    else filtro_dudoso=1
    fi
  done
  [ "$filtro_dudoso" = 0 ] || inc_nocodigo=0
  for t in ${objetivos[@]+"${objetivos[@]}"}; do
    [ -n "$t" ] || continue
    fuera_del_indice "$t" && continue
    if [[ "$t" == *[*?[]* ]]; then clasificar "$t" 0; rc=$?
    elif [ "$recursivo" = 1 ] && ! tiene_ext "$t" && [ "$inc_codigo" = 1 ]; then rc=0
    elif [ "$recursivo" = 1 ] && ! tiene_ext "$t" && [ "$inc_nocodigo" = 1 ]; then rc=1
    else clasificar "$t" "$recursivo"; rc=$?
    fi
    case "$rc" in
      0) BLOQUEO="codigo"; BLOQUEO_RUTA="$t"; return 0 ;;
      2) BLOQUEO="nomedible"; BLOQUEO_RUTA="$MEDIDA_RUTA"; return 0 ;;
    esac
  done
}

saltar_envoltorios() { # avanza SEG_I sobre lo que ejecuta al comando siguiente
  local w
  while [ "$SEG_I" -lt "${#SEG[@]}" ]; do
    w="${SEG[SEG_I]}"
    case "$w" in
      '{' | '}' | '!' | do | then | else | elif | if | while | until | time | nohup | exec | builtin | nice | stdbuf | doas | [A-Za-z_]*=*)
        SEG_I=$((SEG_I+1)) ;;
      sudo | env | xargs | timeout)
        SEG_I=$((SEG_I+1))
        while [ "$SEG_I" -lt "${#SEG[@]}" ] && [[ "${SEG[SEG_I]}" == -* || "${SEG[SEG_I]}" == [A-Za-z_]*=* ]]; do
          case "$w:${SEG[SEG_I]}" in
            sudo:-[ug] | env:-u | xargs:-[InPLsdaE] | timeout:-[sk]) SEG_I=$((SEG_I+1)) ;;
          esac
          SEG_I=$((SEG_I+1))
        done
        [ "$w" = timeout ] && SEG_I=$((SEG_I+1)) ;;
      command) [[ "${SEG[SEG_I+1]:-}" == -[vV] ]] && return 1; SEG_I=$((SEG_I+1)) ;;
      *) return 0 ;;
    esac
  done
}

analizar_segmento() {
  [ "${#SEG[@]}" -gt 0 ] || return 0
  SEG_I=0
  saltar_envoltorios || return 0
  [ "$SEG_I" -lt "${#SEG[@]}" ] || return 0
  local h="${SEG[SEG_I]##*/}" j
  if [ "$h" = git ]; then
    j=$((SEG_I+1)); GIT_C=""
    while [ "$j" -lt "${#SEG[@]}" ]; do
      case "${SEG[j]}" in
        -C) GIT_C="${SEG[j+1]:-}"; j=$((j+2)) ;;
        -c) j=$((j+2)) ;;
        -*) j=$((j+1)) ;;
        *) break ;;
      esac
    done
    [ "${SEG[j]:-}" = grep ] && analizar_busqueda git-grep "${SEG[@]:j+1}"
    return 0
  fi
  analizar_busqueda "$h" "${SEG[@]:SEG_I+1}"
}

SEG=(); saltar=0
for tok in ${TOKENS[@]+"${TOKENS[@]}"} "$SEP"; do
  if [ "$tok" = "$SEP" ]; then
    analizar_segmento
    [ -n "$BLOQUEO" ] && break
    SEG=(); saltar=0
  elif [ "$tok" = "$RED" ]; then saltar=1
  elif [ "$saltar" = 1 ]; then saltar=0
  else SEG+=("$tok")
  fi
done

# `find -L`/`-follow` también siguen enlaces.
DEREF=0
printf '%s' "$cmd" | grep -qE '(^|[[:space:]])(-L|-follow|-R|--follow)([[:space:]]|$)' && DEREF=1
if [ -z "$BLOQUEO" ] && printf '%s' "$cmd" | grep -qE -- "$READ_MANY"; then
  if printf '%s' "$cmd" | grep -qE "$EXT_HINT"; then
    BLOQUEO="volumen"
  else
    n=0
    for tok in ${TOKENS[@]+"${TOKENS[@]}"}; do
      case "$tok" in "$SEP" | "$RED" | -* | *=*) continue ;; esac
      [[ "$tok" == *[*?[/]* ]] || [ -d "$(ruta_abs "$tok")" ] || continue
      n=$((n+1)); [ "$n" -le 10 ] || break
      clasificar "$tok" 1
      case "$?" in
        0) BLOQUEO="volumen"; break ;;
        2) BLOQUEO="nomedible"; BLOQUEO_RUTA="$MEDIDA_RUTA"; break ;;
      esac
    done
  fi
fi

[ -n "$BLOQUEO" ] || exit 0

case "$BLOQUEO" in
  volumen)
    cat >&2 <<'MSG'
🛑 BLOQUEADO (redirect-code-search-to-mcp): leer CÓDIGO en volumen por fuera del índice.

Cambiar de herramienta (python/awk/find/node) no cambia el problema: leer muchos
archivos de código en crudo produce los mismos diagnósticos incompletos que grep
—no ve una dependencia inyectada, ni el docstring tres líneas más arriba—, y
además gasta contexto en texto que el índice ya tiene resuelto.

  ¿quién llama a X? ¿qué rompe si lo cambio?  → trace_path
  ¿dónde está definido X?                     → search_graph / find_symbol
  texto, pero enriquecido con el grafo        → search_code

Esto NO bloquea a python/awk/find en general: sólo cuando LEEN EL CONTENIDO de
archivos de código. Listar nombres (`find src -name "*.ts"`), procesar logs o
JSON, o leer UN archivo ya identificado siguen pasando.
MSG
    ;;
  nomedible)
    cat >&2 <<MSG
🛑 BLOQUEADO (redirect-code-search-to-mcp): búsqueda recursiva sobre «${BLOQUEO_RUTA}», y no se
pudo medir si contiene código (git ls-files tardó más de 2 s o falló, o la ruta
depende de una variable que el hook no puede resolver).

Un gate que no puede medir no abre. Salidas:
  · nombrá un directorio o archivo concreto, sin variables;
  · acotá la búsqueda a lo que no es código (--include='*.md', -g '*.log');
  · si es código, usá el índice (search_code / search_graph / trace_path).
MSG
    ;;
  *)
    cat >&2 <<MSG
🛑 BLOQUEADO (redirect-code-search-to-mcp): buscar en CÓDIGO con grep/sed vía Bash
(«${BLOQUEO_RUTA}» contiene código).

Usá el índice de código. Responde en una llamada y ve lo que grep no puede:

  ¿quién llama a X? ¿qué rompe si lo cambio?  → trace_path
  ¿dónde está definido X? ¿qué símbolos hay?  → search_graph / find_symbol
  ¿qué impacto tiene este diff?               → detect_changes
  ¿arquitectura, capas, módulos?              → get_architecture
  texto, pero enriquecido con el grafo        → search_code

(Herramientas mcp__codebase-memory-mcp__* y mcp__plugin_serena_serena__*.)

Por qué bloquea en vez de avisar: avisando se ignora. Y grep sobre código miente por
construcción — no ve una env leída por indirección, ni una dependencia inyectada, ni
el docstring que estaba tres líneas más arriba del match.

NO hay variable de override. Las salidas legítimas, que no dependen de tu voluntad:
  · el índice (arriba), que es el camino esperado;
  · un archivo concreto ya identificado, sin recursión ni comodines;
  · texto que no sea código: logs, JSON, YAML, configs, salida de CLIs
    (también acotando con --include='*.md');
  · lo que el índice no cubre: ${DIRS_FUERA_DEL_INDICE// /, } (sin seguir enlaces).
Si ninguna cubre tu caso, pedíselo al dueño: un agente no se auto-autoriza.
MSG
    ;;
esac
# El índice es del repo PRINCIPAL (`--git-common-dir`), no del worktree.
# codebase-memory lo nombra con la ruta absoluta sin la `/` inicial y con `/` → `-`.
comun="$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)"
case "$comun" in
  */.git) raiz="${comun%/.git}" ;;
  *) raiz="$RAIZ" ;;
esac
if [ -n "$raiz" ]; then
  indice="${raiz#/}"
  printf "\nÍndice de este repo: '%s' (NO '%s'). Serena: activate_project('%s').\nSi no existe: index_repository(repo_path='%s').\n" \
    "${indice//\//-}" "${raiz##*/}" "${raiz##*/}" "$raiz" >&2
else
  printf '\nEl cwd no es un repo de git: list_projects da el nombre del índice.\n' >&2
fi
registrar
exit 2

#!/usr/bin/env bash
# Biblioteca compartida: configuración POR PROYECTO de los hooks globales.
#
# Los hooks de ~/.claude/hooks aplican a TODOS los proyectos y no saben nada de
# ninguno. Lo que es de un proyecto vive en ESE proyecto, en un único archivo:
#
#   <raíz del repo>/.claude/hooks.json
#
#   {
#     "engram":          { "proyectos": ["nombre-viejo", "otro-alias"] },
#     "reglas_escritura": [
#       { "patron": "select[[:space:]]+\\*[[:space:]]+from", "id": 123,
#         "titulo": "Las consultas nombran sus columnas",
#         "exige": "Listar las columnas que se usan." }
#     ],
#     "busqueda_codigo": { "extensiones": ["svelte", "zig"], "directorios": ["generated/api"] },
#     "secretos":        { "clis": ["mycli secret reveal", "pass show"] }
#   }
#
# PRECEDENCIA: $CLAUDE_HOOKS_CONFIG (ruta a un JSON; para pruebas) > el archivo
# del repo > los valores por defecto de cada hook. La raíz sale de
# `git rev-parse --show-toplevel` sobre el directorio que pase el hook (el cwd
# del payload o $CLAUDE_PROJECT_DIR). Fuera de un repo de git no hay archivo.
#
# ── MODELO DE CONFIANZA ────────────────────────────────────────────────────
#
# Un repo clonado de un tercero también es "un proyecto", así que su archivo NO
# es de confianza:
#   · sólo puede SUMAR restricción o alcance: más extensiones, directorios,
#     CLIs de secretos, reglas y alias. Nunca quita un valor por defecto, ni
#     desactiva un hook, ni añade exenciones: esas claves no existen, y toda
#     clave desconocida se ignora;
#   · cada valor se valida y el inválido se descarta en silencio:
#       nombres     ^[A-Za-z0-9._-]{1,64}$
#       extensiones ^[a-z0-9]{1,10}$
#       directorios segmentos de nombre, relativos, sin `.` ni `..`
#       ids         ^[0-9]+$  (uno inválido se borra; la regla sigue)
#       regex       hasta 300 caracteres, sin retrorreferencias ni
#                   cuantificadores anidados, compiladas y probadas con
#                   `timeout 1 grep -E` antes de usarlas
#       CLIs        de 2 a 8 palabras [a-z0-9._-]
#   · JSON ilegible, ausente, enorme o sin jq: sólo los valores por defecto. La
#     configuración nunca hace que un hook de seguridad falle ABIERTO.
#   · NUNCA se hace `source` de nada que venga del repo: sólo se lee con jq.
#
# Lectura pura: sin estado, sin caché, sin archivos temporales. Dos hooks que la
# lean en el mismo turno no comparten nada que se pueda corromper.

_CFG_MAX_BYTES=65536
_CFG_MAX_ITEMS=100

# config_timeout <segundos> <comando…> → `timeout`, o `gtimeout` (macOS con
# coreutils). Sin ninguno, corre el comando sin límite: sin esto, una máquina
# sin `timeout` rechazaría todas las reglas y apagaría el gate en silencio.
config_timeout() {
  if command -v timeout >/dev/null 2>&1; then timeout "$@"
  elif command -v gtimeout >/dev/null 2>&1; then gtimeout "$@"
  else shift; "$@"
  fi
}

# config_raiz [dir] → raíz del repo de git que contiene <dir>, o nada.
config_raiz() {
  local dir="${1:-${CLAUDE_PROJECT_DIR:-$PWD}}"
  [ -d "$dir" ] || return 0
  git -C "$dir" rev-parse --show-toplevel 2>/dev/null || true
}

# config_archivo [dir] → ruta del JSON que manda, o nada.
config_archivo() {
  if [ -n "${CLAUDE_HOOKS_CONFIG:-}" ]; then
    printf '%s' "$CLAUDE_HOOKS_CONFIG"
    return 0
  fi
  local raiz
  raiz="$(config_raiz "${1:-}")"
  [ -n "$raiz" ] && [ -f "$raiz/.claude/hooks.json" ] && printf '%s' "$raiz/.claude/hooks.json"
  return 0
}

# _config_jq <filtro> [dir] → salida de jq sobre la configuración. Nunca falla:
# sin jq, sin archivo, archivo especial, demasiado grande o ilegible → nada.
_config_jq() {
  command -v jq >/dev/null 2>&1 || return 0
  local f tam
  f="$(config_archivo "${2:-}")"
  # `-f` exige un archivo regular: un FIFO o un dispositivo colgarían la lectura.
  [ -n "$f" ] && [ -f "$f" ] && [ -r "$f" ] || return 0
  tam="$(wc -c <"$f" 2>/dev/null || echo x)"
  case "$tam" in *[!0-9[:space:]]* | '') return 0 ;; esac
  [ "$tam" -le "$_CFG_MAX_BYTES" ] || return 0
  config_timeout 2 jq -r "try ($1) catch empty" <"$f" 2>/dev/null | head -n "$_CFG_MAX_ITEMS" || true
}

# Lista de strings de una ruta del JSON; cualquier otro tipo se ignora.
_config_strings() {
  _config_jq "($1)"' | arrays | .[] | strings | select(test("[\u0000-\u001f]") | not)' "${2:-}"
}

# config_engram_proyectos [dir] → alias de Engram declarados por el proyecto.
config_engram_proyectos() {
  _config_strings '.engram.proyectos' "${1:-}" | grep -E '^[A-Za-z0-9._-]{1,64}$' || true
}

# config_extensiones [dir] → extensiones de código ADICIONALES (sin punto).
config_extensiones() {
  _config_strings '.busqueda_codigo.extensiones' "${1:-}" | sed 's/^\.//' \
    | grep -E '^[a-z0-9]{1,10}$' || true
}

# config_directorios [dir] → directorios (relativos a la raíz) que cuentan como
# código aunque la medición no lo diga. Sin `/` inicial, sin `.` ni `..`.
config_directorios() {
  _config_strings '.busqueda_codigo.directorios' "${1:-}" | sed 's#/*$##' \
    | grep -E '^[A-Za-z0-9._-]{1,64}(/[A-Za-z0-9._-]{1,64}){0,7}$' \
    | grep -vE '(^|/)\.{1,2}(/|$)' || true
}

# config_secretos_clis [dir] → una entrada por línea, palabras separadas por un
# espacio: "mycli secret reveal". Acepta string o array de palabras.
config_secretos_clis() {
  _config_jq '.secretos.clis | arrays | .[]
    | if type == "array" then (map(strings) | join(" ")) elif type == "string" then . else empty end' "${1:-}" \
    | tr -s ' \t' '  ' | sed 's/^ //; s/ $//' \
    | grep -E '^[a-z0-9._-]{1,64}( [a-z0-9._-]{1,64}){1,7}$' || true
}

# config_regex_valida <regex> → 0 si se puede usar con `grep -E`.
# GNU grep es lineal salvo con retrorreferencias, que se rechazan; aun así se
# prueba contra un texto adverso con timeout, por si el grep del sistema no es GNU.
config_regex_valida() {
  local re="$1" rc
  [ -n "$re" ] && [ "${#re}" -le 300 ] || return 1
  case "$re" in *$'\n'* | *$'\001'*) return 1 ;; esac
  # Retrorreferencias y cuantificadores anidados (`(a+)+`, `(.*x){20}`): son las
  # formas que vuelven exponencial a un motor con backtracking. Se rechazan sin
  # depender de cuál sea el grep del sistema.
  printf '%s' "$re" | grep -qE '\\[1-9]|\([^()]*[*+}][^()]*\)[*+{]' && return 1
  config_timeout 1 grep -E -e "$re" </dev/null >/dev/null 2>&1
  rc=$?
  [ "$rc" = 0 ] || [ "$rc" = 1 ] || return 1
  printf '%s\n' "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa!" \
    | config_timeout 1 grep -aqE -e "$re" >/dev/null 2>&1
  rc=$?
  [ "$rc" = 0 ] || [ "$rc" = 1 ]
}

# config_regla_valida <patron> <id> <titulo> <exige> → imprime la regla saneada
# (campos separados por 0x01) o nada si el patrón no sirve. Un id inválido se
# borra: la regla sigue bloqueando y se cita por su título.
config_regla_valida() {
  local pat="$1" id="$2" tit="$3" exi="$4" s
  config_regex_valida "$pat" || return 0
  [[ "$id" =~ ^[0-9]{1,18}$ ]] || id=""
  # Título y exigencia salen por stderr: sin caracteres de control (una
  # secuencia ANSI ajena no llega a la terminal) y con un largo acotado.
  tit="$(printf '%s' "$tit" | tr -d '\000-\037\177' | cut -c1-200)"
  exi="$(printf '%s' "$exi" | tr -d '\000-\037\177' | cut -c1-500)"
  s="$(printf '\001')"
  printf '%s%s%s%s%s%s%s\n' "$pat" "$s" "$id" "$s" "$tit" "$s" "$exi"
}

# config_reglas_escritura [dir] → reglas del proyecto, ya validadas, una por
# línea con los campos separados por 0x01 (el formato del TSV histórico).
config_reglas_escritura() {
  local pat id tit exi s
  s="$(printf '\001')"
  while IFS="$s" read -r pat id tit exi; do
    [ -n "$pat" ] && config_regla_valida "$pat" "$id" "$tit" "$exi"
  done < <(_config_jq '.reglas_escritura | arrays | .[] | objects
      | select((.patron | type) == "string")
      | [.patron, ((.id // "") | tostring), ((.titulo // "") | tostring), ((.exige // "") | tostring)]
      | map(gsub("[\u0000-\u001f]"; " "))
      | join("\u0001")' "${1:-}")
}

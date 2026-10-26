#!/usr/bin/env bash
# Biblioteca compartida: EJECUTAR ≠ NOMBRAR.
#
# Los gates de Bash evalúan LO MISMO desde acá, en vez de tres copias que
# divergen (dos listas que dicen lo mismo terminan diciendo cosas distintas).
#
# ── POR QUÉ EXISTE ─────────────────────────────────────────────────────────
#
# Un gate que evalúa el TEXTO del comando bloquea por NOMBRAR, no por HACER.
# El caso testigo: `grep -c "no-leer-secretos-por-bash" x.jsonl` quedaría
# bloqueado POR CONTENER EL NOMBRE del hook, mientras CUENTA sus bloqueos.
#
# El costo no es sólo fricción: un gate que muerde el trabajo de medir deja un
# PUNTO CIEGO justo donde se lo audita. Se paga con lo que no se midió.
#
# ── FALLA CERRADO ──────────────────────────────────────────────────────────
#
# Quien hace `source` de este archivo debe BLOQUEAR si no puede cargarlo: un
# control que no resuelve su contexto no se rinde en silencio. El patrón de
# carga obligatorio está al pie de este archivo.

# normalizar_ejecutable <comando>
#
# Devuelve la parte APROXIMADAMENTE EJECUTABLE del comando: sin cuerpos de
# heredoc, sin strings entrecomillados, sin comentarios. Lo que queda es lo que
# el shell va a correr, no lo que el comando menciona.
#
# ⚠️ EL ORDEN DE LAS PASADAS ES PARTE DEL CONTROL, no un detalle:
#   1) comillas vacías  (`to''fu` ES `tofu` — si se borran strings primero, la
#      comilla vacía ya no existe y en su lugar quedó un espacio: `to fu`)
#   2) intérpretes      (el string de `bash -c '…'` es CÓDIGO, no una cita)
#   3) heredoc / strings / comentarios
#
# ⚠️ Los strings se reemplazan por un MARCADOR INERTE, no por un espacio.
# Con un espacio, `grep -nE "EXT|tf|terraform"` quedaría `grep -nE EXT|tf|terraform`,
# y los `|` que eran parte del PATRÓN pasarían a leerse como PIPES. Borrar un
# string no sólo pierde el contenido: FABRICA sintaxis de shell que no existe.
normalizar_ejecutable() {
  local cmd="$1"

  # (1) Comillas VACÍAS: el shell las elimina antes de ejecutar.
  cmd="$(printf '%s' "$cmd" | sed -E "s/''//g; s/\"\"//g")"

  # (2) EXCEPCIÓN: lo que recibe un INTÉRPRETE es código, no texto. Se exige que
  # el intérprete arranque un comando (inicio o tras separador) para que
  # `grep -n "bash -c" docs/` siga siendo texto y no dispare.
  if printf '%s' "$cmd" | grep -qE '(^|[|;&`]|&&|\|\||\$\()[[:space:]]*(eval|(env[[:space:]]+)?(ba|z|k|da)?sh([[:space:]]+-[^[:space:]]+)*[[:space:]]+-[a-zA-Z]*c)\b' \
     || printf '%s' "$cmd" | grep -qE '(^|[|;&]|&&|\|\|)[[:space:]]*((ba|z|k|da)?sh|python[0-9.]*|node|perl|ruby)\b[^|;&]*<<'; then
    printf '%s' "$cmd"
    return 0
  fi

  # (3) Heredoc + strings + comentarios.
  printf '%s' "$cmd" | awk '
    BEGIN { inhd = 0 }
    {
      line = $0
      if (inhd) { if (line ~ ("^[[:space:]]*" hd "[[:space:]]*$")) inhd = 0; next }
      if (match(line, /<<-?[[:space:]]*[\047"]?[A-Za-z_][A-Za-z0-9_]*[\047"]?/)) {
        hd = substr(line, RSTART, RLENGTH)
        gsub(/^<<-?[[:space:]]*|[\047"]/, "", hd)
        inhd = 1
        line = substr(line, 1, RSTART - 1)
      }
      gsub(/\047[^\047]*\047/, " XSTRX ", line)
      gsub(/"[^"]*"/, " XSTRX ", line)
      sub(/(^|[[:space:]])#.*$/, "", line)
      print line
    }
  '
}

# normalizar_heredoc <comando>
#
# Quita SOLO los cuerpos de heredoc, conservando strings y comentarios. Sirve
# para las sondas que necesitan ver rutas entrecomilladas (`cat ".env"`) pero
# no deben ver lo que un documento MENCIONA.
#
# Un heredoc dirigido a un INTERPRETE es ejecucion: ahi se devuelve intacto.
normalizar_heredoc() {
  local cmd="$1"
  if printf '%s' "$cmd" | grep -qE '(^|[|;&]|&&|\|\|)[[:space:]]*((ba|z|k|da)?sh|python[0-9.]*|node|perl|ruby)\b[^|;&]*<<'; then
    printf '%s' "$cmd"
    return 0
  fi
  printf '%s' "$cmd" | awk '
    BEGIN { inhd = 0 }
    {
      line = $0
      if (inhd) { if (line ~ ("^[[:space:]]*" hd "[[:space:]]*$")) inhd = 0; next }
      if (match(line, /<<-?[[:space:]]*[\047"]?[A-Za-z_][A-Za-z0-9_]*[\047"]?/)) {
        hd = substr(line, RSTART, RLENGTH)
        gsub(/^<<-?[[:space:]]*|[\047"]/, "", hd)
        inhd = 1
        line = substr(line, 1, RSTART - 1)
      }
      print line
    }
  '
}

# desenvolver_palabra_sola <comando>
#
# Quita las comillas que envuelven UNA SOLA PALABRA: `'tofu' apply` es sintaxis
# de shell, no una cita (un string citado de verdad lleva espacios). Sin esto,
# entrecomillar una palabra suelta es una forma barata de esquivar un gate.
#
# ⚠️ NO desenvuelve una palabra con METACARACTERES: en `grep -nE "EXT|tf" $H`
# el patrón es "una sola palabra" (no tiene espacios), y quitarle las comillas
# haría que los `|` del PATRÓN se leyeran como PIPES.
# Desenvolver es seguro sólo cuando lo de adentro no puede cambiar de ROL al
# perder las comillas: sin | ; & ` $ ( ) < > *
desenvolver_palabra_sola() {
  printf '%s' "$1" | sed -E \
    "s/(^|[[:space:]=])'([^'[:space:]|;&\`\$()<>*]+)'([[:space:]]|\$)/\1\2\3/g; \
     s/(^|[[:space:]=])\"([^\"[:space:]|;&\`\$()<>*]+)\"([[:space:]]|\$)/\1\2\3/g"
}

# colapsar_lineas <texto>
#
# `cmd \<newline> arg` es UN comando para el shell pero dos líneas para grep, y
# el argumento queda huérfano del binario. Se colapsa ANTES de evaluar.
colapsar_lineas() {
  printf '%s' "$1" | tr '\n' ' ' | sed -E 's/\\[[:space:]]+/ /g; s/[[:space:]]+/ /g'
}

# extraer_comando <payload-json>
#
# Saca `.tool_input.command`. Sin jq usa sed; si ni eso, neutraliza las comillas
# del payload para que el texto ejecutable sobreviva a la normalización (usar el
# payload CRUDO no sirve: es JSON, o sea TODO entre comillas, y la pasada que
# borra strings lo reduce a `{ :{ : }}` y el hook quedaría inerte).
extraer_comando() {
  local payload="$1" cmd=""
  if command -v jq >/dev/null 2>&1; then
    cmd="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
  fi
  if [ -z "$cmd" ]; then
    cmd="$(printf '%s' "$payload" \
      | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(\([^"\\]\|\\.\)*\)".*/\1/p' | head -1)"
    [ -n "$cmd" ] && cmd="$(printf '%b' "${cmd//\\\"/\"}" 2>/dev/null || printf '%s' "$cmd")"
    [ -z "$cmd" ] && cmd="$(printf '%s' "$payload" | tr '"' ' ')"
  fi
  printf '%s' "$cmd"
}

# ── PATRÓN DE CARGA OBLIGATORIO (falla CERRADO) ────────────────────────────
#
#   _lib="$(dirname "${BASH_SOURCE[0]}")/lib/normalizar-comando.sh"
#   if ! . "$_lib" 2>/dev/null || ! command -v normalizar_ejecutable >/dev/null; then
#     printf '🛑 BLOQUEADO: no se pudo cargar %s …\n' "$_lib" >&2
#     exit 2
#   fi
#
# Se comprueba que la FUNCIÓN exista, no sólo que el `source` devuelva 0: un
# archivo truncado a la mitad hace `source` exitoso y deja el gate sin su
# normalizador. Es la misma diferencia que entre "el hook existe" y "el hook
# está registrado".

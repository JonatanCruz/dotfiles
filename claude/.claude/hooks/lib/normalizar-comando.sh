#!/usr/bin/env bash
# Biblioteca compartida: EJECUTAR ≠ NOMBRAR.
#
# Portada desde guard-sensitive-exec.sh (otro repo), que ya había resuelto este
# problema y lo declara en su cabecera como invariante central. Acá se extrae
# para que los tres gates de Bash evalúen lo MISMO, en vez de tres copias que
# divergen — el defecto que este repo ya pagó dos veces (las dos listas de
# extensiones de redirect-code-search, las dos ramas de destino del guard).
#
# ── POR QUÉ EXISTE ─────────────────────────────────────────────────────────
#
# Medido en una sesión real (2026-09-22): dos hooks bloquearon 157 comandos.
#   redirect-code-search-to-mcp  107
#   no-leer-secretos-por-bash     50
#
# El defecto de los dos es el MISMO: bloqueaban por NOMBRAR, no por HACER —
# evaluaban el TEXTO del comando en vez de lo que el comando ejecuta. El caso
# testigo: `grep -c "no-leer-secretos-por-bash" x.jsonl` quedó bloqueado POR
# CONTENER SU PROPIO NOMBRE, mientras CONTABA bloqueos.
#
# El costo no fue sólo fricción. Un agente auditando seguridad reportó que "el
# eje de secrets quedó cubierto sólo por lo que aparece en bloques _env" — el
# control dejó un PUNTO CIEGO en una auditoría de seguridad. Un gate que muerde
# el trabajo de medir no se paga con fricción: se paga con lo que no se midió.
#
# ── FALLA CERRADO (Regla #14) ──────────────────────────────────────────────
#
# Quien hace `source` de este archivo debe BLOQUEAR si no puede cargarlo. Ese
# defecto —un control que no resuelve su contexto y se rinde en silencio— ya
# apareció TRES veces en este sistema (el guard sin jq, el gate sin
# CLAUDE_PROJECT_DIR, settings.json sin versionar) y está documentado en la
# Regla #14. El patrón de carga obligatorio está al pie de este archivo.

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
# Medido en guard-sensitive-exec: con un espacio, `grep -nE "EXT|tf|terraform"`
# dejaba `grep -nE EXT|tf|terraform`, y los `|` que eran parte del PATRÓN
# pasaban a leerse como PIPES. Borrar un string no sólo perdía el contenido:
# FABRICABA sintaxis de shell que nunca existió.
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
# ⚠️ NO desenvuelve una palabra con METACARACTERES. Medido en el guard:
#   grep -nE "EXT|tf|terraform" $H   → bloqueaba
# El patrón de grep es "una sola palabra" (no tiene espacios), así que la pasada
# le quitaba las comillas y los `|` del PATRÓN pasaban a leerse como PIPES.
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
# borra strings lo reduce a `{ :{ : }}` — medido, el hook quedaba inerte).
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
# normalizador. Es la misma diferencia entre "el hook existe" y "el hook está
# registrado" que la Regla #14 documenta.

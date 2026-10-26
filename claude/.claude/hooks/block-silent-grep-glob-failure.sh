#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash). BLOQUEA (exit 2) una sintaxis que en zsh falla
# SIEMPRE y en silencio: `--include=*.ts` / `--exclude=*.js` sin comillas.
#
# EL MODO DE FALLA
# ----------------
# zsh expande el glob ANTES de pasárselo a grep. Si el patrón no matchea nada en
# el cwd, zsh aborta el comando entero:
#
#     $ grep -rn "foo" . --include=*.ts
#     zsh:1: no matches found: --include=*.ts
#
# El comando NUNCA CORRE. La salida queda vacía, y una salida vacía se lee igual
# que "no existe". Es un falso negativo silencioso: la peor clase, porque funda
# conclusiones seguras sobre una medición que jamás se hizo.
#
# Una búsqueda que no corrió produce conclusiones equivocadas que parecen
# seguras ("X no existe", "Z no menciona a X").
#
# POR QUÉ BLOQUEA
# ---------------
# No adivina nada. No interpreta si la búsqueda era apropiada, ni sobre qué
# archivos, ni con qué intención. Detecta una sintaxis que en este shell está rota
# SIEMPRE, para cualquier uso: si el glob no está entrecomillado, el comando falla
# con o sin hook — bloquearlo no le quita al agente ninguna capacidad, sólo
# convierte una falla muda en un error visible.
#
# EJECUTAR ≠ NOMBRAR — el hook distingue las dos cosas. MENCIONAR la sintaxis
# no la ejecuta:
#
#   git commit -m "fix: usar --include=*.ts entrecomillado"
#   echo "usa --include=*.ts con comillas"
#   cat > /tmp/nota.md <<EOF … --include=*.ts … EOF
#   ls src/  # ojo con --include=*.ts
#
# Un gate que muerde el trabajo de escribir y medir se termina desactivando, y
# ahí se pierde también el bloqueo que sí servía. Por eso se descartan strings,
# heredocs y comentarios antes de evaluar (detalle junto al código, más abajo).
#
# La suite está en tests/casos-block-silent-grep-glob-failure.txt y se corre con
# tests/correr.sh.
#
# Esa es la diferencia con un gate de conducta: no cierra una categoría de
# comportamiento, cierra un modo de falla concreto y verificable.
#
# Contrato Claude Code:
#   stdin: JSON { tool_input: { command }, ... }
#   exit 0 = permitir · exit 2 = bloquear (stderr vuelve al modelo)

set -uo pipefail

payload="$(cat 2>/dev/null || true)"

cmd=""
if command -v jq >/dev/null 2>&1; then
  cmd="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
fi

# ── Fallback sin jq: extraer "command", NO usar el payload crudo. Con la pasada
# de normalización de abajo, el crudo (que es JSON, todo entre comillas dobles)
# quedaría reducido a nada y el gate saldría 0 sobre un glob roto de verdad.
if [ -z "$cmd" ]; then
  cmd="$(printf '%s' "$payload" \
    | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(\([^"\\]\|\\.\)*\)".*/\1/p' \
    | head -1)"
  [ -n "$cmd" ] && cmd="$(printf '%b' "${cmd//\\\"/\"}" 2>/dev/null || printf '%s' "$cmd")"
  [ -z "$cmd" ] && cmd="$(printf '%s' "$payload" | tr '"' ' ')"
fi
[ -z "$cmd" ] && exit 0

# ── EJECUTAR ≠ NOMBRAR ──────────────────────────────────────────────────────
#
# Se descartan heredocs, strings entrecomillados y comentarios, porque ahí vive
# TEXTO, no ejecución (los ejemplos están en el encabezado).
#
# Dos detalles que son parte del control, no de la implementación:
#
#   1. Las comillas VACÍAS se colapsan ANTES del awk que borra strings. Después
#      ya es tarde: el borrado las convirtió en un espacio y el match se pierde.
#   2. El string que recibe un INTÉRPRETE no es texto, es código: ahí se evalúa
#      el comando CRUDO. `bash -c 'grep … --include=*.ts'` SÍ ejecuta el glob
#      roto, así que debe seguir bloqueando.
#
# Nótese que la dirección del error acá es la INVERSA de la del gate de memoria:
# allá el riesgo es dejar pasar una escritura; acá el riesgo es bloquear texto
# inocuo. Por eso allá la lista de lecturas es cerrada y acá se descarta el texto.
if printf '%s' "$cmd" | grep -qE '(^|[|;&`]|&&|\|\||\$\()[[:space:]]*(eval|(env[[:space:]]+)?(ba|z|k|da)?sh([[:space:]]+-[^[:space:]]+)*[[:space:]]+-[a-zA-Z]*c)\b' \
   || printf '%s' "$cmd" | grep -qE '(^|[|;&]|&&|\|\|)[[:space:]]*(ba|z|k|da)?sh\b[^|;&]*<<'; then
  : # intérprete: el string ES el comando, se evalúa crudo
else
  cmd="$(printf '%s' "$cmd" | sed -E "s/''//g; s/\"\"//g" | awk '
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
      gsub(/\047[^\047]*\047/, " ", line)   # strings entre comillas simples
      gsub(/"[^"]*"/, " ", line)            # strings entre comillas dobles
      sub(/(^|[[:space:]])#.*$/, "", line)  # comentarios
      print line
    }
  ')"
  cmd="$(printf '%s' "$cmd" | tr '\n' ' ' | sed -E 's/\\[[:space:]]+/ /g; s/[[:space:]]+/ /g')"
  [ -z "${cmd//[[:space:]]/}" ] && exit 0
fi

# `--include=` / `--exclude=` (o `--include-dir`) seguido de un valor con un
# metacaracter de glob (* ? [) que NO abre con comilla simple ni doble.
#
# Entrecomillado (`--include="*.ts"`) → se permite: funciona.
# Sin glob (`--include=Makefile`)     → se permite: zsh no lo expande.
# Escapado (`--include=\*.ts`)        → se permite: el `\` lo vuelve literal.
if printf '%s' "$cmd" | sed 's/\\[*?[]/L/g' |
  grep -qE '\-\-(include|exclude)(-dir)?=[^"'"'"'[:space:]]*[*?[]'; then
  cat >&2 <<'MSG'
🛑 BLOQUEADO: `--include=`/`--exclude=` con glob SIN COMILLAS.

En zsh el glob se expande ANTES de llegar a grep. Si no matchea en el cwd, zsh
aborta el comando entero:

    zsh:1: no matches found: --include=*.ts

El comando NO CORRE y la salida queda VACÍA — que se lee igual que "no existe".
Es un falso negativo silencioso: te deja concluir con confianza sobre una
búsqueda que nunca ocurrió.

QUÉ HACER:

  1. Si buscás CÓDIGO → usá el índice, no grep:
       mcp__codebase-memory-mcp__search_code    (texto, enriquecido con el grafo)
       mcp__codebase-memory-mcp__search_graph   (símbolos: funciones, clases, rutas)
       mcp__codebase-memory-mcp__trace_path     (quién llama a qué)
     Si el repo no está indexado: index_repository. Si el índice está viejo,
     reindexá — no vuelvas a grep.

  2. Si de verdad necesitás grep (logs, JSON, YAML, salida de CLIs):
       poné comillas →  grep -rn "patrón" . --include="*.ts"
       o usá ripgrep →  rg -t ts "patrón"
MSG
  exit 2
fi

exit 0

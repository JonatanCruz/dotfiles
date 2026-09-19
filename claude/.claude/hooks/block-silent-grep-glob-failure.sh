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
# El fix es trivial: comillas. `--include="*.ts"` funciona.
#
# POR QUÉ BLOQUEA
# ---------------
# No adivina nada. No interpreta si la búsqueda era apropiada, ni sobre qué
# archivos, ni con qué intención. Detecta una sintaxis que en este shell está rota
# SIEMPRE, para cualquier uso: si el glob no está entrecomillado, el comando falla
# con o sin hook — bloquearlo no le quita al agente ninguna capacidad, sólo
# convierte una falla muda en un error visible.
#
# ⚠️ LÍMITE CONOCIDO — este hook NO distingue EJECUTAR de NOMBRAR.
#
# Acá decía "el falso positivo es imposible por construcción". Es FALSO, y lo
# refuta un caso trivial. Medido el 2026-09-19 ejecutando el hook:
#
#   echo "usa --include=*.ts con comillas"                    → exit 2
#   git commit -m "fix: usar --include=*.ts entrecomillado"   → exit 2
#   cat > /tmp/nota.md <<EOF … --include=*.ts … EOF           → exit 2
#
# O sea: no se puede escribir el mensaje de commit que documenta este arreglo,
# ni una nota que explique el modo de falla, porque MENCIONAN la sintaxis. El
# patrón mira el comando entero sin descartar strings, heredocs ni comentarios
# — que es exactamente la pasada "ejecutar ≠ nombrar" que guard-sensitive-exec.sh
# y no-editar-repo-por-bash.sh sí implementan.
#
# Se deja documentado en vez de parcheado a ciegas: el error es CONSERVADOR
# (bloquea texto inocuo, nunca deja pasar el glob roto) y la salida es
# entrecomillar el glob dentro del texto, que además es la forma correcta de
# citarlo. Pero la afirmación de arriba no se sostenía y no debía seguir escrita:
# justificaba no verificar.
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
[ -z "$cmd" ] && cmd="$payload"
[ -z "$cmd" ] && exit 0

# `--include=` / `--exclude=` (o `--include-dir`) seguido de un valor con un
# metacaracter de glob (* ? [) que NO abre con comilla simple ni doble.
#
# Entrecomillado (`--include="*.ts"`) → se permite: funciona.
# Sin glob (`--include=Makefile`)     → se permite: zsh no lo expande.
if printf '%s' "$cmd" |
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

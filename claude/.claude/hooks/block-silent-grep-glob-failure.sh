#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash). BLOQUEA (exit 2) un patrón de sintaxis que en
# zsh falla SIEMPRE y en silencio: `--include=*.ts` / `--exclude=*.js` sin comillas.
#
# POR QUÉ EXISTE (medido, 2026-08-14)
# ----------------------------------
# zsh expande el glob ANTES de pasárselo a grep. Si `*.ts` no matchea nada en el
# cwd, zsh aborta el comando entero:
#
#     $ grep -rn "foo" . --include=*.ts
#     zsh:1: no matches found: --include=*.ts
#
# El comando NUNCA CORRE. La salida es vacía, y el vacío se lee igual que
# "no existe" — un falso negativo SILENCIOSO, que es la peor clase.
#
# En una sola sesión esto produjo TRES conclusiones equivocadas:
#   1. "el bot no tiene restos del monitoreo viejo"  → falso, sí los tenía
#   2. "svc-recharge no menciona al bot"             → falso, 106 menciones
#   3. "montoRecargaCents no existe"                 → falso, y por poco desmiento
#                                                      el hallazgo correcto de un agente
#
# El fix es trivial: comillas. `--include="*.ts"` funciona perfecto (verificado).
#
# POR QUÉ ESTE SÍ BLOQUEA (y el de redirect-code-search-to-mcp NO)
# ----------------------------------------------------------------
# Aquel hook no bloquea a propósito: tendría que ADIVINAR si un grep sobre código
# es legítimo, y el panel de la Regla #14 rechazó los hooks heurísticos porque sus
# falsos positivos entrenan al `--no-verify` crónico.
#
# Éste no adivina NADA. No interpreta si la búsqueda era apropiada, ni sobre qué
# archivos, ni con qué intención. Sólo detecta una sintaxis que en este shell está
# rota SIEMPRE, para cualquier uso. Falso positivo imposible: si el glob no está
# entrecomillado, el comando falla — con o sin hook.
#
# Es la distinción que hace que valga la pena: no cierra una categoría de conducta,
# cierra un modo de falla concreto y medido.
#
# Contrato Claude Code:
#   - stdin: JSON { tool_input: { command }, ... }
#   - exit 2 = BLOQUEAR (stderr vuelve al modelo como feedback)
#   - exit 0 = permitir

set -uo pipefail

payload="$(cat)"

if command -v jq >/dev/null 2>&1; then
  cmd="$(printf '%s' "$payload" | jq -r '.tool_input.command // ""')"
else
  cmd="$payload"
fi

[ -z "$cmd" ] && exit 0

# `--include=` o `--exclude=` (o su forma `--include-dir`) seguido de un valor que
# contiene un metacaracter de glob (* ? [) y que NO abre con comilla simple o doble.
#
# Entrecomillado (`--include="*.ts"` / `--include='*.ts'`) → se permite: funciona.
# Sin glob (`--include=Makefile`) → se permite: zsh no lo expande, no rompe.
if printf '%s' "$cmd" |
  grep -qE '\-\-(include|exclude)(-dir)?=[^"'"'"'[:space:]]*[*?[]'; then
  cat >&2 <<'MSG'
BLOQUEADO: `--include=`/`--exclude=` con glob SIN COMILLAS.

En zsh el glob se expande ANTES de llegar a grep. Si no matchea en el cwd, zsh
aborta el comando entero:

    zsh:1: no matches found: --include=*.ts

El comando NO CORRE y la salida queda VACÍA — que se lee igual que "no existe".
Es un falso negativo silencioso. El 2026-08-14 produjo tres conclusiones
equivocadas en una sola sesión, incluida una que casi desmiente un hallazgo
correcto.

QUÉ HACER:

  1. Si buscás CÓDIGO → usá el grafo, NO grep (orden del dueño, 2026-08-13):
       mcp__codebase-memory-mcp__search_code    (texto, enriquecido con el grafo)
       mcp__codebase-memory-mcp__search_graph   (símbolos: funciones, clases, rutas)
       mcp__codebase-memory-mcp__trace_path     (quién llama a qué)
     Proyecto: `PLATAFORMA`. Si el índice está viejo, REINDEXÁ — no vuelvas a grep.

  2. Si de verdad necesitás grep (logs, JSON, YAML, salida de gcloud/gh):
       poné comillas →  --include="*.ts"
       o usá ripgrep →  rg -t ts "patrón"
MSG
  exit 2
fi

exit 0

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
# En una sola sesión esto produjo TRES conclusiones equivocadas ("X no tiene
# restos de Y", "el servicio Z no menciona a X", "el campo W no existe"): las
# tres eran falsas, y por poco se desmintió el hallazgo correcto de un agente.
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
# archivos, ni con qué intención. Sólo detecta una sintaxis que en este shell
# falla siempre que el glob no matchea en el cwd.
#
# Falsos positivos que SÍ existen y cómo se acotan:
#   - El patrón dentro de un string (un payload JSON, un mensaje de commit) no se
#     ejecuta: el contenido entrecomillado se descarta antes de buscar.
#   - Si el glob SÍ matchea en el cwd, zsh lo expande y el comando corre (con un
#     argumento distinto del escrito). Se bloquea igual: el resultado depende de
#     qué haya en el cwd, que es justo lo que no se debe dejar al azar.
#   - El cuerpo de un heredoc no se distingue del comando: puede bloquear de más.
#
# Es la distinción que hace que valga la pena: no cierra una categoría de conducta,
# cierra un modo de falla concreto y medido.
#
# Contrato Claude Code:
#   - stdin: JSON { tool_input: { command }, ... }
#   - exit 2 = BLOQUEAR (stderr vuelve al modelo como feedback)
#   - exit 0 = permitir

set -uo pipefail

# Falla ABIERTO sin jq o con JSON ilegible: no es un control de seguridad, y sin
# jq el comando viaja dentro de las comillas del JSON, así que no se puede aislar.
payload="$(cat 2>/dev/null || true)"
command -v jq >/dev/null 2>&1 || exit 0
cmd="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
[ -n "$cmd" ] || exit 0

# Lo entrecomillado es texto, no argumentos que zsh vaya a expandir: se reemplaza
# por un marcador `Q`. Así `--include="*.ts"` queda `--include=Q` (permitido) y
# un `'{"x":"--include=*.ts"}'` desaparece entero.
sin_comillas="$(printf '%s' "$cmd" | awk 'BEGIN { RS = "\001" } {
  s = $0; out = ""; q = ""; n = length(s)
  for (i = 1; i <= n; i++) {
    c = substr(s, i, 1)
    if (q == "") {
      if (c == "\\" && i < n) { out = out c substr(s, i + 1, 1); i++; continue }
      if (c == "\047" || c == "\"") { q = c; out = out "Q"; continue }
      out = out c
    } else if (c == q) {
      q = ""
    } else if (q == "\"" && c == "\\" && i < n) {
      i++
    }
  }
  printf "%s", out
}')"

# `--include=` o `--exclude=` (o su forma `--include-dir`) seguido de un valor que
# contiene un metacaracter de glob (* ? [) fuera de comillas.
#
# Entrecomillado (`--include="*.ts"` / `--include='*.ts'`) → se permite: funciona.
# Sin glob (`--include=Makefile`) → se permite: zsh no lo expande, no rompe.
# `[[ =~ ]]` y no `grep -q` en una tubería: con pipefail, la salida temprana de
# grep puede matar a printf por SIGPIPE.
glob_sin_comillas='--(include|exclude)(-dir)?=[^[:space:]]*[*?[]'
if [[ "$sin_comillas" =~ $glob_sin_comillas ]]; then
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
     (list_projects da el nombre del índice). Si está viejo, REINDEXÁ — no vuelvas a grep.

  2. Si de verdad necesitás grep (logs, JSON, YAML, salida de gcloud/gh):
       poné comillas →  --include="*.ts"
       o usá ripgrep →  rg -t ts "patrón"
MSG
  exit 2
fi

exit 0

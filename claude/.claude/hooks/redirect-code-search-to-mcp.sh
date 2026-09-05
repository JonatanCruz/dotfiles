#!/usr/bin/env bash
# PreToolUse (matcher: Bash) — bloquea la búsqueda de CÓDIGO con grep/sed vía Bash
# cuando hay un índice de código disponible.
#
# Cierra el hueco de los gates que interceptan las tools Grep|Glob: un `grep` corrido
# dentro de Bash las esquiva por completo.
#
# El control vive en la estructura, no en la memoria del agente. Un aviso sólo previene
# el error que el agente ya sabe que está cometiendo; no previene al que cree que está
# usando la herramienta correcta. Por eso falla cerrado.
#
# ALCANCE — bloquea sólo donde el error es caro:
#   · sí: búsquedas sobre fuentes de código
#   · no: logs, JSON, YAML, configs, salidas de CLIs (ahí grep ES la herramienta)
#   · no: un archivo único ya identificado (leerlo/filtrarlo es legítimo)
# Bloquear de más entrena a saltarse el gate, y ahí se pierden las dos cosas.
#
# Un índice ve lo que grep no puede: quién llama a qué a través de inyección de
# dependencias, un docstring completo en vez del fragmento que entró en la línea
# matcheada, el impacto real de un cambio. Leer código en pedazos produce diagnósticos
# que el archivo entero habría desmentido.
#
# Override consciente y auditable — se escribe a propósito, no es un bypass silencioso:
#   CBM_CHECKED=1 <comando>
#
# Contrato Claude Code:
#   stdin: JSON { tool_input: { command }, ... }
#   exit 0 = permitir · exit 2 = bloquear (stderr vuelve al modelo)

set -uo pipefail

payload="$(cat)"

if command -v jq >/dev/null 2>&1; then
  cmd="$(printf '%s' "$payload" | jq -r '.tool_input.command // ""')"
else
  cmd="$payload"
fi

[ -z "$cmd" ] && exit 0

# El agente ya midió con el índice y necesita grep para algo puntual.
printf '%s' "$cmd" | grep -qE '(^|[[:space:]])CBM_CHECKED=1' && exit 0

# ¿Es una búsqueda de texto?
printf '%s' "$cmd" | grep -qE '(^|[|;&[:space:]])(grep|rg|ag|sed|ack)([[:space:]]|$)' || exit 0

# ¿Apunta a código? Extensiones de fuentes, o directorios de fuentes de layouts comunes
# (monorepo por paquetes, o `src/` a secas). Si no toca código, no molestamos.
printf '%s' "$cmd" | grep -qE '\.(ts|tsx|js|jsx|mjs|cjs|astro|vue|svelte|py|go|rs|java|kt|rb|php|swift|cs|scala|ex|exs)\b|(^|[[:space:]/])(src|lib|app)([[:space:]/]|$)' || exit 0

# Un solo path concreto sin recursión ni comodines: el archivo ya está identificado.
if printf '%s' "$cmd" | grep -qE '\.(ts|tsx|js|jsx|py|go|rs|java|kt|rb|php|swift|cs)\b' \
   && ! printf '%s' "$cmd" | grep -qE '(^|[[:space:]])-[a-zA-Z]*[rR]|[*?]|--include' ; then
  exit 0
fi

cat >&2 <<'MSG'
🛑 BLOQUEADO (redirect-code-search-to-mcp): buscar en CÓDIGO con grep/sed vía Bash.

Usá el índice de código. Responde en una llamada y ve lo que grep no puede:

  ¿quién llama a X? ¿qué rompe si lo cambio?  → trace_path
  ¿dónde está definido X? ¿qué símbolos hay?  → search_graph / find_symbol
  ¿qué impacto tiene este diff?               → detect_changes
  ¿arquitectura, capas, módulos?              → get_architecture
  texto, pero enriquecido con el grafo        → search_code

(Herramientas mcp__codebase-memory-mcp__* y mcp__plugin_serena_serena__*. Si el
repo todavía no está indexado: index_repository. Serena pide activate_project.)

Por qué bloquea en vez de avisar: avisando se ignora. Y grep sobre código miente por
construcción — no ve una env leída por indirección, ni una dependencia inyectada, ni
el docstring que estaba tres líneas más arriba del match.

Si YA mediste con el índice y necesitás grep para algo puntual, escribilo a propósito:

    CBM_CHECKED=1 <tu comando>
MSG
exit 2

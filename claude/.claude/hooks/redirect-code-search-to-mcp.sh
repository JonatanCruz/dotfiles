#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash). Cierra el AGUJERO del `cbm-code-discovery-gate`:
# ese gate solo intercepta las tools Grep|Glob, así que un `grep` ejecutado DENTRO
# de Bash lo esquiva por completo — que es exactamente lo que pasó toda la sesión
# 2026-07-20 (el dueño lo señaló 3 veces: "si tenemos los MCPs ¿por qué no los ocupas?").
#
# Por qué existe (Meadows, la filosofía que ya usa este repo en las Reglas #12/#13/#14):
# el control tiene que vivir en la ESTRUCTURA, no en la memoria del próximo agente.
# Un recordatorio en prosa no previene el "error competente" — el agente que CREE que
# está usando las herramientas correctas. Este hook hace que caer en grep sobre código
# sea un acto CONSCIENTE, no el camino de menor resistencia.
#
# Qué hace: NO bloquea (exit 0 siempre). Inyecta un recordatorio dirigido cuando el
# comando es una búsqueda de CÓDIGO. Deliberadamente NO se mete con búsquedas sobre
# logs, JSON, YAML, configs o salidas de gcloud/gh — ahí grep es la herramienta correcta
# y bloquearlo sería el falso positivo que el panel rechazó en la Regla #14
# ("hook heurístico que adivine → falsos positivos → --no-verify crónico").
#
# Contrato Claude Code:
#   - stdin: JSON { tool_input: { command }, ... }
#   - exit 0 = permitir. El JSON de salida inyecta additionalContext al modelo.

set -uo pipefail

payload="$(cat)"

if command -v jq >/dev/null 2>&1; then
  cmd="$(printf '%s' "$payload" | jq -r '.tool_input.command // ""')"
else
  cmd="$payload"
fi

[ -z "$cmd" ] && exit 0

# ¿Es una búsqueda de texto? (grep/rg/ag/sed/find sobre nombres)
printf '%s' "$cmd" | grep -qE '(^|[|;&[:space:]])(grep|rg|ag|sed|ack)([[:space:]]|$)' || exit 0

# ¿Apunta a CÓDIGO? Extensiones de código o directorios de fuentes del monorepo.
# Si no toca código (logs, tfstate, csv, salida de gcloud/gh), no molestamos.
printf '%s' "$cmd" | grep -qE '\.(ts|tsx|js|jsx|mjs|cjs|astro|py|go|rs|java|kt|rb|php|swift)\b|services/[a-z-]+/src|packages/[a-z-]+/src|apps/[a-z-]+/src' || exit 0

# Excepción: si el comando ya está acotado a un archivo único que el agente YA
# identificó, leer/filtrar ese archivo con grep es legítimo y barato.
# Heurística: un solo path concreto .ts sin comodines ni -r/-R.
if printf '%s' "$cmd" | grep -qE '\.(ts|tsx|js|py|go)\b' \
   && ! printf '%s' "$cmd" | grep -qE '(^|[[:space:]])-[a-zA-Z]*[rR]|[*?]|--include' ; then
  exit 0
fi

cat <<'JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "additionalContext": "RECORDATORIO ESTRUCTURAL (hook redirect-code-search-to-mcp): estás por buscar en CÓDIGO con grep/sed vía Bash. Este proyecto tiene MCPs indexados que responden mejor y en UNA llamada:\n\n- ¿Quién llama a X? ¿qué rompe si cambio X? → mcp__codebase-memory-mcp__trace_path (mode=calls|cross_service). grep NO ve el cableado por inyección de dependencias — así se perdió la cadena CircuitBreaker(Retrying(...)) el 2026-07-20.\n- ¿Dónde está definido X? ¿qué símbolos hay? → mcp__codebase-memory-mcp__search_graph o mcp__plugin_serena_serena__find_symbol (include_body/include_info da el docstring COMPLETO, no fragmentos).\n- ¿Qué impacto tiene este cambio/diff? → mcp__codebase-memory-mcp__detect_changes (since=<ref>).\n- ¿Arquitectura, capas, clusters? → mcp__codebase-memory-mcp__get_architecture.\n- Búsqueda de texto pero enriquecida con el grafo → mcp__codebase-memory-mcp__search_code.\n\nProyecto indexado: 'home-jonatan-DESARROLLO-PLATAFORMA' (NO 'PLATAFORMA'). Serena requiere activate_project('PLATAFORMA') una vez por sesión.\n\nPOR QUÉ IMPORTA: leer en pedazos con grep produjo 3 diagnósticos sucesivos y equivocados en una sola sesión, porque el test/docstring que los invalidaba estaba fuera del fragmento leído. Si ya mediste con el MCP y necesitás grep para algo puntual, seguí adelante — este aviso no bloquea."
  }
}
JSON
exit 0

#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash). Cierra el AGUJERO del `cbm-code-discovery-gate`:
# ese gate solo intercepta las tools Grep|Glob, así que un `grep` ejecutado DENTRO
# de Bash lo esquiva por completo.
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
#   - Sin jq o con JSON ilegible sale 0 sin avisar: el JSON de salida lleva el
#     nombre del proyecto y sólo jq lo escapa bien.

set -uo pipefail

payload="$(cat 2>/dev/null || true)"
command -v jq >/dev/null 2>&1 || exit 0
cmd="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
cwd="$(printf '%s' "$payload" | jq -r '.cwd // empty' 2>/dev/null || true)"

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

# Nombre del proyecto, derivado del repo y no escrito aquí. Se usa el repo
# PRINCIPAL (`--git-common-dir`), no el worktree: el índice es del principal.
# codebase-memory nombra el índice con la ruta absoluta sin la `/` inicial y con
# `/` → `-` (/home/u/src/app → home-u-src-app); Serena usa el nombre de la carpeta.
proyecto=""
comun="$(git -C "${cwd:-$PWD}" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)"
case "$comun" in
  */.git) raiz="${comun%/.git}" ;;
  *) raiz="$(git -C "${cwd:-$PWD}" rev-parse --show-toplevel 2>/dev/null || true)" ;;
esac
if [ -n "$raiz" ]; then
  indice="${raiz#/}"
  indice="${indice//\//-}"
  proyecto="Proyecto indexado: '$indice' (NO '${raiz##*/}'). Serena requiere activate_project('${raiz##*/}') una vez por sesión. Si el índice no existe, mcp__codebase-memory-mcp__index_repository(repo_path='$raiz')."
else
  proyecto="El cwd no es un repo de git: mcp__codebase-memory-mcp__list_projects da el nombre del índice."
fi

ctx="RECORDATORIO ESTRUCTURAL (hook redirect-code-search-to-mcp): estás por buscar en CÓDIGO con grep/sed vía Bash. Este proyecto tiene MCPs indexados que responden mejor y en UNA llamada:

- ¿Quién llama a X? ¿qué rompe si cambio X? → mcp__codebase-memory-mcp__trace_path (mode=calls|cross_service). grep NO ve el cableado por inyección de dependencias — así se perdió una cadena de decoradores el 2026-07-20.
- ¿Dónde está definido X? ¿qué símbolos hay? → mcp__codebase-memory-mcp__search_graph o mcp__plugin_serena_serena__find_symbol (include_body/include_info da el docstring COMPLETO, no fragmentos).
- ¿Qué impacto tiene este cambio/diff? → mcp__codebase-memory-mcp__detect_changes (since=<ref>).
- ¿Arquitectura, capas, clusters? → mcp__codebase-memory-mcp__get_architecture.
- Búsqueda de texto pero enriquecida con el grafo → mcp__codebase-memory-mcp__search_code.

$proyecto

POR QUÉ IMPORTA: leer en pedazos con grep produjo 3 diagnósticos sucesivos y equivocados en una sola sesión, porque el test/docstring que los invalidaba estaba fuera del fragmento leído. Si ya mediste con el MCP y necesitás grep para algo puntual, seguí adelante — este aviso no bloquea."

jq -n --arg ctx "$ctx" \
  '{hookSpecificOutput: {hookEventName: "PreToolUse", additionalContext: $ctx}}' 2>/dev/null || true
exit 0

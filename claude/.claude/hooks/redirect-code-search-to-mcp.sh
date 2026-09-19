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

# Extracción del comando. El fallback SIN jq no puede ser el payload crudo: en
# el JSON las comillas van escapadas, y la etapa 1 de abajo exige que la
# herramienta venga precedida por inicio-de-línea o un separador de shell.
# Sobre el crudo queda precedida por una comilla -> no matchea -> el gate
# salía 0 y DEJABA PASAR la búsqueda que venía a bloquear.
# Medido el 2026-09-19 con jq oculto del PATH: exit=0 sobre un caso que con
# jq da 2. Ahora se decodifica el campo y, si ni eso funciona, se usa el
# payload entero como red de contención. Un gate que ante lo inesperado deja
# pasar es peor que no tenerlo.
if command -v jq >/dev/null 2>&1; then
  cmd="$(printf '%s' "$payload" | jq -r '.tool_input.command // ""')"
else
  cmd="$(printf '%s' "$payload" \
    | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p' \
    | sed 's/\\"/"/g; s/\\\\/\\/g' | head -1)"
  [ -z "$cmd" ] && cmd="$payload"
fi

[ -z "$cmd" ] && exit 0

# ── NO HAY OVERRIDE. Se retiró el 2026-09-19 por orden del dueño. ───────────
#
# Existía `CBM_CHECKED=1`: una palabra que el AGENTE escribía por su cuenta para
# saltarse este gate. Medido ese mismo día: se usó como atajo sistemático, no
# como excepción — el agente lo anteponía en vez de usar el índice, y el dueño
# lo detectó.
#
# Primer intento de arreglo: dejarlo pero REGISTRARLO. El dueño lo refutó en una
# línea: *"¿qué diferencia hay entre saltarlo en silencio y saltarlo con
# registro?"*. Ninguna, si nadie lee el registro. Era el mismo patrón que este
# repo ya pagó caro: el detector de líneas trabadas EXISTÍA, medía 101 casos en
# 30 días, y estaba apagado. Observabilidad que nadie mira no es control.
#
# Ahora la puerta no existe. Si el gate bloquea, el camino es el índice
# (search_code/trace_path/find_symbol) o un comando que no sea una búsqueda
# recursiva sobre código. Las excepciones LEGÍTIMAS siguen abajo y no dependen
# de la voluntad del agente: si no apunta a código, o es un archivo concreto sin
# recursión, no se bloquea.
#
# Si algún día aparece un caso real que estas excepciones no cubren, se pide al
# dueño y él decide. Un agente no se auto-autoriza.

# El registro se conserva: sirve para ver si el gate estorba de verdad.
log="${HOME}/.claude/logs/cbm-blocked.log"

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
mkdir -p "$(dirname "$log")" 2>/dev/null
printf '%s\t%s\n' "$(date -Is)" "$(printf '%s' "$cmd" | head -c 300)" >> "$log" 2>/dev/null
exit 2

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
# NO HAY OVERRIDE. `CBM_CHECKED=1` existió y se retiró el 2026-09-19 (el porqué,
# más abajo, junto al código). Este encabezado siguió ofreciéndolo hasta el
# 2026-09-19: verificado ejecutando, `CBM_CHECKED=1 grep -r handler src/*.ts`
# devuelve exit=2, igual que sin la variable. Las salidas legítimas están en el
# ALCANCE de arriba y no dependen de la voluntad del agente.
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

# ── SUSTITUCIÓN DE HERRAMIENTA (medido el 2026-09-19) ──────────────────────
# El gate miraba sólo grep/rg/ag/sed/ack. Cambiando de binario se lo rodeaba sin
# dejar rastro, con el MISMO objetivo (leer código en volumen):
#
#   python3 -c "...rglob('*.ts')...p.read_text()..."   → exit=0
#   awk '/handler/{print FILENAME}' src/*.ts           → exit=0
#   find src -name '*.ts' -exec cat {} +               → exit=0
#
# LA LÍNEA DIVISORIA NO ES LA HERRAMIENTA. python, awk, find y node son legítimos
# a diario; bloquearlos por nombre rompería el trabajo normal y entrenaría a
# esquivar el gate (el footgun que este repo ya documenta). Lo que separa el
# rodeo del uso legítimo es LEER EL CONTENIDO de muchos archivos de código:
#
#   find src -name '*.ts'                 → lista NOMBRES   → pasa
#   find src -name '*.ts' -exec cat {} +  → lee CONTENIDOS  → bloquea
#
# Verificado contra 7 usos legítimos (awk sobre /var/log, find -delete, python
# que lee package.json, node -e, pnpm build, find|wc): ninguno bloquea.
CODE_HINT='\.(ts|tsx|js|jsx|mjs|cjs|astro|vue|svelte|py|go|rs|java|kt|rb|php|swift|cs|scala|ex|exs)\b|(^|[[:space:]/'"'"'"])(src|lib|app|services|packages|apps)([[:space:]/'"'"'"]|$)'

# Lectura de contenido EN VOLUMEN. Cada alternativa implica varios archivos:
# un recorrido de directorio (rglob/os.walk/find -exec/xargs) o un comodín que
# expande a muchos (awk '/patrón/' src/*.ts). `readFileSync`/`read_text` sobre UN
# archivo ya identificado NO entra: leer un archivo concreto siempre fue legítimo
# acá, y bloquearlo sería el falso positivo que mata al gate.
READ_MANY='-exec[[:space:]]+(cat|head|tail|grep)\b'
READ_MANY="$READ_MANY"'|\|[[:space:]]*xargs[[:space:]]+(cat|head|grep)\b'
READ_MANY="$READ_MANY"'|rglob|iglob|os\.walk|Files\.walk|glob\.glob'
# awk/perl con un patrón //, o cualquier lectura, sobre un comodín de fuentes.
READ_MANY="$READ_MANY"'|(awk|perl)[[:space:]]+[^|;&]*/[^/]*/[^|;&]*\*'
READ_MANY="$READ_MANY"'|(read_text\(\)|readFileSync|\.read\(\))[^|;&]*\*'
READ_MANY="$READ_MANY"'|\*\.(ts|tsx|js|jsx|py|go|rs|java|kt|rb|php|swift|cs)\b[^|;&]*(read_text|readFileSync|\.read\(\))'

if printf '%s' "$cmd" | grep -qE "$CODE_HINT" \
   && printf '%s' "$cmd" | grep -qE -- "$READ_MANY"; then
  cat >&2 <<'MSG'
🛑 BLOQUEADO (redirect-code-search-to-mcp): leer CÓDIGO en volumen por fuera del índice.

Cambiar de herramienta (python/awk/find/node) no cambia el problema: leer muchos
archivos de código en crudo produce los mismos diagnósticos incompletos que grep
—no ve una dependencia inyectada, ni el docstring tres líneas más arriba—, y
además gasta contexto en texto que el índice ya tiene resuelto.

  ¿quién llama a X? ¿qué rompe si lo cambio?  → trace_path
  ¿dónde está definido X?                     → search_graph / find_symbol
  texto, pero enriquecido con el grafo        → search_code

Esto NO bloquea a python/awk/find en general: sólo cuando LEEN EL CONTENIDO de
archivos de código. Listar nombres (`find src -name "*.ts"`), procesar logs o
JSON, o leer UN archivo ya identificado siguen pasando.
MSG
  mkdir -p "$(dirname "$log")" 2>/dev/null
  printf '%s\t%s\n' "$(date -Is)" "$(printf '%s' "$cmd" | head -c 300)" >> "$log" 2>/dev/null
  exit 2
fi

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

NO hay variable de override: CBM_CHECKED=1 se retiró el 2026-09-19 porque se usaba
como atajo sistemático. Anteponerla no cambia nada — el comando vuelve a fallar.

Las salidas legítimas, que no dependen de tu voluntad:
  · el índice (arriba), que es el camino esperado;
  · un archivo concreto ya identificado, sin recursión ni comodines;
  · texto que no sea código: logs, JSON, YAML, configs, salida de CLIs.
Si ninguna cubre tu caso, pedíselo al dueño: un agente no se auto-autoriza.
MSG
mkdir -p "$(dirname "$log")" 2>/dev/null
printf '%s\t%s\n' "$(date -Is)" "$(printf '%s' "$cmd" | head -c 300)" >> "$log" 2>/dev/null
exit 2

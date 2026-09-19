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
# LA LÍNEA DIVISORIA ES UNO vs MUCHOS, NO EL BINARIO (medido 2026-09-19)
# ----------------------------------------------------------------------
# Una auditoría listó como evasiones `head -100 src/app.ts`, `tail -n +1 …`,
# `bat src/app.ts` y `less src/app.ts`. NO se bloquearon, a propósito: sobre UN
# archivo ya identificado son exactamente el caso que el ALCANCE de arriba
# declara legítimo, y se comportan igual que `cat src/app.ts`, `sed -n 1,50p
# src/app.ts` y `grep handler src/app.ts`, que este gate deja pasar desde
# siempre. Bloquearlos obligaría a bloquear también `cat` y `grep` sobre un
# archivo — o sea, leer código de a un archivo—, que es el falso positivo que
# desactiva el gate y que su propio ALCANCE prohíbe.
#
# Lo que SÍ se cerró de esa familia es el volcado EN VOLUMEN con esos mismos
# binarios, que estaba abierto y sí es lo que el gate existe para frenar:
#   cat src/*.ts · head -100 src/*.ts · bat src/*.ts  → antes 0, ahora 2
#   cat src/{a,b,c}.ts · for f in src/*.ts; do cat …  → antes 0, ahora 2
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

# ── NORMALIZACIÓN ANTES DE EVALUAR (portada de guard-sensitive-exec.sh) ─────
#
# Las tres evasiones que siguen se midieron el 2026-09-19, todas en exit 0, y
# todas atacan la MISMA debilidad: el gate comparaba texto crudo, así que
# cualquier forma de escribir `grep` que el shell entiende pero el patrón no,
# lo rodeaba sin dejar rastro.
#
#   gr''ep -rn handler src/          → el shell ejecuta `grep`; acá llegaban
#                                      las comillas vacías intactas.
#   bash -c 'grep -rn handler src/'  → el comando real vive dentro del string.
#   G=grep; $G -rn handler src/      → el nombre llega por variable.
#
# 1) COMILLAS VACÍAS. El shell elimina `''` y `""` antes de ejecutar: `gr''ep`
#    ES `grep`. Se colapsan acá, y el ORDEN IMPORTA — tiene que ser ANTES de
#    cualquier pasada que borre strings, porque después la comilla vacía ya no
#    existe y en su lugar quedó un espacio (`gr ep`), que no matchea nada. Es
#    la misma corrección que el commit 7de969c7 hizo en el guard de prod.
cmd="$(printf '%s' "$cmd" | sed -E "s/''//g; s/\"\"//g")"

# 2) INTÉRPRETES: `bash -c '…'` y `eval "…"`. El string que recibe un intérprete
#    NO es texto citado, es CÓDIGO que se va a ejecutar. El guard de prod ya
#    resolvía esto en su sección "EXCEPCIÓN A LA NORMALIZACIÓN"; acá se porta el
#    mismo criterio: si aparece un intérprete arrancando un comando, se le
#    quitan las comillas al comando entero para que el patrón vea lo de adentro.
#    Se exige que el intérprete inicie comando (o venga tras separador) para que
#    mencionarlo en un texto —`echo "usá bash -c"`— no dispare.
if printf '%s' "$cmd" | grep -qE '(^|[|;&`]|&&|\|\||\$\()[[:space:]]*(eval|(env[[:space:]]+)?(ba|z|k|da)?sh([[:space:]]+-[^[:space:]]+)*[[:space:]]+-[a-zA-Z]*c)\b'; then
  cmd="$(printf '%s' "$cmd" | tr -d "\"'")"
fi

# 3) ASIGNACIÓN A VARIABLE: `G=grep; $G -rn …`. Se resuelven las asignaciones
#    simples a nombres de herramientas y se sustituye el uso (`$G`, `${G}`).
#    Sólo se expanden valores que son binarios de búsqueda/lectura: expandir
#    variables arbitrarias cambiaría comandos legítimos sin motivo.
for _v in $(printf '%s' "$cmd" \
    | grep -oE '(^|[|;&[:space:]])[A-Za-z_][A-Za-z0-9_]*=(grep|rg|ag|ack|sed|awk|cat|head|tail|bat|less|more|nl)\b' \
    | sed -E 's/^[|;&[:space:]]+//'); do
  _name="${_v%%=*}"; _val="${_v#*=}"
  cmd="$(printf '%s' "$cmd" | sed -E "s/\\\$\{?${_name}\}?/${_val}/g")"
done
unset _v _name _val

# 4) EJECUTAR ≠ NOMBRAR. El mismo invariante que guard-sensitive-exec: lo que va
#    ENTRE COMILLAS es texto, no ejecución. Este hook no tenía esta pasada y por
#    eso `echo "no uses grep -rn handler src/"` y
#    `git commit -m "fix: dejar de usar grep -rn en src/"` bloqueaban — un gate
#    que muerde el trabajo de DOCUMENTARLO es el que se termina desactivando.
#
#    Sólo se descartan los strings que son ARGUMENTO de un comando que no
#    ejecuta (echo/printf/git commit -m/…). El string de un intérprete ya se
#    desenvolvió en el paso 2, así que `bash -c 'grep …'` sigue bloqueando.
#
#    ⚠️ El ORDEN importa y es el mismo que en el guard: las comillas vacías (1)
#    y el desenvuelto del intérprete (2) van ANTES. Borrar strings primero
#    destruiría la información que esos dos pasos necesitan.
if printf '%s' "$cmd" | grep -qE '(^|[|;&]|&&|\|\|)[[:space:]]*(echo|printf)\b' \
   || printf '%s' "$cmd" | grep -qE 'git[[:space:]]+(commit|tag)\b[^|;&]*-[a-zA-Z]*m\b'; then
  cmd="$(printf '%s' "$cmd" | sed -E "s/'[^']*'//g; s/\"[^\"]*\"//g")"
fi

# 4b) EL CUERPO DE UN HEREDOC ES TEXTO QUE SE ESCRIBE, NO COMANDOS.
#
#     Faltaba por completo — los otros dos hooks del sistema (guard-sensitive-exec,
#     block-harness-memory) ya descartan cuerpos de heredoc y éste no. Medido el
#     2026-09-19, bloqueando un `git commit` real:
#
#       cat > /tmp/msg.txt <<EOF
#         grep -oE "…" infra/terraform/envs/prod/main.tf   → exit 2
#       EOF
#       git commit -F /tmp/msg.txt
#
#     El comando NO busca nada: escribe un mensaje de commit que DESCRIBE una
#     búsqueda. Es el mismo defecto que el paso (4) ya corrigió para `echo` y
#     `git commit -m` —"un gate que muerde el trabajo de documentarlo es el que se
#     termina desactivando"— pero por la vía del heredoc, que es justamente cómo
#     se escriben los mensajes largos en este repo.
#
#     ⚠️ EXCEPCIÓN: un heredoc dirigido a un INTÉRPRETE (`bash <<EOF … EOF`) SÍ
#     es ejecución, y hay que saltear esta pasada ahí. El paso (2) NO lo cubre:
#     sólo reconoce `bash -c`, no `bash <<`. Al escribir este bloque se afirmó en
#     un comentario que (2) "ya lo desenvolvió antes" — era FALSO, y descartar el
#     cuerpo abrió un agujero real (medido: `bash <<EOF / grep -rn services/ /
#     EOF` → exit 0). El comentario equivocado duró lo que tardó la prueba en
#     correr, que es la razón por la que estos casos están versionados.
if ! printf '%s' "$cmd" | grep -qE '(^|[|;&]|&&|\|\|)[[:space:]]*((ba|z|k|da)?sh|python[0-9.]*|node|perl|ruby)\b[^|;&]*<<'; then
cmd="$(printf '%s' "$cmd" | awk '
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
')"
[ -z "${cmd//[[:space:]]/}" ] && exit 0
fi

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
# Bucle de shell que recorre fuentes: `for f in src/*.ts; do cat "$f"; done`.
READ_MANY="$READ_MANY"'|for[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]]+in[[:space:]][^;]*\*'
# Expansión de llaves sobre fuentes: `cat src/{a,b,c}.ts` — un solo comando,
# varios archivos. El shell la expande; el patrón de comodín no la veía.
READ_MANY="$READ_MANY"'|(cat|head|tail|bat|less|more|nl)[[:space:]][^|;&]*\{[^}]*,[^}]*\}'
# Volcado por COMODÍN: `cat src/*.ts`, `head -100 services/**/*.ts`, `bat src/*.ts`.
# Es el mismo volcado en volumen que ya se bloquea vía find/xargs, pero escrito
# con la expansión del shell. Medido el 2026-09-19 en exit 0.
#
# ⚠️ EXIGE EL COMODÍN. `head -100 src/app.ts` sobre UN archivo ya identificado
# sigue pasando, igual que `cat src/app.ts` y `grep handler src/app.ts`: leer un
# archivo concreto es legítimo y está en el ALCANCE de este hook. La línea
# divisoria es UNO vs MUCHOS, no el binario.
READ_MANY="$READ_MANY"'|(cat|head|tail|bat|less|more|nl)[[:space:]][^|;&]*\*[^|;&]*\.(ts|tsx|js|jsx|mjs|cjs|astro|vue|svelte|py|go|rs|java|kt|rb|php|swift|cs|scala|ex|exs)\b'

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
#
# `services` y `packages` se agregaron el 2026-09-19: son los directorios REALES
# de este monorepo y faltaban, así que `grep -rn handler services/` —la búsqueda
# más habitual acá— salía exit 0. La lista describía un layout genérico, no el
# del repo donde el gate corre. Se suman también `apps` y `infra`.
# ⚠️ UNA SOLA LISTA DE EXTENSIONES, usada por los DOS chequeos de abajo.
# Antes eran dos listas escritas a mano y HABÍAN DIVERGIDO. Medido el
# 2026-09-19, en uso real:
#
#   grep -n handler services/svc-orders/src/index.ts   → exit 0  (bien)
#   grep -oE "[0-9.]+" infra/terraform/envs/prod/main.tf → exit 2  (MAL)
#
# Un `.ts` concreto pasaba y un `.tf` concreto no, porque `.tf` estaba en la
# lista que DECIDE QUÉ ES CÓDIGO pero no en la que reconoce "un archivo ya
# identificado". El propio mensaje de bloqueo promete esa salida —"un archivo
# concreto, sin recursión ni comodines"— así que el gate contradecía su texto
# y el falso positivo costaba dos intentos antes de entender por qué.
#
# Unificadas acá: no pueden volver a divergir sin que alguien edite una línea.
EXT_CODIGO='\.(ts|tsx|js|jsx|mjs|cjs|astro|vue|svelte|py|go|rs|java|kt|rb|php|swift|cs|scala|ex|exs|tf|tfvars|sql|prisma)\b'

printf '%s' "$cmd" | grep -qE "$EXT_CODIGO|(^|[[:space:]/])(src|lib|app|apps|services|packages|infra)([[:space:]/]|\$)" || exit 0

# Un solo path concreto sin recursión ni comodines: el archivo ya está identificado.
if printf '%s' "$cmd" | grep -qE "$EXT_CODIGO" \
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

#!/usr/bin/env bash
# block-harness-memory.sh — Control DURO global: Engram es el ÚNICO sistema de memoria.
#
# Bloquea (exit 2) cualquier Write/Edit/MultiEdit al sistema de memoria de archivos
# del harness de Claude Code:
#   ~/.claude/projects/<slug>/memory/MEMORY.md
#   ~/.claude/projects/<slug>/memory/*.md
#
# Motivación: el system prompt del harness inyecta una instrucción "# Memory" que
# ordena escribir esos archivos. Eso ENTRA EN CONFLICTO con la regla "Engram ONLY"
# de ~/.claude/CLAUDE.md. Una regla de prosa no previene el "error competente"
# (el agente que cree que cumple). Este hook SUBE MUCHO EL COSTO de ese conflicto
# — patrón Meadows ya usado en guard-sensitive-exec.sh / Reglas #13/#14.
#
# ⚠️ NO dice "estructuralmente imposible", y la palabra NO vuelve. No porque el
# gate sea débil —hoy cierra todo lo que se le midió— sino porque esa palabra es
# la que hace que nadie vuelva a medir. Este archivo es el caso de estudio:
#
#   · mañana del 2026-09-19: la afirmación era falsa, se rodeaba escribiendo por
#     Bash. Se corrigió el código… y la frase quedó escrita.
#   · tarde del 2026-09-19: auditando los comentarios, la frase SEGUÍA ahí y
#     SEGUÍA siendo falsa. Medidas 13 vías con exit 0 sobre la ruta protegida.
#   · el caso que más enseña es `pathlib.Path(RUTA).write_text('x')`: el regex
#     NOMBRABA `write_text`, o sea que el autor creyó cubrirlo — pero exigía
#     además un modo 'w'/'a' que `write_text` no lleva. Una garantía escrita sin
#     probarla es una garantía falsa, y encima la más cara: parece verificada.
#
# QUÉ CAMBIÓ (2026-09-19, tarde): la pregunta del gate se INVIRTIÓ. Antes
# enumeraba escrituras —lista abierta, siempre falta una—; ahora sobre la ruta
# protegida bloquea por defecto y sólo deja pasar la lista CERRADA de lecturas,
# que es justamente la excepción que la regla documenta. El detalle está en el
# bloque "POR QUÉ LA PREGUNTA ESTÁ INVERTIDA", más abajo.
#
# ESTADO MEDIDO (no "imposible": medido, con fecha y suite reproducible):
#   27 casos en exit 2   ·   15 usos legítimos → exit 0   (42 casos en total)
#   incluidas las 13 que pasaban, más intérpretes (python/node/perl), comillas
#   vacías (`to''uch`), continuación de línea, `bash -c`, y el modo sin jq.
#
# El número sale de CONTAR el archivo de casos, no de recordarlo: son las clases
# EVA (23, vías que se midieron pasando) + BLK (4) de
# tests/casos-block-harness-memory.txt. La primera versión de esta línea decía
# "23 vías de escritura" porque contó sólo EVA y olvidó BLK. Se corrige el
# 2026-09-19 (tarde) corriendo la suite:
#   ./tests/run-suite.sh ./block-harness-memory.sh tests/casos-block-harness-memory.txt
#   → 42/42, sin desvíos.
#
# Y ya no dice "vías de ESCRITURA": de los 4 BLK, tres lo son (`echo x >`, su
# append, `cat otro >`) pero el cuarto es una LECTURA por intérprete
# (`python3 -c "open(RUTA).read()"`) que bloquea igual. No es un defecto: es la
# consecuencia deliberada de la pregunta invertida —sobre la ruta protegida sólo
# pasa la lista CERRADA de lecturas, y un intérprete no está en ella—. Se dice
# acá porque "27 vías de escritura" habría vuelto a ser una etiqueta que no
# describe lo que el archivo contiene.
# Si mañana aparece una vía nueva, se agrega a la suite y se cierra. Lo que no
# se hace es volver a escribir que es imposible.
#
# Read NO se bloquea (el usuario puede pedir leer un archivo viejo sin migrar aún).
# Override consciente y auditable: export ENGRAM_MIGRATION=1 (para migrar/limpiar
# esos archivos a mano), NUNCA un bypass silencioso.

set -uo pipefail

# Override explícito para tareas de migración/limpieza del propio directorio.
if [[ "${ENGRAM_MIGRATION:-}" == "1" ]]; then
  exit 0
fi

# Leer el payload del hook (JSON por stdin).
input="$(cat 2>/dev/null || true)"

# Extraer el path destino del tool_input. Cubre Write (file_path),
# Edit/MultiEdit (file_path). jq si está disponible; fallback a grep.
target=""
if command -v jq >/dev/null 2>&1; then
  target="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || true)"
fi
if [[ -z "$target" ]]; then
  # Fallback sin jq: extraer "file_path":"..." del JSON crudo.
  target="$(printf '%s' "$input" | grep -oE '"(file_path|path)"[[:space:]]*:[[:space:]]*"[^"]+"' | head -1 | sed -E 's/.*:[[:space:]]*"([^"]+)"/\1/' || true)"
fi

# La ruta protegida vive en UNA variable: es LA POLÍTICA, y no cambia acá.
#   .../.claude/projects/<algo>/memory/...  con archivo .md  (incluye MEMORY.md)
MEM_RE='\.claude/projects/[^/]+/memory/[^[:space:]"'"'"'<>|;&]*\.md'
# El mismo DIRECTORIO, sin exigir el archivo: hace falta para el caso
# `cd .../memory && … MEMORY.md`, donde el nombre queda suelto porque el
# directorio viajó en el `cd`.
#
# El cierre acepta también un separador de shell (`;` `|` `&`), no sólo `/`,
# espacio o fin de línea. Sin él, `D=…/memory; echo x > $D/MEMORY.md` no
# matcheaba —el `;` pegado al directorio no estaba contemplado— y todo el bloque
# de resolución de rutas se salteaba en silencio.
MEM_DIR_RE='\.claude/projects/[^/]+/memory(/|[[:space:]]|[;|&]|$)'

# ── EL HUECO QUE ESTO CIERRA (medido el 2026-09-19) ─────────────────────────
# Este hook estaba registrado sólo en `Write|Edit|MultiEdit`. Una escritura hecha
# desde Bash no pasaba por acá. Probado contra un mock en /tmp con la MISMA
# estructura de ruta:
#
#   python3 - <<PY  →  open(".../memory/MEMORY.md","w")   → hook exit=0, archivo escrito
#   cat > .../memory/MEMORY.md <<EOF                      → hook exit=0, archivo escrito
#
# El encabezado de este archivo decía que la regla era "estructuralmente
# imposible" de violar. No lo era: se rodeaba cambiando de herramienta.
#
# ── POR QUÉ LA PREGUNTA ESTÁ INVERTIDA (corrección 2026-09-19, tarde) ───────
#
# La versión de la mañana preguntaba «¿hay un operador de ESCRITURA?» y enumeraba
# los que se le ocurrieron: `>`, `sed -i`, `tee`, `cp|mv`, y una apertura en modo
# 'w'. Esa lista se quedó corta al instante. Medido ejecutando el hook, 13 vías
# que salían 0 sobre la ruta protegida:
#
#   python3 …Path(RUTA).write_text('x')     ← el regex NOMBRABA write_text, pero
#                                             exigía además un modo 'w'/'a' que
#                                             write_text no lleva. El autor creyó
#                                             cubrirlo, y es el caso que más
#                                             enseña: una garantía escrita sin
#                                             probarla es una garantía falsa.
#   cd …/memory && echo x > MEMORY.md       ← el `cd` se llevó el directorio y la
#                                             ruta quedó relativa: no matcheaba
#   D=…/memory; echo x > $D/MEMORY.md       ← lo mismo, vía variable
#   dd of= · truncate · install · rsync · ln -sf · touch · vim -c wq ·
#   node writeFileSync · perl -i · git checkout -- RUTA
#
# ENUMERAR ESCRITURAS ES UNA LISTA ABIERTA: todo intérprete, todo editor y todo
# comando de copia escribe archivos, y siempre falta uno. Este repo ya pagó el
# mismo error dos veces el mismo día — el catálogo de verbos de `tofu`, que
# ignoraba `destroy`; y la lista `mysql|psql`, que ignoraba `mysqldump`.
#
# LEER, EN CAMBIO, ES UNA LISTA CERRADA. Y es exactamente la excepción que la
# regla documenta: un archivo viejo sin migrar SE PUEDE LEER. Así que la pregunta
# correcta no es «¿esto escribe?» sino «¿esto es INEQUÍVOCAMENTE una lectura?».
# Sobre la ruta protegida se bloquea por defecto y sólo pasa lo que entra en la
# lista de lectores. El agente que invente una forma nueva de escribir choca con
# el gate sin que nadie la haya previsto — eso es fallar cerrado.
#
# El precio es el falso positivo: una lectura con un comando fuera de la lista se
# bloquea. Es barato y CONSERVADOR (el mensaje dice cómo leer, y cat/head/grep/
# git log cubren el uso real), y es el error correcto: el daño de dejar pasar una
# escritura es la memoria del proyecto partida en dos sistemas.
if [[ -z "$target" ]]; then
  cmd=""
  if command -v jq >/dev/null 2>&1; then
    cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
  fi
  # ── FALLBACK SIN jq: extraer "command" con sed, NO usar el payload crudo.
  #
  # Acá decía `cmd="$input"`. Medido al agregar la pasada de normalización: el
  # payload crudo es JSON, o sea que está TODO entre comillas dobles, y el awk que
  # borra strings lo dejaba en `{ :{ : }}` — el comando desaparecía y el hook
  # salía 0. Sin jq el gate no era "más ruidoso": era INERTE.
  #
  #   sin jq:  touch …/memory/MEMORY.md   → exit 0   (debía ser 2)
  #
  # Es literalmente el mismo defecto que guard-sensitive-exec.sh ya había medido
  # y corregido en su propio fallback — la corrección no se había portado acá.
  # Último recurso: neutralizar las comillas del payload para que el texto
  # ejecutable sobreviva a la normalización en vez de ser borrado con ellas.
  if [[ -z "$cmd" ]]; then
    cmd="$(printf '%s' "$input" \
      | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(\([^"\\]\|\\.\)*\)".*/\1/p' \
      | head -1)"
    [[ -n "$cmd" ]] && cmd="$(printf '%b' "${cmd//\\\"/\"}" 2>/dev/null || printf '%s' "$cmd")"
    [[ -z "$cmd" ]] && cmd="$(printf '%s' "$input" | tr '"' ' ')"
  fi
  [[ -z "$cmd" ]] && exit 0

  # ── EJECUTAR ≠ NOMBRAR (portado de guard-sensitive-exec.sh, 2026-09-19).
  #
  # Invertir la pregunta —bloquear salvo lectura— trajo el falso positivo que ya
  # tenían los otros gates: MENCIONAR la ruta pasó a bloquear.
  #   echo "no escribas en …/memory/MEMORY.md"   → exit 2   (debía pasar)
  # Es el mismo defecto que block-silent-grep-glob-failure.sh tenía: no se puede
  # escribir el texto que documenta el gate sin que el gate lo muerda. Y un gate
  # que muerde el trabajo de escribir y medir se termina desactivando.
  #
  # Se descartan heredocs, strings entrecomillados y comentarios: ahí vive TEXTO,
  # no ejecución. Dos detalles que NO son de implementación sino parte del control:
  #
  #   1. Las comillas VACÍAS se colapsan ANTES del awk que borra strings. El shell
  #      las elimina antes de ejecutar —`ca''t` ES `cat`— pero si se hace después,
  #      el borrado de strings ya las convirtió en un ESPACIO (`ca t`, dos
  #      palabras) y no hay match. El orden es el control.
  #   2. El string que recibe un INTÉRPRETE (`bash -c '…'`, `eval`, heredoc a sh)
  #      NO es texto, es código: ahí se evalúa el comando CRUDO. Es el único
  #      agujero que esta pasada puede abrir, y se cierra sin abrirlo.
  #
  # ⚠️ LA LISTA DE INTÉRPRETES NO ES SÓLO LA SHELL. Medido al portar esta pasada:
  # cubrir únicamente `bash -c`/`eval`/`sh <<` REGRESIONÓ los tres casos de
  # intérprete que ya estaban cerrados, porque la ruta viaja DENTRO de comillas y
  # el borrado de strings se la llevó:
  #
  #   python3 -c "…Path(RUTA).write_text('x')"   → volvía a exit 0
  #   node -e "…writeFileSync('RUTA','x')"       → volvía a exit 0
  #   perl -e 'open(F,">","RUTA")'               → volvía a exit 0
  #
  # Es la misma trampa que este archivo documenta arriba, un nivel más adentro:
  # `sh` no es la clase, "programa que ejecuta el string que le pasás" sí lo es.
  # Por eso van también python/node/perl/ruby/php y sus banderas -c/-e.
  if printf '%s' "$cmd" | grep -qE '(^|[|;&`]|&&|\|\||\$\()[[:space:]]*(eval|(env[[:space:]]+)?(ba|z|k|da)?sh([[:space:]]+-[^[:space:]]+)*[[:space:]]+-[a-zA-Z]*c)\b' \
     || printf '%s' "$cmd" | grep -qE '(^|[|;&`]|&&|\|\||\$\()[[:space:]]*(python[0-9.]*|node|perl|ruby|php|deno|bun)\b([[:space:]]+-[^[:space:]]+)*[[:space:]]+-[a-zA-Z]*[ce]\b' \
     || printf '%s' "$cmd" | grep -qE '(^|[|;&]|&&|\|\|)[[:space:]]*((ba|z|k|da)?sh|python[0-9.]*|node|perl|ruby)\b[^|;&]*<<'; then
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
    # Continuación de línea: `touch \<newline> RUTA` es UN comando para el shell
    # pero dos líneas para grep, y la ruta quedaba huérfana del verbo.
    cmd="$(printf '%s' "$cmd" | tr '\n' ' ' | sed -E 's/\\[[:space:]]+/ /g; s/[[:space:]]+/ /g')"
    [[ -z "${cmd//[[:space:]]/}" ]] && exit 0
  fi

  # ── (0) RESOLVER LA RUTA ANTES DE BUSCARLA.
  # El directorio protegido puede viajar por fuera del nombre del archivo: en un
  # `cd`, o en una variable. Se arma una copia del comando con esas dos
  # indirecciones deshechas, y esa copia se usa SÓLO para decidir.
  #   cd …/memory && echo x > MEMORY.md   →  … > …/memory/MEMORY.md
  #   D=…/memory; echo x > $D/MEMORY.md   →  … > …/memory/MEMORY.md
  probe="$cmd"
  if printf '%s' "$cmd" | grep -qE "$MEM_DIR_RE"; then
    # `cd <dir protegido>`: cualquier *.md suelto que venga después cuelga de ahí.
    if printf '%s' "$cmd" | grep -qE "(^|[|;&]|&&)[[:space:]]*cd[[:space:]]+[^|;&]*$MEM_DIR_RE"; then
      probe="$(printf '%s' "$probe" | sed -E 's#(^|[^/[:alnum:]_.-])([A-Za-z0-9_.-]+\.md)#\1.claude/projects/x/memory/\2#g')"
    fi
    # Asignación a variable (`D=<dir protegido>`) y uso posterior de `$D` / `${D}`.
    # NO se reusa MEM_DIR_RE acá: termina en `(/|espacio|fin)`, y en `D=…/memory;`
    # el valor lo corta el `;` que la propia clase `[^[:space:];|&]*` ya excluyó,
    # así que la alternación no podía cerrar. Se ancla con `/?` en su lugar.
    var="$(printf '%s' "$cmd" | grep -oE "[A-Za-z_][A-Za-z0-9_]*=[^[:space:];|&]*\.claude/projects/[^/]+/memory/?" | head -1 | cut -d= -f1)"
    if [[ -n "$var" ]]; then
      probe="$(printf '%s' "$probe" | sed -E "s#\\\$\{?${var}\}?#.claude/projects/x/memory#g")"
    fi
  fi

  # (1) ¿Está involucrada la ruta protegida? Si no, no es nuestra incumbencia.
  printf '%s' "$probe" | grep -qE "$MEM_RE" || exit 0

  # (2) ¿Es INEQUÍVOCAMENTE una lectura? Lista cerrada, y la única salida.
  #
  # Se exige que el comando ENTERO sea de lectura: que arranque con un verbo de
  # la lista y que NO haya ninguna redirección hacia la ruta protegida. Así
  # `cat RUTA` pasa y `cat /tmp/a.md > RUTA` no, aunque los dos empiecen igual.
  #
  # `grep` entra por el uso real —buscar dentro del archivo viejo— y no abre un
  # hueco: grep no escribe el archivo que lee.
  LECTORES='cat|head|tail|less|more|wc|grep|egrep|fgrep|rg|nl|file|stat|md5sum|sha256sum|sha1sum|ls|diff|cmp|realpath|dirname|basename|jq|awk|sed'
  es_lectura=0
  if printf '%s' "$probe" | grep -qE "^[[:space:]]*($LECTORES)([[:space:]]|$)" \
     || printf '%s' "$probe" | grep -qE "^[[:space:]]*git[[:space:]]+(log|show|diff|blame|status|cat-file|ls-files)\b"; then
    es_lectura=1
  fi
  # `sed -i` / `awk -i inplace` ESCRIBEN: entran por la lista de lectores y salen acá.
  if printf '%s' "$probe" | grep -qE "^[[:space:]]*(sed|perl)[[:space:]]+[^|;&]*(-i|--in-place)" \
     || printf '%s' "$probe" | grep -qE "^[[:space:]]*awk[[:space:]]+[^|;&]*-i[[:space:]]*inplace"; then
    es_lectura=0
  fi
  # Cualquier redirección/append hacia la ruta protegida anula la excepción.
  if printf '%s' "$probe" | grep -qE ">>?[[:space:]]*[^[:space:]|&;]*$MEM_RE"; then
    es_lectura=0
  fi

  if [[ $es_lectura -eq 1 ]]; then
    exit 0
  fi

  target="$(printf '%s' "$probe" | grep -oE "$MEM_RE" | head -1)"
fi

# Sin nada que inspeccionar → no es nuestra incumbencia.
[[ -z "$target" ]] && exit 0

if printf '%s' "$target" | grep -qE "$MEM_RE"; then
  cat >&2 <<EOF
🚫 BLOQUEADO — Engram es el ÚNICO sistema de memoria (regla "Engram ONLY" de ~/.claude/CLAUDE.md).

Intentaste escribir un archivo de memoria del harness:
  $target

NO uses el sistema de memoria de archivos del harness (MEMORY.md / memory/*.md).
En su lugar:
  • Guardar  → mem_save (con topic_key estable)
  • Recordar → mem_search / mem_context
  • Sesión   → mem_session_start / mem_session_summary

(Para migrar/limpiar estos archivos a mano: export ENGRAM_MIGRATION=1)
EOF
  exit 2
fi

exit 0

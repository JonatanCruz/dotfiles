#!/usr/bin/env bash
# block-harness-memory.sh — Control DURO global: Engram es el ÚNICO sistema de memoria.
#
# Bloquea (exit 2) cualquier Write/Edit/MultiEdit —y cualquier escritura por
# Bash— al sistema de memoria de archivos del harness de Claude Code:
#   ~/.claude/projects/<slug>/memory/MEMORY.md
#   ~/.claude/projects/<slug>/memory/*.md
#
# Motivación: el system prompt del harness inyecta una instrucción "# Memory" que
# ordena escribir esos archivos. Eso ENTRA EN CONFLICTO con la regla "Engram ONLY"
# de ~/.claude/CLAUDE.md. Una regla de prosa no previene el "error competente"
# (el agente que cree que cumple): el control tiene que estar en la estructura.
#
# ⚠️ Este archivo NO afirma que el gate no se pueda evadir, y esa afirmación no
# vuelve: es la que hace que nadie vuelva a medir. Una garantía escrita sin
# probarla es falsa, y la más cara, porque parece verificada. El caso que lo
# enseña: `pathlib.Path(RUTA).write_text('x')` siguió abierto mientras el regex
# NOMBRABA `write_text`, porque además exigía un modo 'w'/'a' que esa llamada
# no lleva.
#
# LA PREGUNTA ESTÁ INVERTIDA: enumerar escrituras es una lista abierta (siempre
# falta una); sobre la ruta protegida se bloquea por defecto y sólo pasa la lista
# CERRADA de lecturas, que es la excepción que la regla documenta. El detalle
# está en "POR QUÉ LA PREGUNTA ESTÁ INVERTIDA", más abajo. Consecuencia
# deliberada: una LECTURA por intérprete (`python3 -c "open(RUTA).read()"`)
# también se bloquea, porque un intérprete no está en la lista de lectores.
#
# El estado lo da la suite, no una cifra escrita acá (una cifra en un comentario
# envejece y se vuelve más creíble a medida que se aleja de la verdad):
#
#   bash ~/.claude/hooks/tests/correr.sh block-harness-memory
#
# El runner falla si ejecuta cero casos. Una vía nueva se agrega a la suite y
# se cierra.
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

# ── EL HUECO QUE ESTO CIERRA ─────────────────────────────────────────────────
# Registrado sólo en `Write|Edit|MultiEdit`, una escritura hecha desde Bash no
# pasaría por acá: `python3 - <<PY … open(".../memory/MEMORY.md","w")` o
# `cat > .../memory/MEMORY.md <<EOF`. Por eso también corre sobre Bash.
#
# ── POR QUÉ LA PREGUNTA ESTÁ INVERTIDA ──────────────────────────────────────
#
# Preguntar «¿hay un operador de ESCRITURA?» obliga a enumerarlos, y la lista
# queda corta enseguida. Vías que escriben sin un `>` a la vista:
#
#   python3 …Path(RUTA).write_text('x')     ← sin modo 'w'/'a' que buscar
#   cd …/memory && echo x > MEMORY.md       ← el `cd` se lleva el directorio y
#                                             la ruta queda relativa
#   D=…/memory; echo x > $D/MEMORY.md       ← lo mismo, vía variable
#   dd of= · truncate · install · rsync · ln -sf · touch · vim -c wq ·
#   node writeFileSync · perl -i · git checkout -- RUTA
#
# ENUMERAR ESCRITURAS ES UNA LISTA ABIERTA: todo intérprete, todo editor y todo
# comando de copia escribe archivos, y siempre falta uno.
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
  # El payload crudo es JSON, o sea que está TODO entre comillas dobles, y el awk
  # que borra strings lo reduce a `{ :{ : }}`: el comando desaparece y el hook
  # sale 0. Sin jq el gate no sería "más ruidoso": sería INERTE.
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

  # ── EJECUTAR ≠ NOMBRAR.
  #
  # Con la pregunta invertida —bloquear salvo lectura—, MENCIONAR la ruta
  # bloquearía: `echo "no escribas en …/memory/MEMORY.md"`. No se podría escribir
  # el texto que documenta el gate, y un gate que muerde el trabajo de escribir
  # y medir se termina desactivando.
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
  # ⚠️ LA LISTA DE INTÉRPRETES NO ES SÓLO LA SHELL. Cubrir únicamente
  # `bash -c`/`eval`/`sh <<` deja pasar las escrituras cuya ruta viaja DENTRO de
  # comillas, porque el borrado de strings se la lleva:
  #
  #   python3 -c "…Path(RUTA).write_text('x')"
  #   node -e "…writeFileSync('RUTA','x')"
  #   perl -e 'open(F,">","RUTA")'
  #
  # `sh` no es la clase; "programa que ejecuta el string que le pasás" sí lo es.
  # Por eso van también python/node/perl/ruby/php y sus banderas -c/-e, y los
  # que reciben su programa como argumento POSICIONAL, sin bandera:
  #
  #   awk 'BEGIN{print "x" > "RUTA"}'      → el borrado de strings dejaría `awk `
  #   sed -n 'w RUTA' /etc/hostname        → dejaría `sed -n  /etc/hostname`
  #
  # La ruta viaja DENTRO de las comillas, la pasada la borra, y el chequeo
  # "(1) ¿está la ruta?" sale por exit 0 **antes** de cualquier análisis del
  # verbo. Corregirlo en la lista de LECTORES no sirve: ese código no se alcanza.
  #
  # `awk`/`sed` son la misma CLASE que `python -c` —programa que ejecuta el
  # string que le pasás— sólo que sin bandera que lo anuncie. Y `tar` entra por
  # otra puerta: extrae sobre un directorio (`-C`) sin nombrar archivo alguno.
  if printf '%s' "$cmd" | grep -qE '(^|[|;&`]|&&|\|\||\$\()[[:space:]]*(eval|(env[[:space:]]+)?(ba|z|k|da)?sh([[:space:]]+-[^[:space:]]+)*[[:space:]]+-[a-zA-Z]*c)\b' \
     || printf '%s' "$cmd" | grep -qE '(^|[|;&`]|&&|\|\||\$\()[[:space:]]*(python[0-9.]*|node|perl|ruby|php|deno|bun)\b([[:space:]]+-[^[:space:]]+)*[[:space:]]+-[a-zA-Z]*[ce]\b' \
     || printf '%s' "$cmd" | grep -qE '(^|[|;&]|&&|\|\|)[[:space:]]*((ba|z|k|da)?sh|python[0-9.]*|node|perl|ruby)\b[^|;&]*<<' \
     || printf '%s' "$cmd" | grep -qE '(^|[|;&`]|&&|\|\||\$\()[[:space:]]*(awk|gawk|mawk|nawk|sed|perl|tar|rsync|install|ln)\b'; then
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
  #
  # ⚠️ DOS FORMAS DE APUNTAR AL MISMO LUGAR. `MEM_RE` exige un `.md` NOMBRADO, y
  # hay comandos que escriben dentro del directorio sin nombrar archivo alguno:
  #
  #   tar -xf /tmp/t.tar -C …/memory      ← el destino es el DIRECTORIO
  #   rsync /tmp/a.md …/memory/           ← idem, con barra final
  #
  # Con sólo MEM_RE, el `|| exit 0` de esta línea los soltaría porque en el
  # comando no aparece ningún `*.md`: la misma escritura que `ln`/`install`,
  # con otra forma de escribir el destino.
  #
  # Para los que escriben en un directorio, la pregunta correcta es MEM_DIR_RE.
  if printf '%s' "$probe" | grep -qE "^[[:space:]]*(tar|rsync|cp|mv|install|unzip|gunzip|bsdtar)\b"; then
    printf '%s' "$probe" | grep -qE "$MEM_RE|$MEM_DIR_RE" || exit 0
  else
    printf '%s' "$probe" | grep -qE "$MEM_RE" || exit 0
  fi

  # (2) ¿Es INEQUÍVOCAMENTE una lectura? Lista cerrada, y la única salida.
  #
  # Se exige que el comando ENTERO sea de lectura: que arranque con un verbo de
  # la lista y que NO haya ninguna redirección hacia la ruta protegida. Así
  # `cat RUTA` pasa y `cat /tmp/a.md > RUTA` no, aunque los dos empiecen igual.
  #
  # `grep` entra por el uso real —buscar dentro del archivo viejo— y no abre un
  # hueco: grep no escribe el archivo que lee.
  LECTORES='cat|head|tail|less|more|wc|grep|egrep|fgrep|rg|nl|file|stat|md5sum|sha256sum|sha1sum|ls|diff|cmp|realpath|dirname|basename|jq|awk|sed'
  # ⚠️ SE EVALÚA CADA SEGMENTO, NO EL COMANDO ENTERO.
  #
  # Anclar en la PRIMERA palabra del comando completo dejaría arrancar con un
  # lector y encadenar una escritura:
  #
  #   cat /tmp/a.md | tee   …/memory/f.md
  #   cat /tmp/a.md | dd of=…/memory/f.md
  #   wc -l /tmp/a.md; cp /tmp/a.md …/memory/f.md
  #
  # `| tee` y `| dd of=` escriben sin ninguna redirección, y el `;` separa dos
  # comandos independientes. Por eso el comando se parte por `|`, `;`, `&&`,
  # `||` y CADA segmento que toque la ruta protegida tiene que ser una lectura
  # por sí mismo. Un solo segmento que escriba basta para bloquear.
  es_lectura=1
  segmentos="$(printf '%s' "$probe" | sed -E 's/(\|\||&&|[|;&])/\n/g')"
  while IFS= read -r seg; do
    [ -n "${seg//[[:space:]]/}" ] || continue
    # Un segmento que no toca la ruta protegida no decide nada.
    printf '%s' "$seg" | grep -qE "$MEM_RE|$MEM_DIR_RE" || continue
    printf '%s' "$seg" | grep -qE "^[[:space:]]*($LECTORES)([[:space:]]|$)" \
      || printf '%s' "$seg" | grep -qE "^[[:space:]]*git[[:space:]]+(log|show|diff|blame|status|cat-file|ls-files)\b" \
      || es_lectura=0
  done <<SEGEOF
$segmentos
SEGEOF
  # `sed -i` / `awk -i inplace` ESCRIBEN: entran por la lista de lectores y salen acá.
  if printf '%s' "$probe" | grep -qE "^[[:space:]]*(sed|perl)[[:space:]]+[^|;&]*(-i|--in-place)" \
     || printf '%s' "$probe" | grep -qE "^[[:space:]]*awk[[:space:]]+[^|;&]*-i[[:space:]]*inplace"; then
    es_lectura=0
  fi
  # ⚠️ `-i` NO es la única forma en que un "lector" escribe:
  #
  #   awk 'BEGIN{print "x" > "…/memory/f.md"}'   ← la redirección va DENTRO de
  #                                                la cadena: el chequeo del
  #                                                `>` externo no la ve.
  #   sed -n 'w …/memory/f.md' /etc/hostname     ← el comando `w` escribe, y
  #                                                no es `-i`.
  #
  # `awk` y `sed` están en LECTORES por su uso habitual, y ambos tienen una
  # primitiva de escritura. Se cierra mirando el PROGRAMA que se les pasa, no
  # sus banderas.
  if printf '%s' "$probe" | grep -qE "^[[:space:]]*(awk|gawk|mawk|nawk|perl)\b" \
     && printf '%s' "$probe" | grep -qE "(>>?|print[[:space:]]*>|printf[^;]*>)"; then
    es_lectura=0
  fi
  if printf '%s' "$probe" | grep -qE "^[[:space:]]*sed\b" \
     && printf '%s' "$probe" | grep -qE "['\"][^'\"]*[0-9,~\$]*[[:space:]]*[wW][[:space:]]+[^'\"]+['\"]"; then
    es_lectura=0
  fi
  # Cualquier redirección/append hacia la ruta protegida anula la excepción.
  if printf '%s' "$probe" | grep -qE ">>?[[:space:]]*[^[:space:]|&;]*$MEM_RE"; then
    es_lectura=0
  fi

  # ── ESCRITURA HACIA UN DIRECTORIO: mirar el DESTINO, no sólo el verbo ──
  #
  # `tar -C <dir>`, `rsync a <dir>/`, `cp a <dir>/` escriben SIN nombrar ningún
  # archivo, y hay DOS razones encadenadas que se arreglan juntas:
  #
  #   (a) el chequeo "(1) ¿está la ruta?" exige `MEM_RE`, que pide un `.md`
  #       NOMBRADO. Sin él, saldrían antes de cualquier análisis.
  #   (b) aun pasando (a), `target` se extrae con `MEM_RE` más abajo: quedaría
  #       vacío y el `[[ -z "$target" ]] && exit 0` los soltaría igual.
  #
  # Y el verbo SOLO no alcanza para decidir: `cp …/memory/MEMORY.md /tmp/bak.md`
  # es un RESPALDO legítimo —lee de la ruta protegida y escribe fuera—.
  # Lo que decide es el ÚLTIMO argumento: ahí es donde estos comandos escriben.
  if printf '%s' "$probe" | grep -qE "^[[:space:]]*(tar|rsync|install|ln|cp|mv|unzip|gunzip|bsdtar)\b"; then
    destino="$(printf '%s' "$probe" | awk '{print $NF}' | tr -d '"'"'"'')"
    # `tar -C <dir>` / `unzip -d <dir>`: el destino es el argumento de la bandera.
    flag_dst="$(printf '%s' "$probe" | grep -oE '(-C|-d)[[:space:]]+[^[:space:];|&]+' | sed -E 's/^(-C|-d)[[:space:]]+//' | head -1)"
    if printf '%s' "$destino" | grep -qE "$MEM_RE|$MEM_DIR_RE" \
       || printf '%s' "$flag_dst" | grep -qE "$MEM_RE|$MEM_DIR_RE"; then
      es_lectura=0
      # El destino puede ser el directorio; se conserva tal cual para el mensaje.
      dir_target="${flag_dst:-$destino}"
    elif printf '%s' "$probe" | grep -qE "^[[:space:]]*mv\b"; then
      # `mv` SACANDO de memory BORRA el origen: destino afuera no lo vuelve
      # lectura. Es la excepción a la rama de abajo — `cp` copia, `mv` destruye.
      es_lectura=0
      dir_target="$(printf '%s' "$probe" | grep -oE "$MEM_RE" | head -1)"
    else
      # Destino FUERA de la ruta protegida ⇒ el comando LEE de memory y escribe
      # afuera: `cp …/memory/MEMORY.md /tmp/bak.md` es un respaldo legítimo.
      # Estos verbos no están en LECTORES (escriben, en general), así que sin
      # esta rama el respaldo quedaría bloqueado.
      es_lectura=1
    fi
  fi

  if [[ $es_lectura -eq 1 ]]; then
    exit 0
  fi

  # `target` para el mensaje: el `.md` si se nombró, si no el directorio destino.
  target="$(printf '%s' "$probe" | grep -oE "$MEM_RE" | head -1)"
  [[ -z "$target" ]] && target="${dir_target:-}"
fi

# Sin nada que inspeccionar → no es nuestra incumbencia.
[[ -z "$target" ]] && exit 0

if printf '%s' "$target" | grep -qE "$MEM_RE|$MEM_DIR_RE"; then
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

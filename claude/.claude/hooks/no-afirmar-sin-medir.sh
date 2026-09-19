#!/usr/bin/env bash
# PreToolUse (matcher: Write|Edit|MultiEdit). AVISA cuando un comentario es
# NARRATIVA HISTÓRICA —lo que git ya guarda— o cita evidencia sin medir.
#
# EL CRITERIO, que es todo lo que hace falta saber:
#
#   ¿Se lo puedo preguntar a `git log`?  → va en el mensaje del commit.
#   ¿Rompe si alguien lo ignora mañana?  → va en el archivo, y corto.
#
# Un INVARIANTE ("la lista es cerrada: lo que falte queda bloqueado") se queda:
# sin él, el próximo lo rompe. La CRÓNICA de cómo se llegó ahí —qué decía
# antes, cuántas rondas costó, qué se midió y qué día— es exactamente lo que
# git guarda mejor, con fecha exacta y sin desincronizarse.
#
# La crónica en el archivo tiene dos costos: envejece sola (una cifra de casos
# queda vieja al agregar un caso) y sepulta el código bajo prosa.
#
# AVISA, NO BLOQUEA: distinguir prosa útil de crónica exige entender el
# dominio, y un patrón de texto no lo hace. Bloquear sobre esa señal frenaría
# comentarios correctos y se terminaría desactivando.
#
# Los porqués de este archivo, con sus mediciones: ver `git log` de este hook.
#
#   stdin: JSON { tool_input: { file_path, content|new_string } }
#   stdout: JSON { systemMessage }   ·   exit 0 SIEMPRE

set -uo pipefail

payload="$(cat 2>/dev/null || true)"
command -v jq >/dev/null 2>&1 || exit 0

ruta="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)"
texto="$(printf '%s' "$payload" | jq -r '
  (.tool_input.content // "") + "\n" +
  (.tool_input.new_string // "") + "\n" +
  ((.tool_input.edits // []) | map(.new_string // "") | join("\n"))' 2>/dev/null || true)"
[ -z "${texto//[[:space:]]/}" ] && exit 0

comentarios="$(printf '%s' "$texto" | grep -E '^[[:space:]]*(#|//|\*|<!--)' || true)"
[ -z "${comentarios//[[:space:]]/}" ] && exit 0
n_com="$(printf '%s' "$comentarios" | grep -c . || true)"

hallazgos=""

# (1) NARRATIVA HISTÓRICA — el defecto que más pesa.
#     "decía X", "antes era", "la primera versión", "costó N rondas",
#     "sobrevivió a", "se corrigió el <fecha>". Todo eso es `git log`.
if printf '%s' "$comentarios" | grep -qiE '(dec[ií]a|antes (era|dec[ií]a|estaba)|la primera versi[oó]n|se corrig|sobrevivi[oó]|cost[oó] (tres|dos|una|[0-9]+) (ronda|intento|sesi)|ronda (anterior|1|2)|auditor[ií]a (independiente|anterior|del)|hasta (hoy|el 2026)|el defecto (sobrevivi|se repiti))'; then
  hallazgos="${hallazgos}· CRÓNICA de cómo se llegó acá (qué decía antes, cuántas rondas, qué se\n  corrigió). Eso lo responde \`git log\` / \`git blame\`. Va en el MENSAJE DEL\n  COMMIT. En el archivo envejece y sepulta el código.\n"
fi

# (2) FECHAS. Una fecha en un comentario es casi siempre crónica: el archivo no
#     necesita saber cuándo se escribió — git lo sabe con precisión de segundo.
if printf '%s' "$comentarios" | grep -qE '20[0-9]{2}-[0-9]{2}-[0-9]{2}'; then
  hallazgos="${hallazgos}· una FECHA. git ya registra cuándo cambió cada línea, con más precisión y\n  sin desincronizarse. Si la fecha importa para el invariante, dejá el hecho\n  (\"el proveedor cambió el formato\"), no la crónica.\n"
fi

# (3) CIFRA DE CASOS/TESTS. Se desincroniza sola: el "33 casos" de este mismo
#     sistema quedó viejo en una hora, al agregar 10 casos sin tocar el número.
if printf '%s' "$comentarios" | grep -qiE '[0-9]+[[:space:]]*(casos?|tests?|pruebas?)\b|[0-9]+/[0-9]+[[:space:]]*(pasan|verde|ok)|\b[0-9]+[[:space:]]*(pasan|fallan)\b'; then
  hallazgos="${hallazgos}· una CIFRA de casos/tests. Se desincroniza sola —agregás casos y el número\n  queda viejo—. Referí al comando (\`bash tests/correr.sh\`), no al resultado.\n"
fi

# (4) COMANDO O MEDICIÓN citados como prueba.
if printf '%s' "$comentarios" | grep -qE '(bash|sh|\./|npm|pnpm|node|python)[^[:space:]]*\.(sh|ts|js|py)\b[^#]*(→|->|=>)' \
   || printf '%s' "$comentarios" | grep -qiE '(medido|verificado|comprobado)[^#]*(exit|→|->)[[:space:]]*[0-9]'; then
  hallazgos="${hallazgos}· una MEDICIÓN o un COMANDO citados como prueba. Ejecutalo ahora y pegá su\n  salida real — o quitalo: si nadie lo reproduce, en un mes es folclore.\n"
fi

# (5) GARANTÍA ABSOLUTA sobre el propio código. Es la que justifica no volver
#     a probar, y por eso la que más caro sale cuando es falsa.
if printf '%s' "$comentarios" | grep -qiE '(estructuralmente|por construcci[oó]n)[[:space:]]+(imposible|seguro)|imposible[[:space:]]+(de|por)[[:space:]]+(evadir|saltar|violar)|no[[:space:]]+puede[[:space:]]+(fallar|evadirse)|cubre[[:space:]]+(todos|todas)[[:space:]]+(los|las)'; then
  hallazgos="${hallazgos}· una GARANTÍA ABSOLUTA. Justifica no volver a probar, y ese es el costo\n  cuando es falsa. Acotala a lo que medís hoy.\n"
fi

# (6) VOLUMEN. El síntoma agregado: un archivo mayormente prosa.
if [ "$n_com" -gt 60 ]; then
  hallazgos="${hallazgos}· VOLUMEN: ${n_com} líneas de comentario en un solo cambio. Los hooks de este\n  sistema llegaron a 72% de prosa. Si el lector tiene que atravesar la\n  historia para llegar al código, la historia está en el lugar equivocado.\n"
fi

# (7) HOOK NUEVO: el autor no es buen auditor de su propio diseño.
#     Cada hook de este sistema pasó sus casos y una auditoría independiente
#     le encontró evasiones después: el que los escribe prueba lo que imaginó,
#     no lo que no imaginó. El ataque va ANTES de darlo por bueno.
#     Se exige que el contenido sea un ARCHIVO COMPLETO (shebang + lógica), no
#     un fragmento: un Edit de dos líneas sobre un hook inexistente es una
#     prueba o un retoque, no un gate nuevo que auditar.
es_hook_nuevo=0
case "$ruta" in
  */.claude/hooks/*.sh)
    if [ ! -f "$ruta" ] \
       && printf '%s' "$texto" | grep -qE '^#!.*(bash|sh)' \
       && [ "$(printf '%s' "$texto" | grep -c .)" -gt 15 ]; then
      es_hook_nuevo=1
    fi
    ;;
esac

if [ "$es_hook_nuevo" = "1" ]; then
  jq -nc --arg m "🔨 HOOK NUEVO — atacalo ANTES de darlo por bueno.

Cada gate de este sistema pasó sus propios casos y una auditoría independiente
le encontró evasiones después. El que escribe el gate prueba lo que imaginó;
las evasiones viven en lo que no imaginó.

Antes de registrarlo:
  1. DECOY — agregá un token inocente al comando (\`cat .env README.md\`).
     ¿Lo desarma? Las exenciones se evalúan por TOKEN, no por comando.
  2. INDIRECCIÓN — \$(…), backticks, variable, glob, comillas parciales,
     ruta absoluta, ../, symlink, heredoc, pipe hacia otro proceso.
  3. VERBO NO PREVISTO — el que falte en tu lista. Si enumerás lo que hay que
     bloquear, la lista es ABIERTA: enumerá lo permitido y bloqueá el resto.
  4. FALSO POSITIVO — corrélo contra tu propio historial de comandos reales.
     Un gate que muerde trabajo legítimo se rodea y deja de existir.
  5. Y recién entonces: casos versionados + auditor independiente.

Los 1-4 los podés hacer vos en dos minutos. El paso 5 encuentra lo que quede." \
    '{systemMessage: $m}'
  exit 0
fi

[ -z "$hallazgos" ] && exit 0

msg="✂️  Comentarios: esto probablemente va en el COMMIT, no en el archivo.

$(printf '%b' "$hallazgos")
El criterio, en una línea:
  ¿Se lo puedo preguntar a \`git log\`?   → mensaje del commit.
  ¿Rompe si alguien lo ignora mañana?   → archivo, y corto.

Un INVARIANTE (\"la lista es cerrada: lo que falte queda bloqueado\") se queda:
sin él, el próximo lo rompe. La CRÓNICA de cómo se llegó ahí, no."

jq -nc --arg m "$msg" '{systemMessage: $m}'
exit 0

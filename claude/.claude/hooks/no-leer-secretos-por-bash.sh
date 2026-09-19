#!/usr/bin/env bash
# PreToolUse (matcher: Bash). BLOQUEA (exit 2) leer por Bash un archivo que las
# reglas `deny` del usuario protegen de la herramienta `Read`.
#
# ── LA DEUDA QUE CIERRA ─────────────────────────────────────────────────────
#
# `~/.claude/settings.json` declara 8 reglas `deny`. SIETE son de LECTURA:
#
#   Read(./secrets/**)   Read(./**/*.key)         Read(./**/*.pem)
#   Read(./**/*credentials*)   Read(./**/*password*)
#   Read(./.aws/**)      Read(./.ssh/**)          Edit(./secrets/**)
#
# Esas reglas gobiernan la herramienta `Read`. **Bash es otra puerta y no las
# respeta.** Medido el 2026-09-19, los cinco con exit 0 y sin que ningún hook
# del sistema (guard-sensitive-exec, block-harness-memory,
# redirect-code-search-to-mcp, block-silent-grep-glob-failure) los tocara:
#
#   cat secrets/prod.key        cat .ssh/id_rsa       cat .aws/credentials
#   cat config/db-password.txt  head -5 certs/server.pem
#
# Los gates existentes están hechos de VERBOS DE ESCRITURA; las siete reglas de
# lectura nunca estuvieron cubiertas por ninguno. Se nombró como deuda conocida
# al retirar el guard de destino y se cierra acá, explícitamente, no de
# contrabando.
#
# ── QUÉ SE AGREGA A LA LISTA DEL USUARIO, Y POR QUÉ ────────────────────────
#
# `.env`. Medido el mismo día: de todas las rutas que las reglas nombran, en
# este repo **sólo existe `.env`** — no hay `secrets/`, ni `.ssh/`, ni `.aws/`.
# O sea que las siete reglas protegían rutas ausentes mientras el único archivo
# de secretos real quedaba fuera de todas, legible por `Read` Y por Bash.
# `.gitignore:22` ya lo declara secreto ("Env (secrets locales)"); la regla
# faltaba. `.env.example` y `.env.dev` se excluyen: el propio `.gitignore` los
# desmarca (`!.env.example`) porque son plantillas sin valores.
#
# ── LA PREGUNTA ESTÁ INVERTIDA (lección medida tres veces hoy) ─────────────
#
# NO se enumera "qué comandos leen" — esa lista es ABIERTA y hoy se cayó tres
# veces en este mismo sistema: faltaba `add` en los verbos de gcloud, faltaba
# un host sin punto en los destinos SQL, faltaban `ugrep`/`xargs -0` en los
# buscadores. Cualquier lista de lectores se queda corta: `cat`, `less`, `xxd`,
# `od`, `base64`, `openssl`, `python -c`, un editor, un `while read`.
#
# Se pregunta al revés: **¿el comando NOMBRA una ruta protegida?** Si la nombra
# y NO es una de las pocas operaciones que no exponen contenido (lista cerrada:
# `ls`, `stat`, `rm`, `test`…), se bloquea. Un binario que nadie previó no pasa:
# no puede, porque no hace falta reconocerlo.
#
# ── FALSOS POSITIVOS: EL RIESGO REAL, MEDIDO ───────────────────────────────
#
# Las reglas `*credentials*` y `*password*` matchean CÓDIGO FUENTE legítimo. En
# este repo, los únicos archivos trackeados que matchean son exactamente eso:
#
#   services/svc-auth/src/application/admin/reset-user-password.usecase.ts
#   services/svc-chat/src/infrastructure/secrets/secret-loader.service.ts
#
# Bloquear su lectura rompería el trabajo normal, y un gate que muerde trabajo
# legítimo se termina rodeando (el footgun que este repo ya documenta dos
# veces). Por eso **las extensiones de código quedan exentas**: un `.ts` no es
# un secreto aunque se llame `password`. El secreto vive en `.env`, `.key`,
# `.pem`, o bajo `secrets/`.
#
# ── NO HAY OVERRIDE ────────────────────────────────────────────────────────
#
# Las reglas son del dueño y un agente no se auto-autoriza. Si hace falta leer
# un secreto, lo lee el dueño. `CBM_CHECKED=1` se retiró hoy de otro hook por
# usarse como atajo sistemático; no se reintroduce acá.
#
#   stdin: JSON { tool_input: { command } }   ·   exit 0 = permitir · 2 = bloquear

set -uo pipefail

payload="$(cat 2>/dev/null || true)"
cmd=""
if command -v jq >/dev/null 2>&1; then
  cmd="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
fi
if [ -z "$cmd" ]; then
  # Fallback sin jq. Falla CERRADO más abajo: si no se puede leer el comando
  # pero el payload nombra una ruta protegida, se bloquea igual.
  cmd="$(printf '%s' "$payload" \
    | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(\([^"\\]\|\\.\)*\)".*/\1/p' | head -1)"
  [ -z "$cmd" ] && cmd="$payload"
fi
[ -z "$cmd" ] && exit 0

# Comillas fuera: `cat "secrets/x.key"` es la misma lectura. Es la lección de
# E4 de hoy — entrecomillar una ruta la escondía de un patrón sin frontera.
probe="$(printf '%s' "$cmd" | tr -d "\"'")"

# ── ¿Nombra una ruta protegida? Las 7 reglas del usuario, más `.env`. ──────
# ⚠️ LA FRONTERA NO ES SÓLO EL ESPACIO. Medido al escribir este hook:
#   python3 -c "print(open('.env').read())"  → exit 0
# porque `.env` venía seguido de `)` y el patrón exigía espacio o fin de línea.
# Una ruta termina en cualquier carácter que no forme parte de un nombre de
# archivo: paréntesis, coma, punto y coma, pipe, `>`. Es la misma clase de
# defecto que E4 (entrecomillar escondía el directorio): una frontera
# demasiado estrecha deja pasar la forma que nadie escribió en la prueba.
FIN='([^[:alnum:]_.-]|$)'
PROTEGIDO="(^|[^[:alnum:]_.-])(secrets/|\.ssh/|\.aws/)|[^[:space:]]*\.(key|pem|p12|pfx|jks)${FIN}|[^[:space:]]*(credentials|password|passwd|secret)[^[:space:]/]*${FIN}|(^|[^[:alnum:]_.-])\.env${FIN}"
printf '%s' "$probe" | grep -qE "$PROTEGIDO" || exit 0

# ── Exenciones, en orden de especificidad ──────────────────────────────────

# 1. CÓDIGO FUENTE. Un `.ts` llamado `reset-user-password.usecase.ts` no es un
#    secreto. Medido: son los únicos archivos trackeados del repo que matchean.
# ⚠️ `.json` NO está en esta lista, a diferencia de las demás extensiones de
# texto. Medido: `cat certs/api-credentials.json` pasaba, y un
# `credentials.json` ES el secreto —`.gitignore:67` ya declara
# `.gcp-credentials.json`—. El riesgo inverso se midió y es CERO: ningún `.json`
# trackeado del repo nombra credenciales/password/secret, así que exentarlo no
# compraba nada y abría la puerta al formato en que vienen las llaves de GCP.
if printf '%s' "$probe" | grep -qE '\.(ts|tsx|js|jsx|mjs|cjs|astro|vue|svelte|py|go|rs|java|kt|rb|php|swift|cs|scala|ex|exs|tf|tfvars|sql|prisma|md|ya?ml|toml|lock|snap)([[:space:]]|$)'; then
  exit 0
fi

# 2. PLANTILLAS sin valores: el propio `.gitignore` las desmarca (`!.env.example`).
if printf '%s' "$probe" | grep -qE '\.env\.(example|sample|template|dev)([[:space:]]|$)'; then
  exit 0
fi

# 3. OPERACIONES QUE NO EXPONEN CONTENIDO. Lista CERRADA —éste es el único
#    lugar donde se enumera, y se puede porque lo enumerado es lo permitido:
#    lo que falte queda BLOQUEADO, que es el lado seguro del error.
#    Se exige que el verbo ARRANQUE el comando o venga tras un separador.
# ⚠️ NINGÚN INTÉRPRETE va acá. Medido al escribir este hook:
#   python3 -c "print(open('.env').read())"  → exit 0
# porque `node`/`python` estaban en la lista. Un intérprete ejecuta código
# arbitrario: es la forma MÁS directa de leer el archivo, no una operación
# inocua. Mismo criterio para `sh -c`, `perl`, `ruby`.
INOCUOS='ls|ll|stat|file|test|\[|rm|mv|touch|mkdir|chmod|chown|ln|find|basename|dirname|realpath|readlink|wc|du|df|git|docker|pnpm|npm|tofu|terraform|gcloud|echo|printf|export'
if printf '%s' "$probe" | grep -qE "(^|[|;&]|&&|\|\|)[[:space:]]*($INOCUOS)([[:space:]]|$)" \
   && ! printf '%s' "$probe" | grep -qE "(^|[|;&]|&&|\|\|)[[:space:]]*(cat|head|tail|less|more|bat|nl|od|xxd|hexdump|strings|base64|openssl|grep|egrep|fgrep|rg|awk|sed|cut|sort|uniq|tr|tee|dd|cp|scp|rsync|curl|wget|python[0-9.]*|perl|ruby|php)\b"; then
  exit 0
fi

# ── Bloquea ────────────────────────────────────────────────────────────────
ruta="$(printf '%s' "$probe" | grep -oE "$PROTEGIDO" | head -1 | sed -E 's/^[[:space:]=]+//')"

cat >&2 <<EOF
🛑 BLOQUEADO: leer por Bash un archivo que las reglas \`deny\` protegen.

   coincide con: ${ruta:-<ruta protegida>}

Las reglas \`deny\` de ~/.claude/settings.json gobiernan la herramienta \`Read\`.
Bash es otra puerta, y hasta ahora no las respetaba: \`cat secrets/x.key\` pasaba
mientras \`Read\` lo bloqueaba. Este hook cierra esa asimetría.

NO hay override: las reglas son del dueño y un agente no se auto-autoriza. Si
de verdad hace falta el contenido de un secreto, lo abre él.

QUÉ SÍ podés hacer sin el contenido:
  • ver si existe / su tamaño / permisos  → ls -la, stat
  • operar sin leer                       → rm, mv, chmod
  • las plantillas SIN valores            → .env.example, .env.dev
  • el CÓDIGO que menciona secretos       → no se bloquea (un .ts no es un
    secreto aunque se llame reset-user-password.usecase.ts)
EOF
exit 2

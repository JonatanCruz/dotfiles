#!/usr/bin/env bash
# PreToolUse (matcher: Agent|Task). BLOQUEA un encargo que manda a construir
# sobre un hecho del sistema que nadie midió, o sin enumerar los desenlaces.
#
# LAS DOS COSAS QUE VIGILA, y por qué son la misma
#
#   1. Un HECHO del sistema afirmado sin la medición que lo produjo. El agente
#      delegado no puede distinguir "lo medí" de "lo supuse": construye sobre lo
#      que el encargo afirme. Un supuesto falso en un briefing no cuesta una
#      frase — cuesta el trabajo entero que se levanta encima.
#
#   2. Un encargo de IMPLEMENTACIÓN sin los desenlaces enumerados. Quien escribe
#      sólo el camino que quiere que ocurra, escribe el test que lo recorre, lo
#      ve verde, y da por cubierto lo que nunca miró.
#
# Las dos fallan en el MISMO instante —al redactar el encargo— y producen el
# mismo daño: trabajo construido sobre algo que no se verificó.
#
# QUÉ CUENTA COMO MEDICIÓN (cualquiera alcanza)
#   · La salida de un comando, un conteo, un `archivo:línea`.
#   · Un identificador verificable: commit, PR, issue, ruta concreta.
#   · Decirlo como lo que es: "no medí", "supongo", "verificalo".
#
# POR QUÉ BLOQUEA Y NO AVISA
# Un control que avisa se ignora: está medido en este repo, el que pide usar el
# índice de código avisó y se ignoró cada vez. El costo de un bloqueo es
# reescribir dos líneas del encargo; el de un aviso ignorado es el trabajo que
# se construye sobre el supuesto.
#
# NO hay override. Si hace falta afirmar sin medir, se escribe "no lo medí" —
# que es la verdad, y el agente delegado puede entonces medirlo él.

set -uo pipefail

INPUT="$(cat 2>/dev/null || true)"
[ -z "${INPUT//[[:space:]]/}" ] && exit 0

if command -v jq >/dev/null 2>&1; then
  PROMPT="$(printf '%s' "$INPUT" | jq -r '
    [(.tool_input.description // empty), (.tool_input.prompt // empty)] | join("\n")
  ' 2>/dev/null || printf '%s' "$INPUT")"
else
  # Sin jq se usa el payload crudo: un control que no resuelve su contexto no
  # puede rendirse en silencio.
  PROMPT="$INPUT"
fi
[ -z "${PROMPT//[[:space:]]/}" ] && exit 0

# Un encargo corto es una consulta, no un plan de trabajo.
[ "${#PROMPT}" -lt 400 ] && exit 0

hallazgos=""

# ── (1) HECHOS DEL SISTEMA AFIRMADOS ────────────────────────────────────────
# La forma que importa: una afirmación categórica sobre existencia, cantidad o
# estado. "No existe", "nunca corre", "son 278", "está limpio".
AFIRMA='(no|nunca) (existe|corre|se (usa|invoca|ejecuta|despliega))|cero (filas|ocurrencias|resultados|consumidores)|(está|estan|están) (limpio|vacío|vacias|desplegad)|ningún (entorno|servicio|test|caller|cron)|no (hay|tiene) (tests?|cobertura|candado|guarda)|es irrecuperable|no se puede (derivar|recuperar)'

# Lo que vuelve LEGÍTIMA la afirmación: la evidencia al lado.
MIDE='archivo:línea|[a-zA-Z0-9_./-]+\.(ts|tsx|sql|tf|json|sh|md):[0-9]+|`[^`]*(grep|gcloud|git |SELECT|COUNT|psql|mysql|pnpm|docker)[^`]*`|medid[oa]|verificad[oa]|conteo|salida del comando|commit [0-9a-f]{7}|PR #[0-9]+|issue #[0-9]+|no (lo )?(medí|verifiqué)|supongo|verificalo|no está medido'

if printf '%s' "$PROMPT" | grep -qiE "$AFIRMA"; then
  if ! printf '%s' "$PROMPT" | grep -qiE "$MIDE"; then
    hallazgos="${hallazgos}· Afirma un HECHO del sistema (que algo no existe, no corre, está limpio,\n  o cuánto hay) SIN la medición que lo produjo. Quien reciba este encargo no\n  puede distinguir un dato de un supuesto: va a construir sobre él.\n\n  Pegá la salida del comando, citá \`archivo:línea\`, o escribí \"no lo medí\".\n"
  fi
fi

# ── (2) DESENLACES EN UN ENCARGO DE IMPLEMENTACIÓN ──────────────────────────
CONSTRUYE='implementá|implementa |construí|construi |agregá|agrega |escribí el|creá |crea el|modificá|modifica |cambiá|cambia el|arreglá|arregla |corregí|corrige |movoé|mové|mueve |refactor'

# Sólo cuenta como enumeración si nombra formas de FALLAR, no el camino feliz.
ENUMERA='desenlace|qué pasa si|si falla|falla el|lanza (en vez|una excepción)|se cuelga|devuelve (null|undefined|vacío|algo inesperado)|ya lo hizo|simultáne|concurrent|reintent|idempot|rollback|no cubierto|caso límite|edge case'

if printf '%s' "$PROMPT" | grep -qiE "$CONSTRUYE"; then
  if ! printf '%s' "$PROMPT" | grep -qiE "$ENUMERA"; then
    hallazgos="${hallazgos}· Encargo de IMPLEMENTACIÓN sin los DESENLACES enumerados. Sólo el camino\n  feliz llega al código; lo que no se nombra no se cubre y aparece después,\n  auditando o en producción.\n\n  Para cada dependencia que se invoque: ¿y si falla? ¿y si LANZA en vez de\n  devolver error? ¿y si devuelve algo inesperado? ¿y si se cuelga? ¿y si el\n  paso siguiente falla? ¿y si ya lo hizo otro?\n"
  fi
fi

[ -z "$hallazgos" ] && exit 0

cat >&2 <<EOF
🛑 BLOQUEADO (no-delegar-sobre-supuestos): el encargo manda a construir sobre
algo que no se verificó.

$(printf '%b' "$hallazgos")
El daño no es la frase: es el trabajo que se levanta encima. Un supuesto falso
en un briefing se convierte en código, en tests que lo confirman, y en horas de
corrección cuando alguien lo mide.

NO hay variable de override. Si no lo mediste, escribilo — "no lo medí" es una
frase honesta y deja que quien reciba el encargo lo mida.
EOF
exit 2

#!/usr/bin/env bash
# no-defiendas-contaminacion.sh — PreToolUse sobre la herramienta de agentes
#
# PROBLEMA QUE RESUELVE (2026-08-13): al encargar un borrado de contaminación
# legacy, escribo una cláusula de escape que suena a prudencia y funciona como
# veto: *"si al medir encontrás que SÍ se usa, decilo y no lo borres"*. El dueño
# lo cazó y lo nombró: *"ahí está el error, no defiendas, primero rompe y luego
# repara"*.
#
# No es la primera vez. El mismo patrón está corregido en memoria al menos tres
# veces (2026-08-06, 2026-08-10, 2026-08-13) y siguió ocurriendo — porque una
# nota en memoria depende de que yo la lea en el momento exacto en que estoy
# por escribir la cláusula, y ese es justo el momento en que no la leo.
#
# El dueño lo nombró textual: *"se te está olvidando a cada rato y ya ni sé
# cuántas memorias has guardado con esto"*. Escribir la regla otra vez sería
# repetir el error. Este hook la pone en la ESTRUCTURA (Meadows), en el único
# instante donde se rompe: el encargo, ANTES de que el agente lo ejecute.
#
# NO bloquea — señala el texto exacto que hay que reescribir y sale 0.

set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0

INPUT="$(cat 2>/dev/null || true)"
PROMPT="$(printf '%s' "$INPUT" | jq -r '
  [(.tool_input.description // empty), (.tool_input.prompt // empty)] | join(" ")
' 2>/dev/null || true)"
[ -n "$PROMPT" ] || exit 0

# Sólo interesa cuando el encargo ES de borrado/descontaminación. Sin esto el
# hook gritaría en cada delegación y se volvería ruido que se aprende a ignorar.
printf '%s' "$PROMPT" | grep -qiE 'borra|elimin|descontamin|retira|quitar|legacy|contaminaci' || exit 0

# Las formas concretas en que escribo el veto. Deliberadamente específicas: una
# heurística amplia daría falsos positivos y el hook moriría por desconfianza
# (el footgun que el propio proyecto documenta con el hook GGA roto).
ESCAPES="$(printf '%s' "$PROMPT" | grep -oiE \
  'no lo borres|no los borres|no lo elimines|no la borres|dejalo como está|dejálo como está|conservalo|consérvalo|si (algo|alguno|alguien) (lo|los|la) (usa|consume|lee)[^.]*no (lo|los|la)|mejor no tocar|no lo toques si' \
  2>/dev/null | head -3)"

[ -n "$ESCAPES" ] || exit 0

echo "🛑 CLÁUSULA DE ESCAPE en un encargo de borrado — reescribila antes de mandarlo:"
printf '%s\n' "$ESCAPES" | sed 's/^/   → "/;s/$/"/'
echo ""
echo "La regla del dueño, repetida: «se elimina, no se renombra, no se traduce, se va y punto»"
echo "· «aunque lo validara se va, NO importa si se usa» · «primero rompe y luego repara»."
echo ""
echo "Un uso vivo NO es razón para conservar: es el trabajo a reparar después de borrar."
echo "Medí para saber QUÉ REPARAR, no para decidir SI borrás."
echo ""
echo "El ÚNICO límite legítimo no es «se usa» sino «el negocio se cae» (p.ej. perder el"
echo "padrón deja vendedores sin vender). Romper código ≠ romper el negocio."
exit 0

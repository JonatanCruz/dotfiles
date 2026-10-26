#!/usr/bin/env bash
# no-defiendas-contaminacion.sh — PreToolUse sobre la herramienta de agentes.
#
# QUÉ VIGILA: la cláusula de escape en un encargo de BORRADO. Suena a prudencia
# —"si al medir encontrás que sí se usa, no lo borres"— y funciona como veto: el
# agente delegado mide, encuentra un uso vivo, y conserva lo que había que
# eliminar. El encargo se anula a sí mismo sin que nadie lo note.
#
# POR QUÉ ES UN HOOK Y NO UNA NOTA: la regla se rompe en el instante de ESCRIBIR
# el encargo, que es justo cuando no se releen las notas. El control tiene que
# estar en ese instante, no en la memoria del que escribe.
#
# POR QUÉ AVISA Y NO BLOQUEA: distinguir un veto indebido de un límite legítimo
# ("no borres la tabla de la que depende el cobro") exige entender el dominio, y
# eso un patrón de texto no lo hace. Bloquear sobre esa señal ambigua frenaría
# encargos correctos. Acá el aviso alcanza porque llega ANTES de mandar el
# encargo, con el texto exacto a reescribir señalado: el costo de corregirlo es
# una edición, no un incidente.
#
# El patrón es deliberadamente ESTRECHO —las formas concretas del veto— porque
# una heurística amplia gritaría en cada delegación y moriría por desconfianza.
#
# El aviso sale como additionalContext (JSON con jq): en PreToolUse el texto
# plano con exit 0 no llega al modelo. Sin jq no hay forma segura de armar el
# JSON, así que no avisa.
#
set -uo pipefail

INPUT="$(cat 2>/dev/null || true)"
[ -n "$INPUT" ] || exit 0

# Sin jq se usa el payload crudo. Antes había un `command -v jq || exit 0` acá:
# en una máquina sin jq el hook salía en silencio y el encargo con cláusula de
# escape se mandaba sin aviso. Medido el 2026-09-19 con jq oculto del PATH:
# un encargo de borrado con "no lo borres" salía exit=0 SIN imprimir nada.
#
# El crudo sirve para este hook —a diferencia del gate del índice— porque acá se
# buscan FRASES en español dentro del texto del encargo, y esas frases sobreviven
# intactas al escapado del JSON. No se pierde precisión, sólo se deja de depender
# de que jq exista.
PROMPT=""
if command -v jq >/dev/null 2>&1; then
  PROMPT="$(printf '%s' "$INPUT" | jq -r '
    [(.tool_input.description // empty), (.tool_input.prompt // empty)] | join(" ")
  ' 2>/dev/null || true)"
fi
[ -n "$PROMPT" ] || PROMPT="$INPUT"
[ -n "$PROMPT" ] || exit 0

# Sólo interesa cuando el encargo ES de borrado/descontaminación. Sin esto el
# hook gritaría en cada delegación y se volvería ruido que se aprende a ignorar.
# `borr`/`retir`/`quit` cortan ANTES de la vocal acentuada: el imperativo con
# tilde (`Borrá`, `retirá`, `quitá`) es la forma que más se usa al escribir un
# encargo, y un fragmento que incluya la vocal no lo matchea.
printf '%s' "$PROMPT" | grep -qiE 'borr|elimin|descontamin|retir|quit|legacy|contaminaci' || exit 0

# Las formas concretas en que escribo el veto. Deliberadamente específicas: una
# heurística amplia daría falsos positivos y el hook moriría por desconfianza
# (el footgun que el propio proyecto documenta con el hook GGA roto).
ESCAPES="$(printf '%s' "$PROMPT" | grep -oiE \
  'no lo borres|no los borres|no lo elimines|no la borres|dejalo como está|dejálo como está|conservalo|consérvalo|si (algo|alguno|alguien) (lo|los|la) (usa|consume|lee)[^.]*no (lo|los|la)|mejor no tocar|no lo toques si' \
  2>/dev/null | head -3)"

[ -n "$ESCAPES" ] || exit 0

CITAS="$(printf '%s\n' "$ESCAPES" | sed 's/^/   → "/;s/$/"/')"
MENSAJE="🛑 CLÁUSULA DE ESCAPE en un encargo de borrado — reescribila antes de mandarlo:
$CITAS

La regla del dueño, repetida: «se elimina, no se renombra, no se traduce, se va y punto»
· «aunque lo validara se va, NO importa si se usa» · «primero rompe y luego repara».

Un uso vivo NO es razón para conservar: es el trabajo a reparar después de borrar.
Medí para saber QUÉ REPARAR, no para decidir SI borrás.

El ÚNICO límite legítimo no es «se usa» sino «el negocio se cae» (p.ej. perder
datos que la operación en producción necesita). Romper código ≠ romper el negocio."

# En PreToolUse el stdout plano con exit 0 no llega al modelo (sólo al log de
# depuración): tiene que ir como `additionalContext`. JSON armado con `jq --arg`.
jq -n --arg ctx "$MENSAJE" \
  '{hookSpecificOutput: {hookEventName: "PreToolUse", additionalContext: $ctx}}' 2>/dev/null || true
exit 0

#!/usr/bin/env bash
# probe-payload.sh — vuelca el payload crudo que Claude Code entrega a un hook.
#
# Existe para RE-MEDIR la afirmación de CLAUDE.md (Regla #14, §"Lo que estos
# controles NO cubren"): que no hay señal en el payload que distinga al agente
# principal de un subagente, y que por eso el gate "delegá antes de actuar" no
# se puede construir sin fabricar un override.
#
# Esa afirmación sostiene una decisión de NO construir. Si algún día el harness
# empieza a mandar la señal, la decisión hay que rehacerla — y nadie se va a
# enterar leyendo la tabla. Por eso la verificación se deja corrible:
#
#   1. registrarlo temporalmente como PreToolUse en settings.json
#   2. correr cualquier comando desde el agente principal y desde un subagente
#   3. comparar los dos volcados:  diff /tmp/payload-hook-*.json
#
# Si aparece un campo que separe los dos casos, la fila de la tabla queda
# obsoleta y el gate vuelve a estar sobre la mesa.
payload="$(cat 2>/dev/null || true)"
printf '%s\n' "$payload" > "/tmp/payload-hook-$(date +%s%N).json"
exit 0

#!/usr/bin/env bash
# Runner de `no-afirmar-sin-medir.sh`.
#
# Tiene su propio runner porque es un hook de Write/Edit, no de Bash: el runner
# genérico manda `{tool_input:{command}}`, que este hook ignora → saldría exit 0
# en todos los casos y el archivo mediría NADA, reportando verde.
#
# Ese fallo exacto ya ocurrió hoy en este sistema (`run-suite.sh` imprimía
# "→ 0/0, sin desvíos" sobre cero casos ejecutados), así que acá se cuenta lo
# que no parsea y se falla si no se ejecutó nada.

set -uo pipefail
cd "$(dirname "$0")" || exit 1

HOOK="../no-afirmar-sin-medir.sh"
CASOS="casos-no-afirmar-sin-medir.txt"
[ -f "$HOOK" ] && [ -f "$CASOS" ] || { echo "falta $HOOK o $CASOS"; exit 1; }

p=0; f=0; saltadas=0
printf '\n══ no-afirmar-sin-medir ══\n'
while IFS=$'\t' read -r esperado ruta comentario; do
  case "$esperado" in ''|'#'*) continue ;; esac
  case "$esperado" in
    AVISA|calla) ;;
    *) saltadas=$((saltadas+1)); continue ;;
  esac
  [ -z "${comentario:-}" ] && { saltadas=$((saltadas+1)); continue; }

  # El veredicto es el EXIT CODE, no stdout: este hook BLOQUEA (exit 2) y escribe
  # el motivo en stderr. Medir stdout daría "calla" en todo caso bloqueado y la
  # suite reportaría verde sobre un gate que muerde — el modo de falla que este
  # runner existe para no repetir.
  salida="$(jq -nc --arg p "$ruta" --arg c "$comentario" \
    '{tool_input:{file_path:$p,content:$c}}' | bash "$HOOK" 2>&1)"
  rc=$?
  real="calla"
  { [ "$rc" -eq 2 ] || [ -n "${salida//[[:space:]]/}" ]; } && real="AVISA"

  if [ "$real" = "$esperado" ]; then
    p=$((p+1))
  else
    f=$((f+1))
    printf '  ❌ %s (esperado %s)\n     %s\n' "$real" "$esperado" "$comentario"
  fi
done < "$CASOS"

# El caso del HOOK NUEVO necesita un archivo completo (shebang + >15 líneas),
# que el formato de una línea del archivo de casos no puede expresar.
nuevo="$(printf '#!/usr/bin/env bash\nset -uo pipefail\n'; seq 1 20 | sed 's/^/# linea /')"
r="$(jq -nc --arg p "$(cd .. && pwd)/zz-inexistente.sh" \
     --arg c "$nuevo" '{tool_input:{file_path:$p,content:$c}}' | bash "$HOOK" 2>/dev/null || true)"
if printf '%s' "$r" | grep -q 'HOOK NUEVO'; then
  p=$((p+1))
else
  f=$((f+1)); printf '  ❌ hook nuevo completo: no dio el checklist de ataque\n'
fi
# Y el simétrico: un hook que YA existe no debe darlo.
r="$(jq -nc --arg p "$HOOK" --arg c "$nuevo" '{tool_input:{file_path:$p,content:$c}}' \
     | bash "$HOOK" 2>/dev/null || true)"
if printf '%s' "$r" | grep -q 'HOOK NUEVO'; then
  f=$((f+1)); printf '  ❌ hook existente: dio el checklist y no debía\n'
else
  p=$((p+1))
fi

printf '  %s pasan, %s fallan\n' "$p" "$f"
[ "$saltadas" -gt 0 ] && { printf '  ⚠️  %s línea(s) no parsean\n' "$saltadas"; f=$((f+saltadas)); }
[ $((p+f)) -eq 0 ] && { printf '  ❌ CERO casos ejecutados\n'; f=1; }
[ "$f" -eq 0 ]

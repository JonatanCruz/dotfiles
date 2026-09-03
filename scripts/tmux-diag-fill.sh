#!/usr/bin/env bash
# Diagnóstico: área de relleno ("puntos") en tmux.
#
# Corre esto EN LA VENTANA donde se ven los puntos, sin cambiar de ventana.
# Compara el tamaño del cliente con el de la ventana/panes: si la ventana es
# más pequeña que el cliente, tmux rellena el sobrante con `fill-character`,
# que es lo que se ve como puntos.
set -euo pipefail

echo "=== CLIENTE (tu terminal real) ==="
tmux list-clients -F '#{client_name}  #{client_width}x#{client_height}  sess=#{client_session}'

echo
echo "=== VENTANA ACTIVA ==="
tmux display -p 'ventana #{session_name}:#{window_index} (#{window_name})  #{window_width}x#{window_height}  zoomed=#{window_zoomed_flag}'

echo
echo "=== PANES DE ESTA VENTANA ==="
tmux list-panes -F '  pane #{pane_index}  #{pane_width}x#{pane_height}  at #{pane_left},#{pane_top}  #{pane_current_command}'

echo
echo "=== DELTA (lo que importa) ==="
tmux display -p 'cliente #{client_height} - ventana #{window_height} = #{e|-:#{client_height},#{window_height}} filas sin cubrir'
tmux display -p 'cliente #{client_width} - ventana #{window_width} = #{e|-:#{client_width},#{window_width}} columnas sin cubrir'
echo "(1 fila de delta = status bar, normal. Más de 2 = área de relleno visible.)"

echo
echo "=== OPCIONES RELEVANTES ==="
for o in fill-character window-size default-size aggressive-resize status; do
  printf '  %s\n' "$(tmux show -g "$o" 2>/dev/null || echo "$o (no soportada)")"
done

#!/usr/bin/env bash
# ==============================================================================
# mix_color - Interpola dos colores hex. Awk puro, sin dependencias.
# ==============================================================================
# Adaptado de basecamp/omarchy (bin/omarchy-theme-color).
# Uso: mix_color "#1e1e2e" "#000000" 25%   -> 25% hacia el segundo color
#      mix_color "#1e1e2e" "#000000" 0.25  -> equivalente

mix_color() {
  local start="${1#\#}" end="${2#\#}" amount="$3"

  awk -v start="$start" -v end="$end" -v amount="$amount" '
    function hex_value(char) {
      return index("0123456789abcdef", tolower(char)) - 1
    }
    function hex_pair_to_int(hex, idx) {
      return hex_value(substr(hex, idx, 1)) * 16 + hex_value(substr(hex, idx + 1, 1))
    }
    BEGIN {
      if (amount ~ /%$/) { sub(/%$/, "", amount); amount = amount / 100 }
      else { amount += 0; if (amount > 1) amount = amount / 100 }
      if (amount < 0) amount = 0
      if (amount > 1) amount = 1

      r = hex_pair_to_int(start, 1) * (1 - amount) + hex_pair_to_int(end, 1) * amount
      g = hex_pair_to_int(start, 3) * (1 - amount) + hex_pair_to_int(end, 3) * amount
      b = hex_pair_to_int(start, 5) * (1 - amount) + hex_pair_to_int(end, 5) * amount

      printf "#%02x%02x%02x\n", int(r + 0.5), int(g + 0.5), int(b + 0.5)
    }
  '
}

# strip_hash "#89b4fa" -> 89b4fa   (para configs que no aceptan el #)
strip_hash() { echo "${1#\#}"; }

# to_rgb "#89b4fa" -> 137,180,250
to_rgb() {
  local h="${1#\#}"
  printf '%d,%d,%d\n' "0x${h:0:2}" "0x${h:2:2}" "0x${h:4:2}"
}

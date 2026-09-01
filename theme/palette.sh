#!/usr/bin/env bash
# shellcheck shell=bash
# ==============================================================================
# PALETA - Fuente de verdad de colores (Catppuccin Mocha)
# ==============================================================================
# NOTA shellcheck: este archivo se consume con `source`, nunca se ejecuta. Sus
# variables se leen por indirección (${!name}) desde theme/apply.sh al expandir
# los tokens de las plantillas, así que el análisis estático no puede verlas
# usadas. De ahí el disable de SC2034 para todo el archivo.
# shellcheck disable=SC2034
# Formato neutral (shell) para que lo consuman tanto scripts como plantillas.
# La paleta oficial: https://github.com/catppuccin/catppuccin#-palette
#
# Para cambiar de tema: edita SOLO este archivo y corre `theme/apply.sh`.
# Los archivos generados llevan cabecera de "NO EDITAR" y se regeneran.
#
# nvim consume su propia copia en nvim/.config/nvim/lua/utils/colors.lua, que
# es la paleta idéntica en formato Lua (nvim carga Lua nativo; generar ese
# archivo por sed sería más frágil que mantenerlo como está).

THEME_NAME="catppuccin-mocha"
THEME_MODE="dark"

# --- Paleta oficial Catppuccin Mocha ---------------------------------------
ROSEWATER="#f5e0dc"
FLAMINGO="#f2cdcd"
PINK="#f5c2e7"
MAUVE="#cba6f7"
RED="#f38ba8"
MAROON="#eba0ac"
PEACH="#fab387"
YELLOW="#f9e2af"
GREEN="#a6e3a1"
TEAL="#94e2d5"
SKY="#89dceb"
SAPPHIRE="#74c7ec"
BLUE="#89b4fa"
LAVENDER="#b4befe"
TEXT="#cdd6f4"
SUBTEXT1="#bac2de"
SUBTEXT0="#a6adc8"
OVERLAY2="#9399b2"
OVERLAY1="#7f849c"
OVERLAY0="#6c7086"
SURFACE2="#585b70"
SURFACE1="#45475a"
SURFACE0="#313244"
BASE="#1e1e2e"
MANTLE="#181825"
CRUST="#11111b"

# --- Roles semánticos -------------------------------------------------------
# Los consumidores usan ESTOS, no los nombres de color. Cambiar de tema =
# reapuntar estos alias, sin tocar ninguna plantilla.
ACCENT="$BLUE"          # Color primario (status bars, ramas activas)
SECONDARY="$MAUVE"      # Acento secundario (headers, decoraciones)
TERTIARY="$PEACH"       # Tercer acento (nombres de archivo, avisos suaves)
BG="$BASE"
FG="$TEXT"
MUTED="$OVERLAY0"       # Comentarios, texto secundario, números de línea
SELECTION="$SURFACE1"
ERROR="$RED"
WARN="$YELLOW"
INFO="$BLUE"
HINT="$TEAL"
ADDED="$GREEN"
CHANGED="$YELLOW"
DELETED="$RED"

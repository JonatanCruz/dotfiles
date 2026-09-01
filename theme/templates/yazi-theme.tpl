# ==============================================================================
# GENERADO POR theme/apply.sh — NO EDITAR A MANO
# ==============================================================================
# Fuente: theme/palette.sh + theme/templates/yazi-theme.tpl
# Para cambiar colores: edita la paleta y corre `theme/apply.sh`.

[mgr]
cwd          = { fg = "{{ PINK }}", bold = true } # Pink for current path

# Window borders
border       = { fg = "{{ OVERLAY0 }}" } # Overlay0
border_hover = { fg = "{{ MAUVE }}", bold = true } # Mauve when panel is active

# Selection highlight
hovered      = { fg = "{{ TEXT }}", bg = "{{ SURFACE1 }}", bold = true } # Text on Surface1 for selection
preview_hovered = { bg = "{{ SURFACE1 }}" }

# General background (transparent)
background   = { bg = "none" }

# --- Status bar ---
[status]
separator_fg = "{{ OVERLAY0 }}"
background   = { bg = "{{ BASE }}" } # Base for readability

# Modes (normal, select, etc.)
mode_normal  = { fg = "{{ BASE }}", bg = "{{ GREEN }}", bold = true } # Green
mode_select  = { fg = "{{ BASE }}", bg = "{{ PEACH }}", bold = true } # Peach
mode_unset   = { fg = "{{ BASE }}", bg = "{{ PINK }}", bold = true } # Pink

# Progress information
progress_normal = { fg = "{{ GREEN }}" }
progress_error  = { fg = "{{ RED }}" }

# --- Tabs ---
[tab]
active   = { fg = "{{ TEXT }}", bg = "{{ SURFACE1 }}", bold = true }
inactive = { fg = "{{ OVERLAY0 }}" }


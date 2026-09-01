# ==============================================================================
# GENERADO POR theme/apply.sh — NO EDITAR A MANO
# ==============================================================================
# Fuente: theme/palette.sh + theme/templates/tmux-colors.tpl
# Para cambiar colores: edita la paleta y corre `theme/apply.sh`.

# Background transparente
set -g status-style bg=default
set -g status-bg default

# Contenido del status bar (solo lo esencial)
set -g status-left ""
set -g status-right "#[fg={{ ACCENT }},bg=default] #{session_name} "
set -g status-justify left

# Estilo de las ventanas/tabs (transparente)
set -g window-status-style "fg={{ MUTED }},bg=default"
set -g window-status-current-style "fg={{ ACCENT }},bg=default,bold"
set -g window-status-format " #I #W "
set -g window-status-current-format " #I #W "
set -g window-status-separator ""

# ==============================================================================
# TMUX - Gestión de sesiones de tmux
# ==============================================================================

alias tn='tmux new -s'           # Crear nueva sesión: tn <nombre>
alias ta='tmux a'                # Conectarse a sesión: ta <nombre>
alias tl='tmux ls'               # Listar sesiones
alias tk='tmux kill-session -t'  # Matar sesión: tk <nombre>
alias tks='tmux kill-server'     # Matar todas las sesiones

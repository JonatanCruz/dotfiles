# ==============================================================================
# NAVIGATION - Navegación de directorios y archivos
# ==============================================================================

# Navegación rápida
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# Zoxide (cd inteligente)
alias za='zi'                  # Zoxide interactivo (con fzf)
alias zq='zoxide query -ls'    # Ver base de datos
alias zrm='zoxide remove'      # Eliminar ruta

# Operaciones de archivos más seguras
alias cp='cp -iv'              # Confirma y verbose
alias mv='mv -iv'              # Confirma y verbose
alias mkdir='mkdir -p'         # Crea padres si no existen
alias t='touch'                # Crear archivos

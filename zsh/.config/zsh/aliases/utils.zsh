# ==============================================================================
# UTILS - Utilidades varias
# ==============================================================================

# Yazi (file manager)
alias yz='yazi'

# Comandos comunes
alias c='clear'
alias e='exit'

# Análisis de espacio
alias ducks='du -sh * | sort -rh | head -n 10'

# Networking
alias myip='curl ifconfig.me'

# Benchmark zsh startup (track plugin load regressions over time)
alias zsh-bench='for i in 1 2 3 4 5; do /usr/bin/time -p zsh -i -c exit 2>&1 | awk "/real/{print \"run $i:\", \$2 \"s\"}"; done'

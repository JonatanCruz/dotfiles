# ==============================================================================
# TOOLS - Aliases para herramientas modernas
# ==============================================================================
# Requiere: eza, bat, btop, tldr, fd, ripgrep
# Nerd Font recomendada para iconos

# Eza (reemplazo de ls)
alias ls='eza --icons'
alias l='eza -l --icons'
alias la='eza -la --icons'
alias ll='eza -l --git --icons'
alias lt='eza --tree --level=2'
alias llt='eza --tree --level=3'

# Bat (reemplazo de cat)
alias cat='bat --paging=never'

# Monitor de sistema
alias top='btop'
alias monitor='btop'

# Ayuda rápida
alias help='tldr'

# Búsqueda y grep
alias grep='grep --color=auto'
alias ff='fd --hidden'    # Find file con fd
alias rg='rg -i'          # Ripgrep case-insensitive

# claude code
alias clauded="set ENABLE_TOOL_SEARCH=true && claude --dangerously-skip-permissions"

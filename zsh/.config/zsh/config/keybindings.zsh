# ==============================================================================
# KEYBINDINGS - Atajos de teclado
# ==============================================================================

# Modo Vi para edición de línea de comandos
bindkey -v

# Búsqueda inteligente en historial (requiere plugin history-substring-search)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# ==============================================================================
# PLUGINS - Carga de plugins y aplicaciones
# ==============================================================================
# El orden de carga importa: zsh-syntax-highlighting DEBE SER EL ÚLTIMO

# Plugins de Zsh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Integración de herramientas
source <(fzf --zsh)              # FZF
eval "$(zoxide init zsh)"        # Zoxide (cd inteligente)
eval "$(direnv hook zsh)"        # Direnv (vars por directorio)
eval "$(starship init zsh)"      # Starship prompt (DEBE SER EL ÚLTIMO)

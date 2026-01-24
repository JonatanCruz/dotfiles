# ==============================================================================
# PLUGINS - Carga de plugins y aplicaciones
# ==============================================================================
# El orden de carga importa: zsh-syntax-highlighting DEBE SER EL ÚLTIMO

# Plugins de Zsh (orden crítico: syntax-highlighting DEBE ser el último plugin)
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
source ~/.zsh/zsh-you-should-use/you-should-use.plugin.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh  # MUST BE LAST PLUGIN

# Integración de herramientas
source <(fzf --zsh)              # FZF (keep immediate - essential for interactive use)

# Lazy load zoxide (100-150ms savings total for zoxide/direnv/gh)
_lazy_zoxide() {
  unset -f z zi
  eval "$(zoxide init zsh)"
}
function z() { _lazy_zoxide; z "$@"; }
function zi() { _lazy_zoxide; zi "$@"; }

# Lazy load direnv
_lazy_direnv() {
  unset -f direnv
  eval "$(direnv hook zsh)"
}
function direnv() { _lazy_direnv; direnv "$@"; }

# Google Cloud SDK completion (si está instalado)
if [ -f "/snap/google-cloud-sdk/current/completion.zsh.inc" ]; then
    source "/snap/google-cloud-sdk/current/completion.zsh.inc"
fi

# Lazy load GitHub CLI completion
if command -v gh &> /dev/null; then
  _lazy_gh() {
    unset -f gh
    eval "$(command gh completion -s zsh)"
  }
  # Unalias gh if it exists, then create function
  # Use 'function' keyword to prevent alias expansion during parsing
  unalias gh 2>/dev/null || true
  function gh() { _lazy_gh; command gh "$@"; }
fi

eval "$(starship init zsh)"      # Starship prompt (DEBE SER EL ÚLTIMO)

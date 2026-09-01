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

# ==============================================================================
# WIDGET: fzf sobre git log  (Ctrl+Alt+L)
# ==============================================================================
# Adaptado de omacom/omarchy-zsh (shell/zoptions:195-218).
#
# La idea que vale: NO ejecuta nada — inserta los SHAs en la línea de comandos.
# Escribes `git revert `, pulsas Ctrl+Alt+L, eliges el commit y completas tú.
# Con Tab (--multi) seleccionas varios y te los inserta seguidos, ideal para
# `git cherry-pick A B C`.
#
# Cambios sobre el original:
#  - fuera `--scheme=history`: ese esquema de puntuación está afinado para el
#    orden del historial de shell, no para un git log (copy-paste equivocado)
#  - valida estar dentro de un repo git en vez de fallar con ruido
#  - comprueba que fzf exista

_fzf_git_log_widget() {
  if ! command -v fzf &>/dev/null; then
    zle -M "fzf no está instalado"
    return 1
  fi
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    zle -M "no estás dentro de un repo git"
    return 1
  fi

  local selected
  selected=$(
    git log --no-show-signature --color=always \
      --format='%C(bold blue)%h%C(reset) - %C(cyan)%ad%C(reset) %C(yellow)%d%C(reset) %C(normal)%s%C(reset)  %C(dim normal)[%an]%C(reset)' \
      --date=short 2>/dev/null |
      fzf --ansi --multi \
          --prompt="Git Log> " \
          --header="Tab: marcar varios | Enter: insertar SHA(s)" \
          --preview='git show --color=always --stat --patch {1}' \
          --preview-window=right:50%:wrap |
      awk '{print $1}' |
      xargs -I {} git rev-parse {} 2>/dev/null |
      tr '\n' ' '
  )

  if [[ -n "$selected" ]]; then
    LBUFFER="${LBUFFER}${selected}"
  fi
  zle reset-prompt
}

# Registrar ANTES de que se cargue zsh-syntax-highlighting (plugins.zsh), que
# envuelve los widgets ZLE existentes: uno registrado después queda fuera.
zle -N _fzf_git_log_widget
bindkey '^[^L' _fzf_git_log_widget          # Ctrl+Alt+L
bindkey -M vicmd '^[^L' _fzf_git_log_widget # también en modo comando (vi)

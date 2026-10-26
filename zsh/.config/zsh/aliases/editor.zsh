# ==============================================================================
# EDITOR - Aliases para Neovim y configuración
# ==============================================================================

alias v='nvim'
alias vim='nvim'
# sudoedit edita una copia temporal con TU nvim y TU config (vía $SUDO_EDITOR/
# $EDITOR) y solo escribe como root al guardar; `sudo nvim` ejecutaba nvim
# entero, plugins incluidos, como root.
alias sv='sudoedit'

# Edición rápida de configuración
# El .zshrc vive en $ZDOTDIR (~/.config/zsh, definido en ~/.zshenv), no en ~/
alias zshrc='nvim "${ZDOTDIR:-$HOME}/.zshrc"'
alias tmuxconf='nvim ~/.tmux.conf'
alias nvimconf='cd ~/.config/nvim && nvim .'

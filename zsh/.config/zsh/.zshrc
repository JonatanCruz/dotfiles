# ==============================================================================
# ┌─┐┌─┐┌┬┐┌─┐┬─┐┌─┐┬ ┬  CONFIGURACIÓN DE ZSH
# │ ││ │ ││├┤ ├┬┘└─┐├─┤  Configuración modular
# └─┘└─┘─┴┘└─┘┴└─└─┘┴ ┴
# ==============================================================================
# Configuración modular y escalable de Zsh
# Estructura organizada en módulos por categoría
# ==============================================================================

# ==============================================================================
# CONFIGURACIÓN BASE
# ==============================================================================

# Cargar configuración base
source "${ZDOTDIR}/config/environment.zsh"
source "${ZDOTDIR}/config/history.zsh"
source "${ZDOTDIR}/config/options.zsh"
source "${ZDOTDIR}/config/completion.zsh"
source "${ZDOTDIR}/config/keybindings.zsh"

# ==============================================================================
# ALIASES
# ==============================================================================

source "${ZDOTDIR}/aliases/tools.zsh"
source "${ZDOTDIR}/aliases/tmux.zsh"
source "${ZDOTDIR}/aliases/git.zsh"
source "${ZDOTDIR}/aliases/navigation.zsh"
source "${ZDOTDIR}/aliases/editor.zsh"
source "${ZDOTDIR}/aliases/utils.zsh"

# ==============================================================================
# PLUGINS Y HERRAMIENTAS
# ==============================================================================

source "${ZDOTDIR}/plugins.zsh"

# ==============================================================================
# FIN DE LA CONFIGURACIÓN
# ==============================================================================

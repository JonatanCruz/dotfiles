# ==============================================================================
# ┌─┐┌─┐┌┬┐┌─┐┬─┐┌─┐┬ ┬  CONFIGURACIÓN DE ZSH
# │ ││ │ ││├┤ ├┬┘└─┐├─┤  por Gemini
# └─┘└─┘─┴┘└─┘┴└─└─┘┴ ┴
# ==============================================================================

# ==============================================================================
# 1. ENTORNO Y PATHS
# ==============================================================================
# Define el editor y paginador por defecto.
export EDITOR='nvim'
export PAGER='less'

# Añade Homebrew al PATH.
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Configuración de NVM (Node Version Manager).
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Añade bin al path
export PATH="$HOME/.local/bin:$PATH"

# Aumenta el límite de anidamiento de funciones para evitar errores con Starship/ZLE.
export FUNCNEST=1000

# Configuración de Claude Code - Límite de tokens de salida
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=100000

# ==============================================================================
# 2. ALIASES PARA HERRAMIENTAS MODERNAS
# ==============================================================================
# Para que los iconos funcionen, necesitas instalar una Nerd Font (ej. FiraCode Nerd Font).
alias ls='eza --icons'         # ls normal
alias l='eza -l --icons'       # Lista detallada
alias la='eza -la --icons'     # Lista detallada, incluye ocultos
alias ll='eza -l --git --icons' # Lista detallada con estado de Git
alias lt='eza --tree --level=2' # Vista de árbol

alias cat='bat --paging=never' # Reemplaza cat con bat (sin paginador por defecto)

# --- Gestión de Tmux ---
alias tn='tmux new -s'      # Crear una nueva sesión con nombre. Uso: tn <nombre>
alias ta='tmux a'   # Conectarse a una sesión existente. Uso: ta <nombre>
alias tl='tmux ls'          # Listar todas las sesiones activas.
alias tk='tmux kill-session -t' # Matar una sesión específica. Uso: tk <nombre>
alias tks='tmux kill-server'    # Matar todas las sesiones.

# --- Git y LazyGit ---
alias g='git'
alias lg='lazygit'          # Inicia la interfaz de LazyGit

alias gs='git status -s'    # Estado de git (versión corta)
alias gst='git status'      # Estado de git (versión completa)
alias ga='git add'
alias gaa='git add -A'      # Añadir todos los cambios
alias gc='git commit -m'    # Hacer commit con mensaje. Uso: gc "mi mensaje"
alias gca='git commit -am'  # Añadir todos los cambios y hacer commit
alias gp='git push'
alias gpl='git pull'
alias gco='git checkout'
alias gcb='git checkout -b' # Crear y cambiar a una nueva rama
alias gb='git branch'       # Listar ramas
alias gl='git log --oneline --graph --decorate --all' # Log de git bonito y compacto

# --- Navegación y Archivos ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# Eza ya está con 'ls', 'l', 'la', 'll', pero podemos añadir uno para árboles más profundos.
alias llt='eza --tree --level=3' # Vista de árbol con 3 niveles

# Alias más seguros y verbosos para operaciones de archivos
alias cp='cp -iv'   # Confirma antes de sobreescribir y muestra qué se copió
alias mv='mv -iv'   # Confirma antes de mover/renombrar y muestra qué se movió
alias mkdir='mkdir -p' # Crea directorios padres si no existen

# --- Alias para Comandos de Zoxide ---
alias za='zi'                  # 'zoxide ask' - Inicia la búsqueda interactiva (con fzf)
alias zq='zoxide query -ls'    # 'zoxide query' - Muestra tu base de datos de carpetas y sus puntuaciones
alias zrm='zoxide remove'      # 'zoxide remove' - Elimina una ruta de la base de datos

# --- Edición y Configuración ---
alias v='nvim'
alias vim='nvim' # Para la memoria muscular
alias sv='sudo nvim' # Editar archivos de sistema

alias zshrc='nvim ~/.zshrc'      # Editar la configuración de Zsh
alias tmuxconf='nvim ~/.tmux.conf' # Editar la configuración de Tmux
alias nvimconf='cd ~/.config/nvim && nvim .' # Abrir toda la configuración de Nvim

# --- Utilidades ---
alias grep='grep --color=auto'
alias ff='fd --hidden'  # 'find file', busca también en archivos ocultos con 'fd'
alias rg='rg -i'        # 'ripgrep' sin distinguir mayúsculas/minúsculas por defecto
alias t='touch'         # para crear archivos
alias yz='yazi'
alias c='clear'
alias e='exit'

# Muestra las carpetas que más ocupan en el directorio actual
alias ducks='du -sh * | sort -rh | head -n 10'

# Obtener tu IP pública
alias myip='curl ifconfig.me'

# ==============================================================================
# 3. CONFIGURACIÓN DEL HISTORIAL
# ==============================================================================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY

# ==============================================================================
# 4. OPCIONES DE LA SHELL (setopt)
# ==============================================================================
setopt autocd
setopt extendedglob
setopt nomatch
setopt notify
unsetopt beep
setopt AUTO_PUSHD
setopt PUSHD_SILENT
setopt PUSHD_IGNORE_DUPS
setopt LONG_LIST_JOBS
setopt NUMERIC_GLOB_SORT

# ==============================================================================
# 5. SISTEMA DE AUTOCOMPLETADO (con caché para velocidad)
# ==============================================================================
autoload -Uz compinit
if [[ -n ${XDG_CACHE_HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit -i -d "${XDG_CACHE_HOME}/.zcompdump"
else
  compinit -i
fi

# Estilos para el menú de completado.
zstyle ':completion:*' menu select
zstyle ':completion:*:*:*:*:descriptions' format '%B-- %d --%b'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ==============================================================================
# 6. ATRIBUTOS DE TECLADO (Keybindings)
# ==============================================================================
bindkey -v # Modo Vi para la edición de línea de comandos.

# Atajos para la búsqueda inteligente en el historial (requiere plugin).
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# ==============================================================================
# 7. PLUGINS E INICIALIZACIÓN DE APLICACIONES (El orden importa)
# ==============================================================================
# --- Carga de plugins ---
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh # DEBE SER EL ÚLTIMO PLUGIN

# --- Inicialización de aplicaciones ---
# Carga la integración de FZF para Zsh.
source <(fzf --zsh)

# Inicializa zoxide (cd inteligente).
eval "$(zoxide init zsh)"

# Inicializa Starship (prompt). DEBE SER LA ÚLTIMA LÍNEA.
eval "$(starship init zsh)"

# ============================== FIN DE LA CONFIGURACIÓN ===============================

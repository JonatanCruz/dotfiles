# ==============================================================================
# ENVIRONMENT - Variables de entorno y configuración de paths
# ==============================================================================

# Editores y paginadores
export EDITOR='nvim'
export PAGER='less'

# Homebrew - detecta macOS o Linux automáticamente
if [ -x "/opt/homebrew/bin/brew" ]; then
  # macOS Apple Silicon (M1/M2/M3)
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
  # macOS Intel
  eval "$(/usr/local/bin/brew shellenv)"
elif [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  # Linux
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# pyenv (Python Version Manager)
export PYENV_ROOT="$HOME/.pyenv"
if [ -d "$PYENV_ROOT/bin" ]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi

# Paths adicionales
export PATH="$HOME/.local/bin:$PATH"

# Python user packages (macOS specific)
if [ -d "$HOME/Library/Python/3.9/bin" ]; then
  export PATH="$HOME/Library/Python/3.9/bin:$PATH"
fi

# Límite de anidamiento de funciones (para Starship/ZLE)
export FUNCNEST=1000

# Claude Code - Límite de tokens de salida
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=100000

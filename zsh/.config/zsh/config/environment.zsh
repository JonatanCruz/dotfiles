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

# NVM (Node Version Manager) - Lazy loaded for performance (200-300ms savings)
export NVM_DIR="$HOME/.nvm"

# Lazy load NVM only when needed
_lazy_nvm() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

# Use 'function' keyword to prevent alias expansion during parsing
function nvm() { _lazy_nvm; nvm "$@"; }
function node() { _lazy_nvm; node "$@"; }
function npm() { _lazy_nvm; npm "$@"; }
function npx() { _lazy_nvm; npx "$@"; }

# Bun (JavaScript Runtime & Toolkit)
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

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

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# .NET SDK
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# Android SDK - detecta macOS o Linux automáticamente
if [ "$(uname)" = "Darwin" ]; then
  # macOS - ubicación estándar de Android Studio
  export ANDROID_HOME="$HOME/Library/Android/sdk"
else
  # Linux - ubicación estándar de Android SDK
  export ANDROID_HOME="$HOME/Android/Sdk"
fi

# Agregar herramientas de Android al PATH si el SDK existe
if [ -d "$ANDROID_HOME" ]; then
  export PATH="$ANDROID_HOME/emulator:$PATH"
  export PATH="$ANDROID_HOME/platform-tools:$PATH"
  export PATH="$ANDROID_HOME/tools:$PATH"
  export PATH="$ANDROID_HOME/tools/bin:$PATH"
fi

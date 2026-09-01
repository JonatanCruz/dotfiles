# ==============================================================================
# ENVIRONMENT - Variables de entorno y configuración de paths
# ==============================================================================

# Editores y paginadores
export EDITOR='nvim'
export PAGER='less'

# Man pages con syntax highlighting via bat.
# MANROFFOPT="-c" evita que groff emita secuencias de subrayado que bat no
# interpreta; col -bx limpia backspaces y tabs antes de pasar a bat.
if command -v bat &>/dev/null; then
  export MANROFFOPT="-c"
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# Asegurar que $TERM esté definido (necesario para tput en entornos sin terminal)
[[ -z "$TERM" ]] && export TERM=xterm-256color

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

# ==============================================================================
# MISE - Gestor único de versiones (sustituye nvm + pyenv)
# ==============================================================================
# Versiones distintas por proyecto Y por servidor desde una sola herramienta.
# La config base está versionada en mise/.config/mise/config.toml; cada
# proyecto la sobrescribe con su mise.toml (o .nvmrc/.python-version, que mise
# lee gracias a idiomatic_version_file_enable_tools).
#
# `mise activate` instala un hook de precmd que reescribe el PATH al cambiar de
# directorio. No usa shims, así que `node` es el binario real y no un wrapper:
# más rápido por invocación y sin romper el hash de comandos de zsh.
#
# Guard por si el servidor aún no tiene mise: el shell arranca igual.
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

# Bun (JavaScript Runtime & Toolkit)
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

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

# .NET SDK - system install (/usr/bin/dotnet → /usr/lib/dotnet)
export DOTNET_ROOT="/usr/lib/dotnet"
export PATH="$PATH:$HOME/.dotnet/tools"

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

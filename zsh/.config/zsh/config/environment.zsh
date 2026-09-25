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
# FPATH - Reconstruir el directorio de funciones del zsh EN EJECUCIÓN
# ==============================================================================
# El FPATH se hereda EXPORTADO del proceso padre. Tras un `brew upgrade` que
# mueve zsh (p.ej. 5.9 -> 5.9.2), un shell padre de larga vida sigue exportando
# el FPATH viejo apuntando a un Cellar que ya no existe. Todo hijo lo hereda y
# entonces `compinit`, `add-zsh-hook`, `is-at-least` (funciones autoload del
# propio zsh) "no se encuentran" -> se rompen todos los plugins.
#
# La config NO debe confiar en el FPATH heredado. Se deriva el directorio de
# funciones del binario zsh EN EJECUCIÓN ($commands[zsh]) — no del entorno — y
# se antepone, purgando de paso cualquier ruta que ya no exista. Inmune a
# futuros brew upgrades, portable entre macOS/Linux y cualquier versión.
() {
  local zsh_bin zsh_prefix d
  local -a candidates
  zsh_bin="${commands[zsh]:-$(command -v zsh)}"
  zsh_prefix="${zsh_bin:h:h}"   # <prefix>/bin/zsh -> <prefix>

  # Dos layouts según empaquetado: Homebrew aplana a share/zsh/functions;
  # una build estándar lo pone bajo share/zsh/<version>/functions.
  candidates=(
    "${zsh_prefix}/share/zsh/functions"
    "${zsh_prefix}/share/zsh/${ZSH_VERSION}/functions"
  )
  for d in $candidates; do
    [[ -d "$d" ]] && fpath=("$d" $fpath)
  done

  # Purgar rutas muertas heredadas (el Cellar viejo) y deduplicar.
  fpath=(${(u)^fpath:A}(N/))
}

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

# .NET SDK - detecta la ubicación según el sistema
if [ -d "/usr/lib/dotnet" ]; then
  # Linux - instalación del sistema (/usr/bin/dotnet → /usr/lib/dotnet)
  export DOTNET_ROOT="/usr/lib/dotnet"
elif [ -d "/usr/local/share/dotnet" ]; then
  # macOS - instalador oficial
  export DOTNET_ROOT="/usr/local/share/dotnet"
elif [ -n "$HOMEBREW_PREFIX" ] && [ -d "$HOMEBREW_PREFIX/opt/dotnet/libexec" ]; then
  # macOS - vía Homebrew
  export DOTNET_ROOT="$HOMEBREW_PREFIX/opt/dotnet/libexec"
fi
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

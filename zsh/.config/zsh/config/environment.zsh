# ==============================================================================
# ENVIRONMENT - Variables de entorno y configuración de paths
# ==============================================================================

# path/fpath sin duplicados: cada `export PATH="X:$PATH"` de abajo (y los de
# brew/mise) volvería a añadir entradas al anidar shells (tmux, nvim :terminal).
typeset -U path fpath

# ==============================================================================
# _zsh_cached_init <nombre> <binario> [args...]
# ==============================================================================
# Deja en $REPLY el código que imprime `<binario> [args...]` (brew shellenv,
# starship init, …) y lo cachea en ${XDG_CACHE_HOME:-~/.cache}/zsh/init/. El
# llamador hace el eval A NIVEL SUPERIOR (`_zsh_cached_init … && eval "$REPLY"`):
# evaluarlo aquí dentro convertiría sus `typeset` en locales de la función.
#
# Solo vale para generadores cuya salida no depende del entorno (comprobado: la
# de `mise activate` sí depende, ver más abajo). La caché se invalida sola si el
# binario es más nuevo que ella (-nt) o si cambia su ruta real o los argumentos
# (van en la 1.ª línea): un `brew upgrade` cambia la ruta del Cellar aunque el
# binario nuevo traiga un mtime viejo de la bottle.
#
# Desenlaces:
#  - binario ausente (brew en otra ruta, direnv sin instalar) → return 1, nada
#  - el init falla o sale vacío → return 1 y NO se guarda nada
#  - no se puede escribir la caché (HOME de solo lectura, disco lleno) → REPLY
#    trae la salida en vivo: el llamador la evalúa igual, sin caché
#  - dos shells regenerando a la vez → mktemp + mv: nadie lee un archivo a medias
_zsh_cached_init() {
  emulate -L zsh
  local name=$1 bin=$2
  shift 2
  REPLY=
  [[ $bin == /* ]] || bin=${commands[$bin]}
  [[ -n $bin && -x $bin ]] || return 1

  local cache=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/init/$name.zsh
  local stamp="# zsh-init-cache: ${bin:A} $*"
  if [[ -r $cache && ! $bin -nt $cache ]]; then
    REPLY=$(<$cache)
    [[ ${REPLY%%$'\n'*} == "$stamp" ]] && return 0
  fi

  local out
  out=$("$bin" "$@" 2>/dev/null) || { REPLY=; return 1 }
  [[ -n ${out//[[:space:]]/} ]] || { REPLY=; return 1 }
  REPLY=$out

  local tmp
  { [[ -d ${cache:h} ]] || mkdir -p -- ${cache:h} } 2>/dev/null || return 0
  tmp=$(mktemp "${cache:h}/.$name.XXXXXX" 2>/dev/null) || return 0
  if print -r -- "$stamp"$'\n'"$out" 2>/dev/null >| $tmp; then
    mv -f -- $tmp $cache 2>/dev/null || rm -f -- $tmp 2>/dev/null
  else
    rm -f -- $tmp 2>/dev/null
  fi
  return 0
}

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

# Homebrew - detecta macOS (Apple Silicon, Intel) o Linux. `brew shellenv` cuesta
# ~65 ms (arranca Ruby/bash de brew); su salida solo depende del prefijo, así que
# va cacheada. Si brew no existe en ninguna de las tres rutas, no se hace nada.
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  if [[ -x $_brew ]]; then
    _zsh_cached_init brew-shellenv $_brew shellenv && eval "$REPLY"
    break
  fi
done
unset _brew

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
#
# NO se cachea con _zsh_cached_init (a diferencia de brew/starship/fzf): la salida
# de `mise activate zsh` incrusta el PATH LITERAL del momento en que se ejecuta
# (`export PATH='/home/…/shims:…'`) y, en un shell ya activado, también desactiva
# el estado anterior. Cacheada, congelaría un PATH viejo en cada arranque. Cuesta
# ~30 ms.
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
if [[ $OSTYPE == darwin* ]]; then   # $OSTYPE evita el fork de uname
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

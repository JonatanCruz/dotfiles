# ==============================================================================
# COMPLETION - Sistema de autocompletado con caché
# ==============================================================================

# Agregar directorio de completions adicionales al FPATH
if [[ -d ~/.zsh/zsh-completions/src ]]; then
  fpath=(~/.zsh/zsh-completions/src $fpath)
fi

# Agregar directorio de completions de Docker al FPATH
if [[ -d ~/.docker/completions ]]; then
  fpath=(~/.docker/completions $fpath)
fi

autoload -Uz compinit
if [[ -n ${XDG_CACHE_HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit -i -d "${XDG_CACHE_HOME}/.zcompdump"
else
  compinit -i
fi

# Estilos del menú de completado
zstyle ':completion:*' menu select
zstyle ':completion:*:*:*:*:descriptions' format '%B-- %d --%b'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Docker completion - habilitar option-stacking
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

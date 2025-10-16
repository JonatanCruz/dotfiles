# ==============================================================================
# COMPLETION - Sistema de autocompletado con caché
# ==============================================================================

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

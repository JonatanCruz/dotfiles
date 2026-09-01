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

# Caché del zcompdump: revalidar el fpath completo cuesta ~230ms en frío, así
# que solo se hace una vez al día; el resto de arranques usan -C (confía en el
# dump existente sin comprobarlo).
#
# FIX: antes usaba ${XDG_CACHE_HOME}, que NO está definida en este setup — la
# ruta evaluaba a "/.zcompdump" (raíz), el glob nunca encontraba nada y siempre
# caía al else. Resultado: compinit corría SIN caché en cada arranque.
autoload -Uz compinit
_zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompdump"
[[ -d "${_zcompdump:h}" ]] || mkdir -p "${_zcompdump:h}"

# (#qN.mh+24) = glob calificado: archivo normal, modificado hace más de 24h
if [[ -n "$_zcompdump"(#qN.mh+24) ]]; then
  compinit -i -d "$_zcompdump"     # tocado hace >24h -> revalida
else
  compinit -C -i -d "$_zcompdump"  # reciente -> confía en el dump
fi
unset _zcompdump

# ==============================================================================
# COMPORTAMIENTO DEL COMPLETADO
# ==============================================================================
# Adaptado de omacom/omarchy-zsh (shell/zoptions). Los defaults de zsh tienen
# estas cuatro apagadas; casi cualquiera las quiere encendidas.

setopt COMPLETE_IN_WORD   # completar desde el medio de una palabra, no solo al final
setopt ALWAYS_TO_END      # tras completar, mover el cursor al final de la palabra

# LIST_AMBIGUOUS es el no obvio: ante varios candidatos inserta primero el
# PREFIJO COMÚN y solo lista si no queda nada más que completar. Menos ruido
# visual por la misma pulsación.
setopt AUTO_LIST          # listar opciones cuando hay ambigüedad
setopt LIST_AMBIGUOUS     # ...pero primero completar el prefijo compartido
setopt AUTO_MENU          # menú de selección en el Tab repetido

# Estilos del menú de completado
zstyle ':completion:*' menu select
zstyle ':completion:*:*:*:*:descriptions' format '%B-- %d --%b'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Autocompletado case-insensitive
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Docker completion - habilitar option-stacking
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# Shift-Tab retrocede DENTRO del menú de completado ya abierto. El keymap
# principal solo cubre la primera pulsación; menuselect es el keymap activo
# una vez el menú está desplegado.
zmodload zsh/complist 2>/dev/null
bindkey -M menuselect '^[[Z' reverse-menu-complete

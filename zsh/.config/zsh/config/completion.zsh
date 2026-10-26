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
# El default `:-$HOME/.cache` no es opcional: XDG_CACHE_HOME no está definida
# aquí, y sin él la ruta evalúa a "/.zcompdump" y la caché nunca se usa.
autoload -Uz compinit
_zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompdump"
[[ -d "${_zcompdump:h}" ]] || mkdir -p "${_zcompdump:h}" 2>/dev/null

# Dump corrupto (cortado a medias, basura): compinit -C lo cargaría tal cual.
# Un dump válido empieza por "#files:"; si no, se borra (con su .zwc) y compinit
# lo regenera desde cero.
if [[ -f "$_zcompdump" ]]; then
  IFS= read -r _zline < "$_zcompdump" 2>/dev/null
  [[ "$_zline" == '#files: '* ]] || rm -f -- "$_zcompdump" "$_zcompdump.zwc" 2>/dev/null
  unset _zline
fi

# (#qN.mh+24) = glob calificado: archivo normal, modificado hace más de 24h.
# Sin dump (primer arranque o recién borrado) también va por la rama completa.
if [[ ! -f "$_zcompdump" || -n "$_zcompdump"(#qN.mh+24) ]]; then
  compinit -i -d "$_zcompdump"     # >24h o sin dump -> revalida
  # compinit solo reescribe el dump si cambió el número de completions; sin el
  # touch, un fpath estable deja el mtime viejo y TODOS los arranques siguientes
  # pagarían la revalidación completa (~230 ms) en vez de una vez al día.
  touch "$_zcompdump" 2>/dev/null
else
  compinit -C -i -d "$_zcompdump"  # reciente -> confía en el dump
fi

# Versión compilada del dump (zsh la prefiere si es más nueva). Si zcompile falla
# (disco lleno, solo lectura) se sigue usando el dump en texto.
if [[ -s "$_zcompdump" && ( ! -s "$_zcompdump.zwc" || "$_zcompdump" -nt "$_zcompdump.zwc" ) ]]; then
  zcompile "$_zcompdump" 2>/dev/null
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

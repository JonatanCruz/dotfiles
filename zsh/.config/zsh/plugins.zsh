# ==============================================================================
# PLUGINS - Carga de plugins y aplicaciones
# ==============================================================================
# No usamos un gestor de plugins (zinit/antidote/etc) por diseño:
#   - 5 plugins estables, cero crecimiento → no hay job-to-be-done que cubrir
#   - los submódulos dan lock implícito: el SHA de cada plugin está en el gitlink
#     que el repo commitea (`git ls-tree HEAD zsh-plugins/.zsh/`), no en
#     .gitmodules, que solo guarda ruta y URL
#   - los `init` de herramientas van cacheados (_zsh_cached_init, en
#     config/environment.zsh): mismo ahorro que el turbo mode, sin diferir hooks
#   - cero dependencias externas → antifragilidad (no rompemos si X muere)
# Para updatear: ./scripts/update-plugins.sh
# Para benchmark: alias `zsh-bench` (en aliases/utils.zsh)
#
# Orden: zsh-syntax-highlighting va después de los demás plugins, como pide su
# README. Con zsh >= 5.9 ya no envuelve los widgets uno a uno (usa el hook
# zle-line-pre-redraw), así que los widgets creados después (fzf, abajo) también
# se colorean. En zsh < 5.9 sí tendría que ir detrás de todo.

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
source ~/.zsh/zsh-you-should-use/you-should-use.plugin.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ==============================================================================
# INITS DE HERRAMIENTAS (cacheados; si el binario no existe, se omiten)
# ==============================================================================
# fzf: Ctrl-R, Ctrl-T, Alt-C en cada sesión.
_zsh_cached_init fzf fzf --zsh && eval "$REPLY"

# zoxide y direnv se cargan al arrancar, SIN lazy-load. El lazy-load anterior
# (definir z/direnv como funciones que hacían el init en la primera llamada)
# rompía lo que justifica a ambos: sus hooks. zoxide aprende directorios en
# chpwd y direnv carga el .envrc en precmd; con el lazy-load, zoxide no
# aprendía nada y direnv no cargaba .envrc hasta que alguien escribía `z` o
# `direnv` a mano. Cacheados cuestan ~1 ms.
_zsh_cached_init zoxide zoxide init zsh && eval "$REPLY"
_zsh_cached_init direnv direnv hook zsh && eval "$REPLY"

# Google Cloud SDK completion (si está instalado)
if [ -f "/snap/google-cloud-sdk/current/completion.zsh.inc" ]; then
    source "/snap/google-cloud-sdk/current/completion.zsh.inc"
fi

# gh: sin lazy-load. Brew instala _gh en share/zsh/site-functions (ya en el
# fpath) y compinit lo autocarga en el primer Tab; generar `gh completion`
# costaba ~110 ms y duplicaba lo mismo.

# Starship al final: fija PROMPT/RPROMPT y envuelve zle-keymap-select si ya
# existe. Cualquier cosa posterior que toque PROMPT, ese widget o precmd lo
# pisaría; no es un requisito de starship sino de no redefinir el prompt después.
_zsh_cached_init starship starship init zsh --print-full-init && eval "$REPLY"

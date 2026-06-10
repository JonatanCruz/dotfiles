# ==============================================================================
# PLUGINS - Carga de plugins y aplicaciones
# ==============================================================================
# No usamos un gestor de plugins (zinit/antidote/etc) por diseño:
#   - 5 plugins estables, cero crecimiento → no hay job-to-be-done que cubrir
#   - submodules dan lock implícito vía SHA commiteado en .gitmodules
#   - lazy manual (abajo) ya captura el ~80% del beneficio de turbo mode
#   - cero dependencias externas → antifragilidad (no rompemos si X muere)
# Para updatear: ./scripts/update-plugins.sh
# Para benchmark: alias `zsh-bench` (en aliases/utils.zsh)
#
# Orden crítico: zsh-syntax-highlighting DEBE SER EL ÚLTIMO plugin (parsea
# el buffer en cada keystroke; cualquier widget registrado después no se
# colorea correctamente).

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
source ~/.zsh/zsh-you-should-use/you-should-use.plugin.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh  # MUST BE LAST PLUGIN

# FZF se carga eager: lo usamos en cada sesión interactiva (Ctrl-R, Ctrl-T).
# Lazy load aquí solo introduciría latencia en el primer uso sin ahorro real.
source <(fzf --zsh)

# Lazy load: comandos que solo se usan ocasionalmente. La primera invocación
# define el comando real y se ejecuta normalmente; las siguientes son directas.
# Ahorra ~150ms en startup interactivo (zoxide/direnv/gh combinados).
_lazy_zoxide() {
  unset -f z zi
  eval "$(zoxide init zsh)"
}
function z() { _lazy_zoxide; z "$@"; }
function zi() { _lazy_zoxide; zi "$@"; }

_lazy_direnv() {
  unset -f direnv
  eval "$(direnv hook zsh)"
}
function direnv() { _lazy_direnv; direnv "$@"; }

# Google Cloud SDK completion (si está instalado)
if [ -f "/snap/google-cloud-sdk/current/completion.zsh.inc" ]; then
    source "/snap/google-cloud-sdk/current/completion.zsh.inc"
fi

# Lazy load GitHub CLI completion
if command -v gh &> /dev/null; then
  _lazy_gh() {
    unset -f gh
    eval "$(command gh completion -s zsh)"
  }
  # Unalias gh if it exists, then create function
  # Use 'function' keyword to prevent alias expansion during parsing
  unalias gh 2>/dev/null || true
  function gh() { _lazy_gh; command gh "$@"; }
fi

eval "$(starship init zsh)"      # Starship prompt (DEBE SER EL ÚLTIMO)

# ==============================================================================
# GIT - Aliases para Git y LazyGit
# ==============================================================================

# LazyGit
alias g='git'
alias lg='lazygit'

# Estado y log
alias gs='git status -s'
alias gst='git status'
alias gl='git log --oneline --graph --decorate --all'

# Staging y commits
alias ga='git add'
alias gaa='git add -A'
alias gc='git commit -m'
alias gca='git commit -am'

# Push y pull
alias gp='git push'
alias gpl='git pull'

# Branches
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'

# ==============================================================================
# WORKTREES
# ==============================================================================
# Adaptado de basecamp/omarchy (default/bash/fns/worktrees).
# La idea que vale: la convención de nombre `repo--rama` hace que el estado
# (qué repo, qué rama) sea derivable del pwd, sin archivo de estado ni lookup.
#
# Cambios sobre el original: nombres gwa/gwr en vez de ga/gd (ga ya es
# `git add` aquí), sin `mise trust`, `gum confirm` -> read nativo, y se
# añadió verificación de errores en cd y en worktree add.

# gwa <rama> — crea worktree + rama hermana del repo actual y entra
gwa() {
  if [[ -z "$1" ]]; then
    echo "Uso: gwa <nombre-de-rama>" >&2
    return 1
  fi

  git rev-parse --is-inside-work-tree &>/dev/null || {
    echo "gwa: no estás dentro de un repo git" >&2
    return 1
  }

  local branch="$1"
  local base="${PWD:t}"          # zsh: basename sin subshell
  local wt_path="../${base}--${branch}"

  if [[ -e "$wt_path" ]]; then
    echo "gwa: ya existe $wt_path" >&2
    return 1
  fi

  # Sin && el cd corre aunque el worktree no se haya creado
  git worktree add -b "$branch" "$wt_path" && cd "$wt_path"
}

# gwr — elimina el worktree actual y su rama, desde dentro del worktree
gwr() {
  local cwd worktree root branch
  cwd="$PWD"
  worktree="${cwd:t}"

  # Split en el primer `--`
  root="${worktree%%--*}"
  branch="${worktree#*--}"

  # Guard: si no hay `--` en el nombre, root == worktree y esto NO es un
  # worktree creado por gwa. Evita borrar un directorio normal.
  if [[ "$root" == "$worktree" ]]; then
    echo "gwr: '$worktree' no sigue la convención repo--rama; no hago nada" >&2
    return 1
  fi

  echo -n "¿Eliminar worktree '$worktree' y la rama '$branch'? [y/N] "
  local reply
  read -r reply
  [[ "$reply" == [yY] ]] || { echo "Cancelado."; return 0; }

  cd "../$root" || { echo "gwr: no pude entrar a ../$root" >&2; return 1; }
  git worktree remove "$cwd" --force || return 1
  git branch -D "$branch"
}

# gwl — lista los worktrees del repo actual
alias gwl='git worktree list'

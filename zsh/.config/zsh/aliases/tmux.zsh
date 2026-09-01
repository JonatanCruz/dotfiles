# ==============================================================================
# TMUX - Gestión de sesiones de tmux
# ==============================================================================

alias tn='tmux new -s'           # Crear nueva sesión: tn <nombre>
alias ta='tmux a'                # Conectarse a sesión: ta <nombre>
alias tl='tmux ls'               # Listar sesiones
alias tk='tmux kill-session -t'  # Matar sesión: tk <nombre>
alias tks='tmux kill-server'     # Matar todas las sesiones

# ==============================================================================
# LAYOUTS DE DESARROLLO
# ==============================================================================
# Portado de basecamp/omarchy (default/bash/fns/tmux), bash -> zsh.
#
# La técnica que vale: capturar el pane id al crearlo con `-P -F '#{pane_id}'`
# y anclar todo a $TMUX_PANE en vez de a "el pane activo". Así el layout no se
# rompe si el foco cambia a mitad del script.
#
# NO se portaron sus alias (`claude --permission-mode auto`, `codex
# --approve-for-me`): rebajan las barreras de permisos en todas las sesiones,
# que es una postura de riesgo, no ergonomía. Pasa el comando que quieras.

# tdl <cmd> [cmd2] — editor a la izq, comando(s) a la der, terminal abajo
tdl() {
  [[ -z "$1" ]] && { echo "Uso: tdl <comando> [segundo-comando]" >&2; return 1 }
  [[ -z "$TMUX" ]] && { echo "tdl: tienes que estar dentro de tmux" >&2; return 1 }

  local current_dir="$PWD"
  local editor_pane cmd_pane cmd2_pane
  local cmd="$1" cmd2="$2"

  # $TMUX_PANE es estable aunque cambie la ventana activa
  editor_pane="$TMUX_PANE"

  tmux rename-window -t "$editor_pane" "${current_dir:t}"
  tmux split-window -v -l 15% -t "$editor_pane" -c "$current_dir"
  cmd_pane=$(tmux split-window -h -l 30% -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')

  if [[ -n "$cmd2" ]]; then
    cmd2_pane=$(tmux split-window -v -t "$cmd_pane" -c "$current_dir" -P -F '#{pane_id}')
    tmux send-keys -t "$cmd2_pane" "$cmd2" C-m
  fi

  tmux send-keys -t "$cmd_pane" "$cmd" C-m
  tmux send-keys -t "$editor_pane" "$EDITOR ." C-m

  # El original tenía aquí `select-pane -t "$opencode_pane"`, una variable que
  # solo existe en tds() — en tdl estaba vacía, así que hacía select-pane -t ""
  # y enfocaba el pane equivocado, justo lo contrario de lo que dice su
  # comentario ("Select the nvim pane for focus").
  tmux select-pane -t "$editor_pane"
}

# tsl <n> <cmd> — n panes en grid, el mismo comando en cada uno
tsl() {
  [[ -z "$1" || -z "$2" ]] && { echo "Uso: tsl <n-panes> <comando>" >&2; return 1 }
  [[ -z "$TMUX" ]] && { echo "tsl: tienes que estar dentro de tmux" >&2; return 1 }
  [[ "$1" == <-> ]] || { echo "tsl: '$1' no es un número" >&2; return 1 }
  (( $1 >= 1 && $1 <= 16 )) || { echo "tsl: usa entre 1 y 16 panes" >&2; return 1 }

  local count="$1" cmd="$2" current_dir="$PWD"
  local -a panes
  local new_pane pane

  tmux rename-window -t "$TMUX_PANE" "${current_dir:t}"
  panes=("$TMUX_PANE")

  while (( ${#panes[@]} < count )); do
    new_pane=$(tmux split-window -h -t "${panes[-1]}" -c "$current_dir" -P -F '#{pane_id}') || return 1
    panes+=("$new_pane")
    tmux select-layout -t "${panes[1]}" tiled
  done

  for pane in "${panes[@]}"; do
    tmux send-keys -t "$pane" "$cmd" C-m
  done

  tmux select-pane -t "${panes[1]}"
}

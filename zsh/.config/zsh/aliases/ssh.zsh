# ==============================================================================
# SSH - Limpieza de terminal y reconexión automática
# ==============================================================================
# Portado de basecamp/omarchy (default/bash/fns/ssh-reconnect), de bash a zsh.
#
# El problema: un tmux o nvim remoto arma modos de terminal sobre la tubería
# SSH (mouse tracking, focus reporting, pantalla alternativa) que solo él
# puede desarmar. Si la conexión muere en vez de salir limpio, esos modos
# quedan armados en tu terminal LOCAL y cada movimiento del ratón vomita
# escapes en el prompt.
#
# Diferencias con el original (bash -> zsh):
#   - $SECONDS es float en zsh; se usa $EPOCHSECONDS (entero) via zsh/datetime
#   - ${letters:i:1} es indexado 0 en bash; en zsh se usa ${letters[i+1]}
#   - Se conserva el "fail closed" de _ssh_interactive tal cual

zmodload zsh/datetime 2>/dev/null

# Desarma mouse tracking (1000/1002/1003 + encoding 1006), focus reporting
# (1004) y la pantalla alternativa (1049); vuelve a mostrar el cursor.
_ssh_disarm() {
  printf '\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?1004l\e[?1049l\e[?25h'
}

# Verdadero para sesión interactiva: hay destino y NO hay comando remoto.
# Las letras son las opciones de ssh(1) que consumen un valor, para no
# confundir su argumento con el destino.
_ssh_interactive() {
  local value_opts="BbcDEeFIiJLlmOoPpQRSWw"
  # OJO: en zsh `argv` es sinónimo reservado de $@ dentro de una función;
  # declararlo local lo vacía y el shift de abajo lo consume. De ahí `orig_args`.
  local -a orig_args=("$@")
  local arg letters dest="" opts_done=""
  local i

  while (( $# )); do
    arg="$1"
    shift

    if [[ -z $opts_done && $arg == "--" ]]; then
      opts_done=1
    elif [[ -z $opts_done && $arg == -?* ]]; then
      letters="${arg#-}"
      for (( i = 1; i <= ${#letters}; i++ )); do
        if [[ $value_opts == *"${letters[i]}"* ]]; then
          # El valor va pegado a la letra (-p2222) salvo que la letra cierre
          # el argumento, en cuyo caso consume el siguiente (-p 2222).
          (( i == ${#letters} )) && shift
          break
        fi
      done
    elif [[ -z $dest ]]; then
      dest="$arg"
    else
      return 1
    fi
  done

  [[ -n $dest ]] || return 1

  # Un RemoteCommand de ssh_config o -o se re-ejecutaría al reconectar igual
  # que un comando posicional. `ssh -G` resuelve la config efectiva de esta
  # invocación sin conectar. Falla CERRADO si no puede resolver: un
  # RemoteCommand no detectado no debe repetirse (puede tener efectos
  # secundarios). El "none" explícito cancela un comando configurado.
  local resolved
  resolved=$(command ssh -G "${orig_args[@]}" 2>/dev/null) || return 1
  ! grep -i '^remotecommand ' <<<"$resolved" | grep -qvi '^remotecommand none$'
}

ssh() {
  local rc started

  started=$EPOCHSECONDS
  command ssh "$@"
  rc=$?

  [[ -t 1 ]] || return $rc
  _ssh_disarm

  # Reconecta solo cuando cae una sesión interactiva: ssh sale con 255 en
  # fallos de transporte, pero un 255 rápido sin sesión establecida es un
  # fallo de conexión/auth; el 255 propio de un comando remoto pasa
  # indistinguible y no debe repetir sus efectos; y con stdin redirigido se
  # alimentaría el resto del pipe a un shell remoto nuevo.
  if (( rc != 255 )) || [[ ! -t 0 ]] || ! _ssh_interactive "$@" ||
     (( EPOCHSECONDS - started < 30 )); then
    return $rc
  fi

  # Reintento en subshell: Ctrl-C llega a todo el grupo de procesos en
  # foreground, así que cancela el intento en vuelo y el bucle a la vez.
  (
    while true; do
      echo "Conexión perdida. Reconectando (Ctrl-C para parar)..."
      sleep 2
      command ssh "$@"
      rc=$?
      _ssh_disarm
      (( rc != 255 )) && exit $rc
    done
  )
}

# ==============================================================================
# PORT FORWARDING
# ==============================================================================
# Portado de basecamp/omarchy (default/bash/fns/ssh-port-forwarding).
# Sin estado: los procesos se descubren por su propia línea de comando con
# pgrep, así que no hay archivos de PID que se queden obsoletos.
#
# Caso de uso del manual de Omarchy: reenviar el puerto de un dev server
# remoto a localhost da privilegios de secure-context sin certificados SSL,
# permitiendo probar websockets y service workers contra una caja remota.
#
# Cambios: `command ssh` para saltar el wrapper de reconexión de arriba (un
# forward con -f -N no es interactivo), y `pgrep -fl` porque el -a de Linux
# no imprime la línea de comando en macOS.

# fip <host> <puerto> [puerto...] — abre forwards en background
fip() {
  (( $# < 2 )) && { echo "Uso: fip <host> <puerto1> [puerto2] ..." >&2; return 1 }
  local host="$1"
  shift
  local port
  for port in "$@"; do
    if [[ "$port" != <-> ]]; then
      echo "fip: '$port' no es un puerto válido" >&2
      continue
    fi
    if command ssh -f -N -L "${port}:localhost:${port}" "$host"; then
      echo "Forward activo: localhost:$port -> $host:$port"
    fi
  done
}

# dip <puerto> [puerto...] — cierra forwards
dip() {
  (( $# == 0 )) && { echo "Uso: dip <puerto1> [puerto2] ..." >&2; return 1 }
  local port
  for port in "$@"; do
    if pkill -f "ssh.*-L ${port}:localhost:${port}"; then
      echo "Forward cerrado en el puerto $port"
    else
      echo "No había forward en el puerto $port"
    fi
  done
}

# lip — lista los forwards activos
lip() {
  pgrep -fl "ssh.*-L [0-9]+:localhost:[0-9]+" || echo "Sin forwards activos"
}

# ==============================================================================
# RSYNC-ON-CHANGE
# ==============================================================================
# Portado de basecamp/omarchy (default/bash/fns/rsyncing).
# Sincroniza un directorio local a un destino remoto cada vez que cambia.
#
# Dos ideas del original que vale la pena conservar:
#  1. Multiplexado SSH (ControlMaster + ControlPersist): una sola conexión por
#     login, así el gestor de credenciales pide la clave una vez y no en cada
#     rsync.
#  2. El proceso se auto-etiqueta pasando 'rsw-watch' como $0 al shell hijo,
#     de modo que lsw/dsw lo encuentran con pgrep SIN archivos de PID que se
#     queden obsoletos.
#
# Cambios para macOS:
#  - inotifywait -> fswatch -1 (espera un evento y sale, igual que inotifywait)
#  - setsid --fork no existe -> nohup en subshell
#  - pgrep -af -> -fl (el -a de Linux no imprime la cmdline en macOS)
#
# Requiere: brew install fswatch

# rsw <origen> <destino> — sincroniza en background ante cada cambio
rsw() {
  (( $# != 2 )) && { echo "Uso: rsw <origen> <destino-rsync>" >&2; return 1 }

  command -v fswatch &>/dev/null || {
    echo "rsw: falta fswatch (brew install fswatch)" >&2
    return 1
  }

  local src="${1%/}" dest="$2"
  [[ -d "$src" ]] || { echo "rsw: '$src' no es un directorio" >&2; return 1 }

  # Una sola conexión SSH reutilizada por login
  local sockets="${XDG_RUNTIME_DIR:-$HOME/.ssh/sockets}"
  mkdir -p "$sockets"
  local rsh="ssh -o ControlMaster=auto -o ControlPath=$sockets/rsw-%r@%h:%p -o ControlPersist=yes"

  # $0 del shell hijo es 'rsw-watch': así lo descubren lsw/dsw
  # El script va en UNA línea a propósito: pgrep -fl imprime la cmdline
  # completa, y un script multilínea produce una "coincidencia" por línea,
  # rompiendo el parseo de lsw.
  ( nohup env RSYNC_RSH="$rsh" bash -c 'rsync -a "$1/" "$2"; while fswatch -1 -r "$1" >/dev/null; do rsync -a "$1/" "$2"; done' rsw-watch "$src" "$dest" >/dev/null 2>&1 & )

  echo "Sincronizando $src -> $dest"
}

# lsw — lista los watchers activos
lsw() {
  local line pid rest found=0
  # Solo las líneas que llevan la etiqueta rsw-watch seguida de los 2 paths
  for line in ${(f)"$(pgrep -fl 'rsw-watch ' 2>/dev/null)"}; do
    [[ "$line" == *"rsw-watch "* ]] || continue
    pid="${line%% *}"
    rest="${line##*rsw-watch }"
    echo "$pid: ${rest% *} -> ${rest##* }"
    found=1
  done
  (( found )) || echo "Sin watchers activos"
}

# dsw — para todos los watchers
dsw() {
  local pid found=0
  for pid in ${(f)"$(pgrep -f 'rsw-watch ')"}; do
    [[ -z "$pid" ]] && continue
    # Captura los paths ANTES de matar, para saber qué fswatch huérfano matar:
    # nohup desacopla la jerarquía, así que pkill -P no lo alcanza.
    local cmdline src_path
    cmdline="$(ps -o command= -p "$pid" 2>/dev/null)"
    src_path="${${cmdline##*rsw-watch }%% *}"

    if kill "$pid" 2>/dev/null; then
      [[ -n "$src_path" ]] && pkill -f "fswatch -1 -r $src_path" 2>/dev/null
      echo "Watcher detenido (pid $pid)"
      found=1
    fi
  done
  (( found )) || echo "Sin watchers activos"
}

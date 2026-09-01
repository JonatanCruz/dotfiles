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

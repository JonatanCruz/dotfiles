# ==============================================================================
# HISTORY - Configuración del historial de comandos
# ==============================================================================

HISTFILE=~/.zsh_history
HISTSIZE=32768
SAVEHIST=32768

setopt SHARE_HISTORY          # historial compartido entre sesiones abiertas
setopt HIST_IGNORE_SPACE      # un comando que empieza con espacio no se guarda
setopt HIST_VERIFY            # expandir !! y dejarlo editable, no ejecutarlo

# HIST_IGNORE_ALL_DUPS borra la entrada ANTIGUA cuando repites un comando, en
# vez de solo ignorar consecutivos (HIST_IGNORE_DUPS). Con SHARE_HISTORY las
# sesiones intercalan comandos, así que los duplicados casi nunca quedan
# consecutivos y HIST_IGNORE_DUPS apenas filtraba nada. Mejora la señal de Ctrl-R.
# Implica HIST_IGNORE_DUPS, por eso este sustituye al anterior.
setopt HIST_IGNORE_ALL_DUPS

# Normaliza espacios sobrantes antes de guardar, para que "ls   -la" y "ls -la"
# cuenten como el mismo comando (y HIST_IGNORE_ALL_DUPS los deduplique).
setopt HIST_REDUCE_BLANKS

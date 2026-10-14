#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash). BLOQUEA (exit 2) crear o mover un worktree de
# PLATAFORMA fuera de PLATAFORMA/.claude/worktrees/.
#
# Indicación del dueño (2026-10-14): los worktrees no se crean junto al repo
# (p.ej. /home/jonatan/DESARROLLO/PLATAFORMA-algo). Fuera del repo cada comando
# pide aprobación y ensucia DESARROLLO/. La indicación ya se había dado antes y se
# ignoró porque sólo vivía en una conversación: este hook la vuelve estructura.
#
# Contrato Claude Code: stdin JSON { tool_input: { command }, cwd }; exit 2 bloquea.

set -uo pipefail

REPO="/home/jonatan/DESARROLLO/PLATAFORMA"
DESTINO="$REPO/.claude/worktrees/"

payload="$(cat)"
command -v jq >/dev/null 2>&1 || exit 0
crudo="$(printf '%s' "$payload" | jq -r '.tool_input.command // ""')"
cwd="$(printf '%s' "$payload" | jq -r '.cwd // ""')"

# Lo que va entre comillas es texto (un payload de prueba, un mensaje de commit),
# no un comando: se descarta antes de buscar `git worktree add|move`.
cmd="$(printf '%s' "$crudo" | sed -E "s/'[^']*'//g; s/\"[^\"]*\"//g")"

printf '%s' "$cmd" | grep -Eq 'git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+worktree[[:space:]]+(add|move)' || exit 0

# Sólo aplica a este repo: el comando lo nombra o se corre desde él.
case "$cmd $cwd" in
  *"$REPO"*) ;;
  *) exit 0 ;;
esac

# Toma cada token que parezca ruta (absoluta, relativa o con ~) después de add/move
# y exige que caiga dentro de .claude/worktrees/.
rutas="$(printf '%s' "$cmd" | grep -Eo 'worktree[[:space:]]+(add|move)[[:space:]].*' |
  tr ' ' '\n' | grep -E '^(/|\.\.?/|~)' || true)"

[ -z "$rutas" ] && exit 0

while IFS= read -r ruta; do
  [ -z "$ruta" ] && continue
  ruta="${ruta/#\~/$HOME}"
  case "$ruta" in
    /*) absoluta="$ruta" ;;
    *) absoluta="$(cd "${cwd:-$REPO}" 2>/dev/null && realpath -m "$ruta")" ;;
  esac
  # El origen de un `move` es un worktree existente: sólo se valida el destino,
  # que es la última ruta del comando.
  ultima="$absoluta"
done <<< "$rutas"

case "$ultima/" in
  "$DESTINO"*) exit 0 ;;
esac

cat >&2 <<EOF
BLOQUEADO (worktree-dentro-del-repo): los worktrees de PLATAFORMA van en
  $DESTINO<nombre>
nunca junto al repo ni en otra carpeta. Ruta pedida: $ultima

Ejemplo: git worktree add $DESTINO<nombre> -b <rama> origin/main
EOF
exit 2

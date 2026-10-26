#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash). BLOQUEA (exit 2) crear o mover un worktree
# fuera de <repo>/.claude/worktrees/ en los repos que ya usan esa carpeta.
#
# Indicación del dueño (2026-10-14): los worktrees no se crean junto al repo
# (p.ej. ../<repo>-algo). Fuera del repo cada comando pide aprobación y ensucia
# la carpeta padre. La indicación ya se había dado antes y se ignoró porque sólo
# vivía en una conversación: este hook la vuelve estructura.
#
# A qué repo aplica: se deriva del comando, no de una ruta escrita aquí. El repo
# es el de `git -C <dir>` si lo hay, o el del cwd; para un worktree se toma el
# repo PRINCIPAL (`--git-common-dir`). La regla sólo rige si ese repo ya tiene
# `.claude/worktrees/`: es la señal de que adoptó la convención, y evita imponerla
# en repos donde otra herramienta pone los worktrees en otro sitio.
#
# Falla ABIERTO (exit 0) sin jq, con JSON ilegible o fuera de un repo de git: es
# una convención de orden, no un control de seguridad.
#
# Contrato Claude Code: stdin JSON { tool_input: { command }, cwd }; exit 2 bloquea.

set -uo pipefail
set -f

payload="$(cat 2>/dev/null || true)"
command -v jq >/dev/null 2>&1 || exit 0
crudo="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
cwd="$(printf '%s' "$payload" | jq -r '.cwd // empty' 2>/dev/null || true)"
[ -n "$crudo" ] || exit 0
[ -n "$cwd" ] || cwd="$PWD"

# Comillas: el CONTENIDO se conserva (`git worktree add "/ruta"` tiene que dejar
# la ruta), pero sus espacios y separadores pasan a marcadores \037/\036. Así un
# texto de varias palabras (un mensaje de commit que menciona `git worktree add`)
# no forma el patrón, y la ruta entrecomillada sigue siendo un token.
cmd="$(printf '%s' "$crudo" | awk 'BEGIN { RS = "\001" } {
  s = $0; out = ""; q = ""; n = length(s)
  for (i = 1; i <= n; i++) {
    c = substr(s, i, 1)
    if (q == "") {
      if (c == "\\" && i < n) { out = out c substr(s, i + 1, 1); i++; continue }
      if (c == "\047" || c == "\"") { q = c; continue }
      out = out c
    } else if (c == q) {
      q = ""
    } else {
      if (q == "\"" && c == "\\" && i < n) { i++; c = substr(s, i, 1) }
      if (c == " " || c == "\t" || c == "\n") c = "\037"
      else if (c == ";" || c == "&" || c == "|") c = "\036"
      out = out c
    }
  }
  printf "%s", out
}')"

# Sólo cuenta el tramo del `git [-C dir] worktree add|move` hasta el primer
# separador: una ruta de un comando encadenado después no es el destino.
tramo="$(printf '%s' "$cmd" | grep -Eo 'git([[:space:]]+-C[[:space:]]+[^[:space:];&|]+)?[[:space:]]+worktree[[:space:]]+(add|move)([[:space:]][^;&|]*)?' | head -1)"
[ -n "$tramo" ] || exit 0

restaurar() { printf '%s' "$1" | tr '\037\036' ' ;'; }

# Directorio base: el de `-C`, relativo al cwd si no es absoluto.
base="$cwd"
dir_c="$(printf '%s' "$tramo" | sed -nE 's/^git[[:space:]]+-C[[:space:]]+([^[:space:]]+).*/\1/p')"
if [ -n "$dir_c" ]; then
  dir_c="$(restaurar "$dir_c")"
  dir_c="${dir_c/#\~/$HOME}"
  case "$dir_c" in
    /*) base="$dir_c" ;;
    *) base="$cwd/$dir_c" ;;
  esac
fi

comun="$(git -C "$base" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)"
case "$comun" in
  */.git) repo="${comun%/.git}" ;;
  *) exit 0 ;;   # fuera de un repo, o repo bare: no hay convención que aplicar
esac
destino="$repo/.claude/worktrees/"
[ -d "$destino" ] || exit 0

resto="${tramo#*worktree}"
subcomando="$(printf '%s' "$resto" | awk '{print $1}')"

# Argumentos posicionales, saltando opciones y el valor de las que lo llevan
# (`-b <rama>`, `-B <rama>`, `--reason <texto>`).
posicionales=()
saltar_valor=0
for token in $(printf '%s' "$resto" | awk '{ $1 = ""; print }'); do
  if [ "$saltar_valor" -eq 1 ]; then saltar_valor=0; continue; fi
  case "$token" in
    -b | -B | --reason) saltar_valor=1 ;;
    -*) ;;
    *) posicionales+=("$token") ;;
  esac
done

# `add <destino> [ref]` valida el primero; `move <worktree> <destino>`, el segundo.
case "$subcomando" in
  add) ruta="${posicionales[0]:-}" ;;
  move) ruta="${posicionales[1]:-}" ;;
  *) ruta="" ;;
esac
[ -n "$ruta" ] || exit 0

ruta="$(restaurar "$ruta")"
ruta="${ruta/#\~/$HOME}"
case "$ruta" in
  /*) ultima="$(realpath -m -- "$ruta")" ;;
  *) ultima="$(cd "$base" 2>/dev/null && realpath -m -- "$ruta")" ;;
esac
[ -n "$ultima" ] || exit 0

case "$ultima/" in
  "$destino"*) exit 0 ;;
esac

cat >&2 <<EOF
BLOQUEADO (worktree-dentro-del-repo): en este repo los worktrees van en
  $destino<nombre>
nunca junto al repo ni en otra carpeta. Ruta pedida: $ultima

Ejemplo: git worktree add $destino<nombre> -b <rama> origin/main
EOF
exit 2

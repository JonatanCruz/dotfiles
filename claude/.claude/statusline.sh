#!/usr/bin/env bash

# ==============================================================================
# STATUSLINE PERSONALIZADO PARA CLAUDE CODE
# ==============================================================================
# Filosofía: minimalista, accionable. Cada elemento previene un fallo:
#   - context % → evita auto-compact sorpresa
#   - 5h rate limit → evita Black Swan de quedarse sin tokens
#   - git status (dirty/ahead/behind) → evita commits a branch equivocada
#   - 200k warning → evita factura 2x en sesiones largas
#   - worktree (condicional) → evita confusión entre worktrees paralelos
# ==============================================================================

# shellcheck disable=SC2034  # Color variables are used in echo statements
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

# Catppuccin Mocha
ROSEWATER="\033[38;2;245;224;220m"
FLAMINGO="\033[38;2;242;205;205m"
PINK="\033[38;2;245;194;231m"
MAUVE="\033[38;2;203;166;247m"
RED="\033[38;2;243;139;168m"
MAROON="\033[38;2;235;160;172m"
PEACH="\033[38;2;250;179;135m"
YELLOW="\033[38;2;249;226;175m"
GREEN="\033[38;2;166;227;161m"
TEAL="\033[38;2;148;226;213m"
SKY="\033[38;2;137;220;235m"
SAPPHIRE="\033[38;2;116;199;236m"
BLUE="\033[38;2;137;180;250m"
LAVENDER="\033[38;2;180;190;254m"
TEXT="\033[38;2;205;214;244m"
SUBTEXT1="\033[38;2;186;194;222m"
SUBTEXT0="\033[38;2;166;173;200m"
OVERLAY2="\033[38;2;147;153;178m"
OVERLAY1="\033[38;2;127;132;156m"
OVERLAY0="\033[38;2;108;112;134m"
SURFACE2="\033[38;2;88;91;112m"
SURFACE1="\033[38;2;69;71;90m"
SURFACE0="\033[38;2;49;50;68m"

input=$(cat)

# ---------- Extracción JSON ----------
# Un solo jq (antes eran 7). @sh entrega cada campo como literal entre comillas simples,
# seguro para eval. Cada campo va en su propio try: si uno falla (p. ej. "model" es un
# string y .model.display_name da error) solo ese queda vacío, como cuando cada campo
# tenía su propio jq. sub() quita los saltos finales igual que hacía $(...).
model_name=""; current_dir=""; ctx_pct=""; exceeds_200k="false"
five_h_pct=""; five_h_reset=""; worktree_name=""
if command -v jq >/dev/null 2>&1; then
    exceeds_200k=""
    eval "$(printf '%s' "$input" | jq -r '
        def f(e): try (e // "" | tostring | sub("\n+\\z"; "")) catch "";
        @sh "model_name=\(f(.model.display_name // .model.displayName // .display_name // .displayName // .modelDisplayName // .model.id // .id))
             current_dir=\(f(.workspace.current_dir // .workspace.project_dir // .workingDirectory // .working_directory // .cwd))
             ctx_pct=\(f(.context_window.used_percentage))
             exceeds_200k=\(f(.exceeds_200k_tokens // false))
             five_h_pct=\(f(.rate_limits.five_hour.used_percentage))
             five_h_reset=\(f(.rate_limits.five_hour.resets_at))
             worktree_name=\(f(.worktree.name))"' 2>/dev/null)" 2>/dev/null
fi

[ -z "$model_name" ] && model_name="${CLAUDE_MODEL:-Sonnet 4.5}"
[ -z "$current_dir" ] && current_dir="$PWD"

# ---------- OS / SSH ----------
os_icon=""
case "${OSTYPE:-$(uname -s)}" in
    Darwin|darwin*) os_icon=$'' ;;
    Linux|linux*)
        if [ -f /etc/os-release ]; then
            # shellcheck source=/dev/null
            . /etc/os-release
            case "$ID" in
                ubuntu) os_icon=$'' ;;
                debian) os_icon=$'' ;;
                fedora) os_icon=$'' ;;
                arch)   os_icon=$'' ;;
                *)      os_icon=$'' ;;
            esac
        else
            os_icon=$''
        fi
        ;;
    MINGW*|MSYS*|CYGWIN*|msys*|cygwin*) os_icon=$'' ;;
    *) os_icon=$'' ;;
esac

ssh_hostname=""
if [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    ssh_hostname=$(hostname -s 2>/dev/null || hostname | cut -d'.' -f1)
fi

# basename sin fork (mismas reglas: ignora las / finales; "/" sigue siendo "/")
dir_name="$current_dir"
while [ "${#dir_name}" -gt 1 ] && [ "${dir_name%/}" != "$dir_name" ]; do dir_name="${dir_name%/}"; done
[ "$dir_name" = "/" ] || dir_name="${dir_name##*/}"

# ---------- Git (branch + dirty + ahead/behind) ----------
# Un solo `git status --porcelain=v2 --branch` (antes 4-5 llamadas): las cabeceras
# "# branch.head/branch.ab" dan rama y ahead/behind, y cualquier otra línea es un
# cambio (staged/unstaged/untracked). Sin upstream no hay branch.ab: no se muestra nada.
git_segment=""
git_branch=""; dirty=""; ahead_behind=""; ahead=""; behind=""; en_repo=""
if git_st=$(git -C "$current_dir" status --porcelain=v2 --branch 2>/dev/null); then
    en_repo=1
    while IFS= read -r line; do
        case "$line" in
            "# branch.head "*) git_branch="${line#\# branch.head }" ;;
            "# branch.ab "*)
                ab="${line#\# branch.ab }"          # "+A -B"
                ahead="${ab%% *}"; ahead="${ahead#+}"
                behind="${ab##* }"; behind="${behind#-}" ;;
            "# "*) ;;
            ?*) dirty="${YELLOW}●${RESET}" ;;
        esac
    done <<< "$git_st"
    if [ "$git_branch" = "(detached)" ]; then
        # Igual que antes: hash corto con la longitud que elija git (core.abbrev)
        short=$(git -C "$current_dir" rev-parse --short HEAD 2>/dev/null)
        git_branch=""
        [ -n "$short" ] && git_branch="detached@${short}"
    fi
elif git -C "$current_dir" rev-parse --git-dir > /dev/null 2>&1; then
    # Dentro de un repo pero sin árbol de trabajo (bare, o dentro de .git): status
    # falla; se resuelve como hacía la versión anterior.
    en_repo=1
    git_branch=$(git -C "$current_dir" branch --show-current 2>/dev/null)
    if [ -z "$git_branch" ]; then
        short=$(git -C "$current_dir" rev-parse --short HEAD 2>/dev/null)
        [ -n "$short" ] && git_branch="detached@${short}"
    fi
    counts=$(git -C "$current_dir" rev-list --left-right --count '@{u}...HEAD' 2>/dev/null)
    if [ -n "$counts" ]; then
        behind="${counts%%[[:space:]]*}"; ahead="${counts##*[[:space:]]}"
    fi
fi
if [ -n "$en_repo" ]; then
    [ "$ahead"  -gt 0 ] 2>/dev/null && ahead_behind="${ahead_behind}${GREEN}↑${ahead}${RESET}"
    [ "$behind" -gt 0 ] 2>/dev/null && ahead_behind="${ahead_behind}${RED}↓${behind}${RESET}"

    if [ -n "$git_branch" ]; then
        icon_git_branch=$''
        git_segment=" ${DIM}${OVERLAY0}│${RESET} ${MAUVE}${icon_git_branch} ${git_branch}${RESET}${dirty}${ahead_behind}"
    fi
fi

# ---------- Worktree (solo si aplica y difiere del repo principal) ----------
worktree_segment=""
if [ -n "$worktree_name" ] && [ "$worktree_name" != "$dir_name" ]; then
    worktree_segment=" ${DIM}${OVERLAY0}│${RESET} ${TEAL}🌳 ${worktree_name}${RESET}"
fi

# ---------- Context % con barra de 5 bloques + color por threshold ----------
ctx_segment=""
if [ -n "$ctx_pct" ] && [ "$ctx_pct" != "null" ]; then
    ctx_int=$(printf '%.0f' "$ctx_pct" 2>/dev/null || echo "0")
    # Color thresholds: <50 green, 50-79 yellow, 80+ red
    if   [ "$ctx_int" -lt 50 ]; then ctx_color="$GREEN"
    elif [ "$ctx_int" -lt 80 ]; then ctx_color="$YELLOW"
    else                              ctx_color="$RED"
    fi
    # 5-block bar (each block = 20%)
    filled=$(( ctx_int / 20 ))
    [ "$filled" -gt 5 ] && filled=5
    bar=""
    for i in 1 2 3 4 5; do
        if [ "$i" -le "$filled" ]; then bar="${bar}▏"; else bar="${bar}░"; fi
    done
    ctx_segment=" ${DIM}${OVERLAY0}│${RESET} ${ctx_color}🧠 ${ctx_int}% ${bar}${RESET}"
fi

# ---------- 5h rate limit + reset time ----------
rate_segment=""
if [ -n "$five_h_pct" ] && [ "$five_h_pct" != "null" ]; then
    rate_int=$(printf '%.0f' "$five_h_pct" 2>/dev/null || echo "0")
    if   [ "$rate_int" -lt 50 ]; then rate_color="$GREEN"
    elif [ "$rate_int" -lt 80 ]; then rate_color="$YELLOW"
    else                              rate_color="$RED"
    fi
    reset_str=""
    if [ -n "$five_h_reset" ] && [ "$five_h_reset" != "null" ]; then
        # Epoch entero con bash >= 4.2: printf builtin, sin fork. Si no, date (una
        # llamada por variante en vez de comprobar y repetir).
        if [[ "$five_h_reset" =~ ^[0-9]+$ ]] && (( BASH_VERSINFO[0] > 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 2) )); then
            printf -v reset_str '%(%H:%M)T' "$five_h_reset"
        elif r=$(date -r "$five_h_reset" +"%H:%M" 2>/dev/null); then
            reset_str="$r"                                       # macOS
        elif r=$(date -d "@$five_h_reset" +"%H:%M" 2>/dev/null); then
            reset_str="$r"                                       # GNU/Linux
        fi
    fi
    if [ -n "$reset_str" ]; then
        rate_segment=" ${DIM}${OVERLAY0}│${RESET} ${rate_color}⏱ 5h ${rate_int}% →${reset_str}${RESET}"
    else
        rate_segment=" ${DIM}${OVERLAY0}│${RESET} ${rate_color}⏱ 5h ${rate_int}%${RESET}"
    fi
fi

# ---------- 200k threshold warning (solo cuando aplica) ----------
warn_segment=""
if [ "$exceeds_200k" = "true" ]; then
    warn_segment=" ${DIM}${OVERLAY0}│${RESET} ${RED}⚠${RESET}"
fi

# ---------- Construcción final ----------
icon_folder=$''
icon_server=$''

status_line=""
status_line+="${BOLD}${PEACH}󰧑 ${model_name}${RESET}"
status_line+=" ${DIM}${OVERLAY0}│${RESET}"
status_line+=" ${BLUE}${icon_folder} ${dir_name}${RESET}"
status_line+="${git_segment}"
status_line+="${worktree_segment}"
status_line+="${ctx_segment}"
status_line+="${rate_segment}"
status_line+="${warn_segment}"
status_line+=" ${DIM}${OVERLAY0}│${RESET} ${BLUE}${os_icon}${RESET}"
if [ -n "$ssh_hostname" ]; then
    status_line+=" ${YELLOW}${icon_server} ${ssh_hostname}${RESET}"
fi

echo -e "$status_line"

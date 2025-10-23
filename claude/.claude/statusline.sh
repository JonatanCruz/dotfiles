#!/usr/bin/env bash

# ==============================================================================
# STATUSLINE PERSONALIZADO PARA CLAUDE CODE
# ==============================================================================
# Script que genera una línea de estado personalizada con información del
# modelo, directorio actual y rama de git.
# ==============================================================================

# Colores ANSI (Catppuccin Mocha)
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

# Catppuccin Mocha colors
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

# Lee el JSON de stdin
input=$(cat)

# Debug: guardar input para inspección si es necesario
# echo "$input" > /tmp/claude-statusline-debug.json

# Extrae información usando jq con múltiples fallbacks
if command -v jq >/dev/null 2>&1; then
    model_name=$(echo "$input" | jq -r '.model.display_name // .model.displayName // .display_name // .displayName // .modelDisplayName // .model.id // .id // empty' 2>/dev/null)
    current_dir=$(echo "$input" | jq -r '.workspace.current_dir // .workspace.project_dir // .workingDirectory // .working_directory // .cwd // empty' 2>/dev/null)
    project_dir=$(echo "$input" | jq -r '.workspace.project_dir // .projectDirectory // .project_directory // empty' 2>/dev/null)
else
    # Fallback si jq no está disponible
    model_name=""
    current_dir=""
    project_dir=""
fi

# Si no obtuvimos el modelo del JSON, intentar de variables de entorno o default
if [ -z "$model_name" ]; then
    model_name="${CLAUDE_MODEL:-Sonnet 4.5}"
fi

# Si no obtuvimos directorio del JSON, usar PWD
if [ -z "$current_dir" ]; then
    current_dir="$PWD"
fi

# Detecta el sistema operativo
os_icon=""
case "$(uname -s)" in
    Darwin)
        os_icon=""  # macOS
        ;;
    Linux)
        # Detecta distribución específica si es posible
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            case "$ID" in
                ubuntu) os_icon="" ;;
                debian) os_icon="" ;;
                fedora) os_icon="" ;;
                arch) os_icon="" ;;
                *) os_icon="" ;;  # Linux genérico
            esac
        else
            os_icon=""  # Linux genérico
        fi
        ;;
    MINGW*|MSYS*|CYGWIN*)
        os_icon=""  # Windows
        ;;
    *)
        os_icon=""  # Desconocido
        ;;
esac

# Detecta si estamos en SSH
ssh_hostname=""
if [ -n "$SSH_CONNECTION" ] || [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    # Estamos en SSH, obtener hostname
    ssh_hostname=$(hostname -s 2>/dev/null || hostname | cut -d'.' -f1)
fi

# Obtén el nombre del directorio actual (basename)
dir_name=$(basename "$current_dir")

# Obtén la rama de git si estamos en un repositorio
git_branch=""
if git -C "$current_dir" rev-parse --git-dir > /dev/null 2>&1; then
    git_branch=$(git -C "$current_dir" branch --show-current 2>/dev/null)
    # Si no hay rama (detached HEAD), muestra el commit corto
    if [ -z "$git_branch" ]; then
        git_branch=$(git -C "$current_dir" rev-parse --short HEAD 2>/dev/null)
        [ -n "$git_branch" ] && git_branch="detached@${git_branch}"
    fi
fi

# Construye la línea de estado
status_line=""

# Ícono del sistema operativo (siempre visible)
status_line+="${BLUE}${os_icon}${RESET}"

# Hostname (solo si estamos en SSH)
if [ -n "$ssh_hostname" ]; then
    status_line+=" ${YELLOW} ${ssh_hostname}${RESET}"
fi

# Separador antes del modelo
status_line+=" ${DIM}${OVERLAY0}│${RESET}"

# Icono y modelo
status_line+=" ${BOLD}${PEACH}󰧑 ${model_name}${RESET}"

# Separador
status_line+=" ${DIM}${OVERLAY0}│${RESET}"

# Directorio
status_line+=" ${BLUE} ${dir_name}${RESET}"

# Rama de git (si existe)
if [ -n "$git_branch" ]; then
    status_line+=" ${DIM}${OVERLAY0}│${RESET} ${MAUVE} ${git_branch}${RESET}"
fi

# Output de la línea de estado
echo -e "$status_line"

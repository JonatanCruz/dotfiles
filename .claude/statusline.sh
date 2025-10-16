#!/usr/bin/env bash

# ==============================================================================
# STATUSLINE PERSONALIZADO PARA CLAUDE CODE
# ==============================================================================
# Script que genera una línea de estado personalizada con información del
# modelo, directorio actual y rama de git.
# ==============================================================================

# Colores ANSI
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

# Colores de texto
ORANGE="\033[38;5;208m"
BLUE="\033[38;5;39m"
GREEN="\033[38;5;46m"
PURPLE="\033[38;5;141m"
GRAY="\033[38;5;245m"
CYAN="\033[38;5;51m"

# Lee el JSON de stdin
input=$(cat)

# Extrae información usando jq
model_name=$(echo "$input" | jq -r '.modelDisplayName // .modelId // "Claude"')
current_dir=$(echo "$input" | jq -r '.workingDirectory // ""')
project_dir=$(echo "$input" | jq -r '.projectDirectory // ""')

# Obtén el nombre del directorio actual (basename)
if [ -n "$current_dir" ]; then
    dir_name=$(basename "$current_dir")
else
    dir_name=$(basename "$PWD")
fi

# Obtén la rama de git si estamos en un repositorio
git_branch=""
if [ -n "$current_dir" ] && [ -d "$current_dir/.git" ] || git -C "$current_dir" rev-parse --git-dir > /dev/null 2>&1; then
    git_branch=$(cd "$current_dir" && git branch --show-current 2>/dev/null)
fi

# Construye la línea de estado
status_line=""

# Icono y modelo
status_line+="${BOLD}${ORANGE}🤖 ${model_name}${RESET}"

# Separador
status_line+=" ${DIM}${GRAY}|${RESET}"

# Directorio
status_line+=" ${BLUE}📁 ${dir_name}${RESET}"

# Rama de git (si existe)
if [ -n "$git_branch" ]; then
    status_line+=" ${DIM}${GRAY}|${RESET} ${PURPLE} ${git_branch}${RESET}"
fi

# Output de la línea de estado
echo -e "$status_line"

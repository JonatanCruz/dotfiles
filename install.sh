#!/usr/bin/env bash

# ==============================================================================
# DOTFILES INSTALLER
# ==============================================================================
# Script de instalación interactivo para dotfiles usando GNU Stow
# Soporta Linux y macOS
# ==============================================================================

set -e  # Exit on error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Variables globales
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS=""
SELECTED_PACKAGES=()

# ==============================================================================
# FUNCIONES DE UTILIDAD
# ==============================================================================

print_header() {
    echo -e "\n${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║${NC}  ${MAGENTA}${BOLD}DOTFILES INSTALLER${NC}                                          ${CYAN}${BOLD}║${NC}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC}  $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC}  $1"
}

print_step() {
    echo -e "\n${BOLD}${BLUE}→${NC} ${BOLD}$1${NC}"
}

# ==============================================================================
# DETECCIÓN DE SISTEMA OPERATIVO
# ==============================================================================

detect_os() {
    print_step "Detectando sistema operativo..."

    case "$(uname -s)" in
        Linux*)
            OS="Linux"
            print_success "Sistema detectado: Linux"
            ;;
        Darwin*)
            OS="macOS"
            print_success "Sistema detectado: macOS"
            ;;
        *)
            print_error "Sistema operativo no soportado: $(uname -s)"
            exit 1
            ;;
    esac
}

# ==============================================================================
# VERIFICACIÓN DE DEPENDENCIAS
# ==============================================================================

check_dependencies() {
    print_step "Verificando dependencias..."

    local missing_deps=()

    # Verificar stow
    if ! command -v stow &> /dev/null; then
        missing_deps+=("stow")
    fi

    # Verificar git
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi

    if [ ${#missing_deps[@]} -eq 0 ]; then
        print_success "Todas las dependencias están instaladas"
        return 0
    fi

    print_warning "Faltan las siguientes dependencias: ${missing_deps[*]}"
    echo -e "\n${BOLD}Instrucciones de instalación:${NC}"

    if [[ "$OS" == "Linux" ]]; then
        echo -e "  Ubuntu/Debian: ${CYAN}sudo apt install ${missing_deps[*]}${NC}"
        echo -e "  Fedora/RHEL:   ${CYAN}sudo dnf install ${missing_deps[*]}${NC}"
        echo -e "  Arch:          ${CYAN}sudo pacman -S ${missing_deps[*]}${NC}"
    elif [[ "$OS" == "macOS" ]]; then
        echo -e "  Homebrew:      ${CYAN}brew install ${missing_deps[*]}${NC}"
    fi

    echo ""
    read -p "¿Deseas continuar sin instalar las dependencias? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
}

# ==============================================================================
# LISTADO DE PAQUETES
# ==============================================================================

# Definir paquetes disponibles con sus descripciones
declare -A PACKAGE_DESCRIPTIONS=(
    ["nvim"]="Neovim - Editor de texto modular con LSP"
    ["zsh"]="Zsh - Shell configuration con aliases y módulos"
    ["zsh-plugins"]="Zsh Plugins - Autosuggestions, syntax-highlighting, etc."
    ["tmux"]="Tmux - Terminal multiplexer configuration"
    ["starship"]="Starship - Prompt personalizado y minimalista"
    ["yazi"]="Yazi - File manager terminal"
    ["wezterm"]="WezTerm - Terminal emulator"
    ["docker"]="Docker - Completion y configuración"
    ["claude"]="Claude Code - Configuración para Claude Code CLI"
)

# Orden de paquetes para mostrar
PACKAGE_ORDER=("nvim" "zsh" "zsh-plugins" "tmux" "starship" "yazi" "wezterm" "docker" "claude")

get_available_packages() {
    local packages=()
    for pkg in "${PACKAGE_ORDER[@]}"; do
        if [ -d "$DOTFILES_DIR/$pkg" ]; then
            packages+=("$pkg")
        fi
    done
    echo "${packages[@]}"
}

# ==============================================================================
# MENÚ INTERACTIVO
# ==============================================================================

show_package_menu() {
    print_step "Selecciona los paquetes a instalar"
    echo ""

    local packages=($(get_available_packages))
    local choices=()

    # Inicializar array de selecciones (todos desmarcados)
    for i in "${!packages[@]}"; do
        choices[$i]=0
    done

    echo -e "${BOLD}Paquetes disponibles:${NC}\n"

    # Mostrar paquetes con números
    for i in "${!packages[@]}"; do
        local pkg="${packages[$i]}"
        local desc="${PACKAGE_DESCRIPTIONS[$pkg]}"
        printf "  ${CYAN}%2d)${NC} ${BOLD}%-15s${NC} %s\n" $((i+1)) "$pkg" "$desc"
    done

    echo -e "\n${BOLD}Opciones:${NC}"
    echo "  ${CYAN}a)${NC} Instalar todos"
    echo "  ${CYAN}n)${NC} Números separados por espacios (ej: 1 2 3)"
    echo "  ${CYAN}q)${NC} Salir"
    echo ""

    while true; do
        read -p "Selecciona opción: " selection

        case "$selection" in
            a|A)
                # Seleccionar todos
                SELECTED_PACKAGES=("${packages[@]}")
                print_success "Todos los paquetes seleccionados (${#SELECTED_PACKAGES[@]})"
                return 0
                ;;
            q|Q)
                print_info "Instalación cancelada"
                exit 0
                ;;
            *)
                # Procesar números
                SELECTED_PACKAGES=()
                local valid=true

                for num in $selection; do
                    if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#packages[@]}" ]; then
                        SELECTED_PACKAGES+=("${packages[$((num-1))]}")
                    else
                        print_error "Número inválido: $num"
                        valid=false
                        break
                    fi
                done

                if [ "$valid" = true ] && [ ${#SELECTED_PACKAGES[@]} -gt 0 ]; then
                    # Eliminar duplicados
                    SELECTED_PACKAGES=($(echo "${SELECTED_PACKAGES[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
                    print_success "${#SELECTED_PACKAGES[@]} paquete(s) seleccionado(s): ${SELECTED_PACKAGES[*]}"
                    return 0
                fi
                ;;
        esac

        if [ ${#SELECTED_PACKAGES[@]} -eq 0 ]; then
            print_warning "Por favor selecciona al menos un paquete"
        fi
    done
}

# ==============================================================================
# VERIFICACIÓN DE CONFLICTOS
# ==============================================================================

check_conflicts() {
    print_step "Verificando conflictos existentes..."

    local conflicts=()

    for pkg in "${SELECTED_PACKAGES[@]}"; do
        case "$pkg" in
            nvim)
                [ -d "$HOME/.config/nvim" ] && ! [ -L "$HOME/.config/nvim" ] && conflicts+=("~/.config/nvim")
                ;;
            zsh)
                [ -d "$HOME/.config/zsh" ] && ! [ -L "$HOME/.config/zsh" ] && conflicts+=("~/.config/zsh")
                ;;
            zsh-plugins)
                [ -d "$HOME/.zsh" ] && ! [ -L "$HOME/.zsh" ] && conflicts+=("~/.zsh")
                ;;
            tmux)
                [ -f "$HOME/.tmux.conf" ] && ! [ -L "$HOME/.tmux.conf" ] && conflicts+=("~/.tmux.conf")
                ;;
            docker)
                [ -d "$HOME/.docker" ] && ! [ -L "$HOME/.docker" ] && conflicts+=("~/.docker")
                ;;
            starship)
                [ -f "$HOME/.config/starship.toml" ] && ! [ -L "$HOME/.config/starship.toml" ] && conflicts+=("~/.config/starship.toml")
                ;;
            yazi)
                [ -d "$HOME/.config/yazi" ] && ! [ -L "$HOME/.config/yazi" ] && conflicts+=("~/.config/yazi")
                ;;
            wezterm)
                [ -d "$HOME/.config/wezterm" ] && ! [ -L "$HOME/.config/wezterm" ] && conflicts+=("~/.config/wezterm")
                ;;
            claude)
                [ -d "$HOME/.claude" ] && ! [ -L "$HOME/.claude" ] && conflicts+=("~/.claude")
                ;;
        esac
    done

    if [ ${#conflicts[@]} -gt 0 ]; then
        print_warning "Se encontraron archivos/directorios existentes:"
        for conflict in "${conflicts[@]}"; do
            echo "    - $conflict"
        done
        echo ""
        echo "Estos archivos NO son symlinks y podrían causar conflictos."
        echo "Opciones:"
        echo "  1) Hacer backup y continuar (se crearán backups con extensión .backup)"
        echo "  2) Cancelar instalación (recomendado para hacer backup manual)"
        echo ""
        read -p "Selecciona opción (1/2): " -n 1 -r
        echo

        if [[ $REPLY == "1" ]]; then
            for conflict in "${conflicts[@]}"; do
                local backup="${conflict}.backup.$(date +%Y%m%d_%H%M%S)"
                mv "$conflict" "$backup"
                print_success "Backup creado: $backup"
            done
        else
            print_info "Instalación cancelada. Por favor haz backup manual de tus archivos."
            exit 0
        fi
    else
        print_success "No se encontraron conflictos"
    fi
}

# ==============================================================================
# INSTALACIÓN CON STOW
# ==============================================================================

install_packages() {
    print_step "Instalando paquetes con GNU Stow..."

    cd "$DOTFILES_DIR"

    local success_count=0
    local fail_count=0

    for pkg in "${SELECTED_PACKAGES[@]}"; do
        echo ""
        echo -e "${BOLD}Instalando:${NC} $pkg"

        if stow -v "$pkg" 2>&1 | grep -q "LINK"; then
            print_success "$pkg instalado correctamente"
            ((success_count++))
        else
            # Intentar reinstalar si ya existe
            if stow -R -v "$pkg" 2>&1; then
                print_success "$pkg reinstalado correctamente"
                ((success_count++))
            else
                print_error "Error al instalar $pkg"
                ((fail_count++))
            fi
        fi
    done

    echo ""
    echo -e "${BOLD}Resumen de instalación:${NC}"
    print_success "Paquetes instalados: $success_count"
    if [ $fail_count -gt 0 ]; then
        print_error "Paquetes con errores: $fail_count"
    fi
}

# ==============================================================================
# POST-INSTALACIÓN
# ==============================================================================

post_install_notes() {
    print_step "Notas post-instalación"
    echo ""

    local needs_submodules=false

    for pkg in "${SELECTED_PACKAGES[@]}"; do
        case "$pkg" in
            zsh-plugins)
                if [ ! -d "$DOTFILES_DIR/zsh-plugins/.zsh/zsh-autosuggestions/.git" ]; then
                    needs_submodules=true
                fi
                ;;
            zsh)
                echo -e "${BOLD}Zsh:${NC}"
                echo "  - Recarga la configuración: ${CYAN}source ~/.zshrc${NC}"
                echo "  - O reinicia el terminal: ${CYAN}exec zsh${NC}"
                [ "$SHELL" != "$(which zsh)" ] && echo "  - Cambia shell por defecto: ${CYAN}chsh -s \$(which zsh)${NC}"
                echo ""
                ;;
            nvim)
                echo -e "${BOLD}Neovim:${NC}"
                echo "  - Los plugins se instalarán automáticamente al abrir Neovim"
                echo "  - Comando: ${CYAN}nvim${NC}"
                echo "  - Verificar salud: ${CYAN}:checkhealth${NC}"
                echo ""
                ;;
            tmux)
                echo -e "${BOLD}Tmux:${NC}"
                echo "  - Instala TPM (plugin manager): ${CYAN}git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm${NC}"
                echo "  - Dentro de tmux, presiona: ${CYAN}Ctrl+s then Shift+I${NC} para instalar plugins"
                echo ""
                ;;
            docker)
                echo -e "${BOLD}Docker:${NC}"
                echo "  - El autocompletado estará disponible en tu próxima sesión de zsh"
                echo "  - Aliases disponibles: ${CYAN}dps, dc, dcu, dcl, etc.${NC}"
                echo ""
                ;;
        esac
    done

    if [ "$needs_submodules" = true ]; then
        echo -e "${YELLOW}${BOLD}⚠ Importante:${NC} Algunos plugins de zsh necesitan inicializar submodules"
        echo "  Ejecuta: ${CYAN}cd $DOTFILES_DIR && git submodule update --init --recursive${NC}"
        echo ""
    fi

    echo -e "${GREEN}${BOLD}¡Instalación completada!${NC}"
    echo -e "\nPara más información, consulta los archivos README.md en cada directorio."
}

# ==============================================================================
# FUNCIÓN PRINCIPAL
# ==============================================================================

main() {
    print_header

    detect_os
    check_dependencies
    show_package_menu

    echo ""
    echo -e "${BOLD}Paquetes a instalar:${NC}"
    for pkg in "${SELECTED_PACKAGES[@]}"; do
        echo "  • $pkg - ${PACKAGE_DESCRIPTIONS[$pkg]}"
    done
    echo ""

    read -p "¿Continuar con la instalación? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ -n $REPLY ]]; then
        print_info "Instalación cancelada"
        exit 0
    fi

    check_conflicts
    install_packages
    post_install_notes
}

# Ejecutar script
main "$@"

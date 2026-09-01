#!/usr/bin/env bash

# ==============================================================================
# QUICK SETUP SCRIPT - UBUNTU 24.04 LTS
# ==============================================================================
# Script optimizado para configurar entorno de desarrollo completo
# Diseñado específicamente para Ubuntu 24.04 LTS
# ==============================================================================

set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly DOTFILES_DIR
SKIP_PROMPTS=false

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

print_header() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    echo "║          🚀 QUICK SETUP - UBUNTU 24.04 LTS 🚀                 ║"
    echo "║                                                                ║"
    echo "║              Dotfiles Environment Setup                        ║"
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
}

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC}  $1"; }
print_info() { echo -e "${BLUE}ℹ${NC}  $1"; }
print_step() { echo -e "\n${BOLD}${CYAN}▸${NC} ${BOLD}$1${NC}"; }

confirm() {
    if [ "$SKIP_PROMPTS" = true ]; then
        return 0
    fi
    read -p "$(echo -e "${YELLOW}?${NC} $1 (Y/n): ")" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        return 1
    fi
    return 0
}

# ==============================================================================
# INSTALLATION STEPS
# ==============================================================================

step_1_system_update() {
    print_step "Paso 1/10: Actualizando sistema"

    if confirm "¿Actualizar sistema operativo?"; then
        sudo apt update
        sudo apt upgrade -y
        print_success "Sistema actualizado"
    else
        print_warning "Actualización omitida"
    fi
}

step_2_basic_dependencies() {
    print_step "Paso 2/10: Instalando dependencias básicas"

    local packages=(
        git
        stow
        curl
        wget
        build-essential
        software-properties-common
        zsh
        tmux
        fzf
    )

    sudo apt install -y "${packages[@]}"
    print_success "Dependencias básicas instaladas"
}

step_3_neovim() {
    print_step "Paso 3/10: Instalando Neovim (última versión)"

    if command -v nvim &>/dev/null; then
        local version
        version=$(nvim --version | head -n1 | cut -d' ' -f2)
        print_info "Neovim ya instalado: $version"

        if ! confirm "¿Reinstalar Neovim?"; then
            return 0
        fi
    fi

    print_info "Descargando Neovim AppImage..."
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod u+x nvim.appimage

    if [ -f /usr/local/bin/nvim ]; then
        sudo mv /usr/local/bin/nvim /usr/local/bin/nvim.backup
    fi

    sudo mv nvim.appimage /usr/local/bin/nvim
    print_success "Neovim instalado: $(nvim --version | head -n1)"
}

step_4_starship() {
    print_step "Paso 4/10: Instalando Starship prompt"

    if command -v starship &>/dev/null; then
        print_info "Starship ya instalado"
        return 0
    fi

    curl -sS https://starship.rs/install.sh | sh -s -- -y
    print_success "Starship instalado"
}

step_5_cli_tools() {
    print_step "Paso 5/10: Instalando herramientas CLI modernas"

    # ripgrep, fd, bat, fzf (desde repos oficiales)
    sudo apt install -y ripgrep fd-find bat

    # eza (requiere repo externo)
    if ! command -v eza &>/dev/null; then
        print_info "Instalando eza..."
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | \
            sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | \
            sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update
        sudo apt install -y eza
    fi

    # zoxide (navegación inteligente)
    if ! command -v zoxide &>/dev/null; then
        print_info "Instalando zoxide..."
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    fi

    # yazi (file manager)
    if ! command -v yazi &>/dev/null; then
        print_info "Instalando yazi..."
        curl -LO https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.tar.gz
        tar -xzf yazi-x86_64-unknown-linux-gnu.tar.gz
        sudo mv yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin/
        rm -rf yazi-x86_64-unknown-linux-gnu*
    fi

    print_success "Herramientas CLI instaladas"
}

step_6_dev_tools() {
    print_step "Paso 6/10: Instalando herramientas de desarrollo"

    # Node.js (vía NodeSource)
    if ! command -v node &>/dev/null; then
        print_info "Instalando Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt install -y nodejs
    fi

    # Python 3 y pip
    sudo apt install -y python3 python3-pip python3-venv

    # LazyGit
    if ! command -v lazygit &>/dev/null; then
        print_info "Instalando LazyGit..."
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \
            grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz \
            "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit lazygit.tar.gz
    fi

    print_success "Herramientas de desarrollo instaladas"
}

step_7_nerd_font() {
    print_step "Paso 7/10: Instalando Nerd Font"

    local font_dir="$HOME/.local/share/fonts"

    if [ -f "$font_dir/JetBrainsMonoNerdFont-Regular.ttf" ]; then
        print_info "JetBrainsMono Nerd Font ya instalada"
        return 0
    fi

    print_info "Descargando JetBrainsMono Nerd Font..."
    mkdir -p "$font_dir"
    cd "$font_dir"
    wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
    unzip -q JetBrainsMono.zip
    rm JetBrainsMono.zip

    fc-cache -fv >/dev/null 2>&1
    cd "$DOTFILES_DIR"

    print_success "Nerd Font instalada"
    print_warning "¡IMPORTANTE! Configura tu terminal para usar 'JetBrainsMono Nerd Font'"
}

step_8_submodules() {
    print_step "Paso 8/10: Inicializando submodules de Git"

    cd "$DOTFILES_DIR"

    if [ ! -f .gitmodules ]; then
        print_warning "No hay submodules definidos"
        return 0
    fi

    git submodule update --init --recursive
    print_success "Submodules inicializados"
}

step_9_stow() {
    print_step "Paso 9/10: Aplicando configuraciones con Stow"

    cd "$DOTFILES_DIR"

    local packages=(nvim zsh zsh-plugins tmux starship yazi docker claude git)
    local stowed=0

    for pkg in "${packages[@]}"; do
        if [ ! -d "$pkg" ]; then
            continue
        fi

        if stow -R "$pkg" 2>&1 | grep -q "LINK\|UNLINK"; then
            print_success "✓ $pkg"
            ((++stowed))
        else
            print_warning "✗ $pkg (puede requerir backup manual)"
        fi
    done

    print_success "$stowed paquetes aplicados con Stow"
}

step_10_shell_setup() {
    print_step "Paso 10/10: Configurando Zsh como shell por defecto"

    local zsh_path
    zsh_path=$(which zsh)

    if [ "$SHELL" = "$zsh_path" ]; then
        print_success "Zsh ya es el shell por defecto"
        return 0
    fi

    if ! grep -q "$zsh_path" /etc/shells; then
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi

    if confirm "¿Cambiar shell por defecto a Zsh?"; then
        chsh -s "$zsh_path"
        print_success "Shell cambiado a Zsh (requiere logout/login)"
    else
        print_info "Puedes cambiar después con: chsh -s $(which zsh)"
    fi
}

# ==============================================================================
# POST-INSTALLATION
# ==============================================================================

post_install_tmux() {
    print_step "Post-instalación: Tmux Plugin Manager"

    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        print_info "TPM ya instalado"
        return 0
    fi

    if confirm "¿Instalar Tmux Plugin Manager (TPM)?"; then
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
        print_success "TPM instalado"
        print_info "Dentro de tmux, presiona: Ctrl+s + Shift+I para instalar plugins"
    fi
}

post_install_summary() {
    echo -e "\n${GREEN}${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}║${NC}                   ${GREEN}✓ INSTALACIÓN COMPLETA${NC}                      ${GREEN}${BOLD}║${NC}"
    echo -e "${GREEN}${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}\n"

    echo -e "${BOLD}📋 Próximos pasos:${NC}\n"

    echo -e "1. ${CYAN}exec zsh${NC}"
    echo -e "   ${BLUE}→${NC} Iniciar nueva sesión de Zsh\n"

    echo -e "2. ${CYAN}nvim${NC}"
    echo -e "   ${BLUE}→${NC} Los plugins se instalarán automáticamente\n"

    echo -e "3. ${CYAN}tmux${NC} y presiona ${CYAN}Ctrl+s + Shift+I${NC}"
    echo -e "   ${BLUE}→${NC} Instalar plugins de Tmux\n"

    echo -e "4. ${CYAN}cd ~/dotfiles && ./scripts/health-check.sh${NC}"
    echo -e "   ${BLUE}→${NC} Verificar instalación completa\n"

    echo -e "${BOLD}⚠️  Importante:${NC}"
    echo -e "  • Configura tu terminal para usar ${YELLOW}JetBrainsMono Nerd Font${NC}"
    echo -e "  • Cierra sesión y vuelve a iniciar para aplicar cambios de shell"
    echo -e "  • Edita ${CYAN}~/.config/git/config${NC} con tu nombre y email\n"

    echo -e "${BOLD}📚 Documentación:${NC}"
    echo -e "  • Guía completa: ${CYAN}~/dotfiles/docs/QUICK_SETUP_UBUNTU.md${NC}"
    echo -e "  • README: ${CYAN}~/dotfiles/README.md${NC}\n"
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -y|--yes) SKIP_PROMPTS=true ;;
            -h|--help)
                echo "Uso: $0 [-y|--yes] [-h|--help]"
                echo ""
                echo "Opciones:"
                echo "  -y, --yes    Modo no interactivo (auto-confirmar todo)"
                echo "  -h, --help   Mostrar esta ayuda"
                exit 0
                ;;
            *) echo "Opción desconocida: $1"; exit 1 ;;
        esac
        shift
    done

    print_header

    # Verificar que estamos en Ubuntu
    if [ ! -f /etc/os-release ]; then
        print_error "No se pudo detectar la distribución"
        exit 1
    fi

    . /etc/os-release
    if [ "$ID" != "ubuntu" ]; then
        print_error "Este script está optimizado para Ubuntu 24.04 LTS"
        print_info "Tu distribución: $ID"
        if ! confirm "¿Continuar de todas formas?"; then
            exit 1
        fi
    fi

    print_info "Distribución detectada: $PRETTY_NAME"
    print_info "Directorio dotfiles: $DOTFILES_DIR"
    echo ""

    if ! confirm "¿Comenzar instalación?"; then
        print_info "Instalación cancelada"
        exit 0
    fi

    # Ejecutar pasos de instalación
    step_1_system_update
    step_2_basic_dependencies
    step_3_neovim
    step_4_starship
    step_5_cli_tools
    step_6_dev_tools
    step_7_nerd_font
    step_8_submodules
    step_9_stow
    step_10_shell_setup

    # Post-instalación
    post_install_tmux
    post_install_summary
}

main "$@"

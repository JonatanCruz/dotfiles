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

# Binarios descargados de GitHub: versión FIJA + sha256 (el `digest` que
# GitHub publica para cada asset de la release). Nada de `latest` ni de
# `curl | sh`: lo que se instala con sudo es exactamente lo verificado.
# Para actualizar: cambia la versión y copia el nuevo digest con
#   gh api repos/<owner>/<repo>/releases/tags/<tag> --jq '.assets[] | "\(.name) \(.digest)"'
# Solo x86_64 (el servidor); en otra arquitectura el script se detiene.
readonly NVIM_VERSION="v0.12.5"
readonly NVIM_SHA256="d429822f6994770e3bb10330e0baf21e72b0afe66e0507cb3c631c1c65f4bf41"     # nvim-linux-x86_64.appimage
readonly FZF_VERSION="0.74.4"   # la config de zsh necesita fzf >= 0.48; apt trae 0.44
readonly FZF_SHA256="05e6813a337cc722c3ed07e54a764b75cc5d671e2e60459db0ba696ee5fa7504"      # fzf-*-linux_amd64.tar.gz
readonly STARSHIP_VERSION="v1.27.0"
readonly STARSHIP_SHA256="10c8eb4cb3b761d9bf59ea828444c2dab36c900b7d69a69e08814b286969df89" # starship-x86_64-unknown-linux-musl.tar.gz
readonly YAZI_VERSION="v26.9.1"
readonly YAZI_SHA256="a02fe91d3304294048c681f010f1100856872a4e98ecf6927328e888d40a6ad2"     # yazi-x86_64-unknown-linux-gnu.zip
readonly LAZYGIT_VERSION="0.65.1"
readonly LAZYGIT_SHA256="02beacbcda0fa342e50ae3480ba8147307353af3fb28e1d5f790e02329c201a6"  # lazygit_*_linux_x86_64.tar.gz
readonly NERDFONT_VERSION="v3.5.1"
readonly NERDFONT_SHA256="04d5e8f903693f9dd13e16f867e994834e681eb3c72c0d337a770dcda09010cf" # JetBrainsMono.tar.xz

# Directorio temporal para las descargas; se borra al salir
WORK_DIR="$(mktemp -d)"
readonly WORK_DIR
trap 'rm -rf "$WORK_DIR"' EXIT

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

# fetch_verified <url> <sha256> <destino>
# Descarga (curl -f: un 404 es un error, no una página HTML guardada como
# binario) y comprueba el sha256 antes de que nadie use el archivo. Con
# set -e, una suma que no coincide detiene el script.
fetch_verified() {
    local url="$1" sha="$2" dest="$3"
    curl -fsSL --retry 3 -o "$dest" "$url"
    echo "$sha  $dest" | sha256sum -c --quiet -
}

# add_apt_repo <nombre> <url-clave-gpg> <línea-deb>
# Repositorio apt firmado: la clave va a /etc/apt/keyrings y la línea deb la
# referencia con signed-by, así que apt solo acepta paquetes firmados por ella.
add_apt_repo() {
    local name="$1" key_url="$2" deb_line="$3"
    sudo install -d -m 0755 /etc/apt/keyrings
    curl -fsSL "$key_url" | sudo gpg --dearmor --yes -o "/etc/apt/keyrings/$name.gpg"
    echo "deb [signed-by=/etc/apt/keyrings/$name.gpg] $deb_line" | \
        sudo tee "/etc/apt/sources.list.d/$name.list" >/dev/null
    sudo chmod 644 "/etc/apt/keyrings/$name.gpg" "/etc/apt/sources.list.d/$name.list"
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
        ca-certificates
        gpg
        unzip        # el release de yazi es un .zip
        xz-utils     # la Nerd Font es un .tar.xz
        libfuse2t64  # el AppImage de Neovim necesita FUSE 2 (libfuse2 en 24.04)
        gh           # helper de credenciales de git para github.com
        zsh
        tmux
        # fzf NO va por apt: Ubuntu 24.04 trae 0.44 y la config necesita >= 0.48
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

    # El asset ahora se llama nvim-linux-x86_64.appimage; el antiguo
    # nvim.appimage da 404.
    print_info "Descargando Neovim $NVIM_VERSION (AppImage)..."
    local appimage="$WORK_DIR/nvim.appimage"
    fetch_verified \
        "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.appimage" \
        "$NVIM_SHA256" "$appimage"

    if [ -f /usr/local/bin/nvim ]; then
        sudo mv /usr/local/bin/nvim /usr/local/bin/nvim.backup
    fi

    sudo install -m 0755 "$appimage" /usr/local/bin/nvim
    print_success "Neovim instalado: $(/usr/local/bin/nvim --version | head -n1)"
}

step_4_starship() {
    print_step "Paso 4/10: Instalando Starship prompt"

    if command -v starship &>/dev/null; then
        print_info "Starship ya instalado"
        return 0
    fi

    # Release fija y verificada en vez de `curl starship.rs/install.sh | sh`
    local tarball="$WORK_DIR/starship.tar.gz"
    fetch_verified \
        "https://github.com/starship/starship/releases/download/${STARSHIP_VERSION}/starship-x86_64-unknown-linux-musl.tar.gz" \
        "$STARSHIP_SHA256" "$tarball"
    tar -xzf "$tarball" -C "$WORK_DIR" starship
    sudo install -m 0755 "$WORK_DIR/starship" /usr/local/bin/starship
    print_success "Starship instalado: $(starship --version | head -n1)"
}

step_5_cli_tools() {
    print_step "Paso 5/10: Instalando herramientas CLI modernas"

    # ripgrep, fd, bat, zoxide y git-delta (repos oficiales de Ubuntu).
    # git-delta: pager de git/.gitconfig (sin él, git cae a less).
    sudo apt install -y ripgrep fd-find bat zoxide git-delta

    # Debian/Ubuntu instalan fd como `fdfind` y bat como `batcat` (choque de
    # nombres con otros paquetes); los alias y la config usan fd y bat.
    # ~/.local/bin está en el PATH (zsh/config/environment.zsh).
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"

    # eza (repo apt firmado del proyecto)
    if ! command -v eza &>/dev/null; then
        print_info "Instalando eza..."
        add_apt_repo gierens \
            https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
            "http://deb.gierens.de stable main"
        sudo apt update
        sudo apt install -y eza
    fi

    # fzf (release fija; la de apt es demasiado vieja)
    print_info "Instalando fzf $FZF_VERSION..."
    local fzf_tar="$WORK_DIR/fzf.tar.gz"
    fetch_verified \
        "https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tar.gz" \
        "$FZF_SHA256" "$fzf_tar"
    tar -xzf "$fzf_tar" -C "$WORK_DIR" fzf
    sudo install -m 0755 "$WORK_DIR/fzf" /usr/local/bin/fzf

    # yazi (file manager; el release es un .zip con yazi y ya)
    if ! command -v yazi &>/dev/null; then
        print_info "Instalando yazi $YAZI_VERSION..."
        local yazi_zip="$WORK_DIR/yazi.zip"
        fetch_verified \
            "https://github.com/sxyazi/yazi/releases/download/${YAZI_VERSION}/yazi-x86_64-unknown-linux-gnu.zip" \
            "$YAZI_SHA256" "$yazi_zip"
        unzip -q "$yazi_zip" -d "$WORK_DIR"
        sudo install -m 0755 "$WORK_DIR/yazi-x86_64-unknown-linux-gnu/yazi" \
            "$WORK_DIR/yazi-x86_64-unknown-linux-gnu/ya" /usr/local/bin/
    fi

    print_success "Herramientas CLI instaladas"
}

step_6_dev_tools() {
    print_step "Paso 6/10: Instalando herramientas de desarrollo"

    # mise: gestor de versiones de node/python (sustituye a NodeSource, que
    # se instalaba con `curl | sudo bash`). Repo apt firmado del proyecto.
    # Las versiones las declara mise/.config/mise/config.toml; se instalan en
    # post_install_mise, cuando stow ya enlazó esa config.
    if ! command -v mise &>/dev/null; then
        print_info "Instalando mise..."
        add_apt_repo mise https://mise.jdx.dev/gpg-key.pub \
            "https://mise.jdx.dev/deb stable main"
        sudo apt update
        sudo apt install -y mise
    fi

    # Python 3 del sistema (scripts, pip --user); el de proyectos va por mise
    sudo apt install -y python3 python3-pip python3-venv

    # LazyGit (release fija y verificada)
    if ! command -v lazygit &>/dev/null; then
        print_info "Instalando LazyGit $LAZYGIT_VERSION..."
        local lazygit_tar="$WORK_DIR/lazygit.tar.gz"
        fetch_verified \
            "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_linux_x86_64.tar.gz" \
            "$LAZYGIT_SHA256" "$lazygit_tar"
        tar -xzf "$lazygit_tar" -C "$WORK_DIR" lazygit
        sudo install -m 0755 "$WORK_DIR/lazygit" /usr/local/bin/lazygit
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

    # Solo hace falta en la máquina donde corre el terminal (en un servidor
    # al que entras por SSH, la fuente la pone tu terminal local).
    print_info "Descargando JetBrainsMono Nerd Font $NERDFONT_VERSION..."
    mkdir -p "$font_dir"
    local font_tar="$WORK_DIR/JetBrainsMono.tar.xz"
    fetch_verified \
        "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERDFONT_VERSION}/JetBrainsMono.tar.xz" \
        "$NERDFONT_SHA256" "$font_tar"
    tar -xJf "$font_tar" -C "$font_dir"

    if command -v fc-cache &>/dev/null; then
        fc-cache -f >/dev/null 2>&1
    fi

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

    local packages=(nvim zsh zsh-plugins tmux starship yazi docker claude opencode git mise)
    local stowed=0

    for pkg in "${packages[@]}"; do
        if [ ! -d "$pkg" ]; then
            continue
        fi

        # Éxito = código de salida de stow. Antes se buscaba "LINK" en la
        # salida, que stow solo imprime con -v: todo paquete salía como fallido.
        if stow -R -t "$HOME" "$pkg"; then
            print_success "$pkg"
            ((++stowed))
        else
            print_warning "$pkg: conflicto con archivos existentes (muévelos y repite 'stow -R $pkg')"
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

post_install_mise() {
    print_step "Post-instalación: runtimes con mise"

    if ! command -v mise &>/dev/null; then
        print_warning "mise no está instalado; omitido"
        return 0
    fi

    # Instala lo declarado en ~/.config/mise/config.toml (enlazado por stow)
    if mise install; then
        print_success "Runtimes instalados: $(mise ls --current 2>/dev/null | awk '{print $1"@"$2}' | tr '\n' ' ')"
    else
        print_warning "mise install falló; repítelo a mano con 'mise install'"
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
    echo -e "  • Crea ${CYAN}~/.gitconfig-local${NC} con tu [user] name y email (ver git/.gitconfig)"
    echo -e "  • Autentica gh (${CYAN}gh auth login${NC}): git lo usa como helper de credenciales\n"

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

    # Los binarios fijados arriba son x86_64
    if [ "$(uname -m)" != "x86_64" ]; then
        print_error "Arquitectura $(uname -m) no soportada: las descargas fijadas son x86_64"
        exit 1
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
    post_install_mise
    post_install_summary
}

main "$@"

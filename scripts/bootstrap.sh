#!/usr/bin/env bash

# ==============================================================================
# DOTFILES BOOTSTRAP SCRIPT
# ==============================================================================
# Cross-platform automated setup for dotfiles environment
# Supports: Arch Linux, Debian/Ubuntu, macOS
# ==============================================================================

set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly DOTFILES_DIR
BACKUP_DIR="$HOME/.dotfiles-backups/$(date +%Y%m%d_%H%M%S)"
readonly BACKUP_DIR
INTERACTIVE=true
OS=""
DISTRO=""

# Required dependencies
readonly CORE_DEPS=(git stow)
readonly TOOL_DEPS=(neovim tmux zsh starship eza bat fd ripgrep zoxide fzf)
readonly DEV_DEPS=(nodejs python3)

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

print_header() {
    echo -e "\n${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║${NC}  ${MAGENTA}${BOLD}DOTFILES BOOTSTRAP${NC}                                         ${CYAN}${BOLD}║${NC}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}\n"
}

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC}  $1"; }
print_info() { echo -e "${BLUE}ℹ${NC}  $1"; }
print_step() { echo -e "\n${BOLD}${BLUE}→${NC} ${BOLD}$1${NC}"; }

confirm() {
    if [ "$INTERACTIVE" = false ]; then
        return 0
    fi
    read -p "$1 (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# ==============================================================================
# OS DETECTION
# ==============================================================================

detect_os() {
    print_step "Detecting operating system..."

    case "$(uname -s)" in
        Linux*)
            OS="Linux"
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                case "$ID" in
                    arch|manjaro) DISTRO="arch" ;;
                    ubuntu|debian|pop|mint) DISTRO="debian" ;;
                    fedora|rhel|centos) DISTRO="fedora" ;;
                    *) DISTRO="unknown" ;;
                esac
            fi
            print_success "Detected: Linux ($DISTRO)"
            ;;
        Darwin*)
            OS="macOS"
            DISTRO="homebrew"
            print_success "Detected: macOS"
            ;;
        *)
            print_error "Unsupported OS: $(uname -s)"
            exit 1
            ;;
    esac
}

# ==============================================================================
# DEPENDENCY INSTALLATION
# ==============================================================================

install_package_manager() {
    if [ "$OS" = "macOS" ]; then
        if ! command -v brew &>/dev/null; then
            print_step "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

            # Add Homebrew to PATH for current session
            # Apple Silicon Macs use /opt/homebrew, Intel Macs use /usr/local
            if [[ $(uname -m) == "arm64" ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            else
                eval "$(/usr/local/bin/brew shellenv)"
            fi

            print_success "Homebrew installed"
        fi
    fi
}

install_dependencies() {
    print_step "Installing dependencies..."

    local all_deps=("${CORE_DEPS[@]}" "${TOOL_DEPS[@]}" "${DEV_DEPS[@]}")
    local to_install=()

    # Check what needs to be installed
    for dep in "${all_deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            to_install+=("$dep")
        fi
    done

    if [ ${#to_install[@]} -eq 0 ]; then
        print_success "All dependencies already installed"
        return 0
    fi

    print_info "Missing: ${to_install[*]}"

    case "$DISTRO" in
        arch)
            print_info "Installing via pacman..."
            local arch_packages=(git stow neovim tmux zsh starship eza bat fd ripgrep zoxide fzf nodejs python)
            sudo pacman -S --noconfirm --needed "${arch_packages[@]}"
            ;;
        debian)
            print_info "Installing via apt..."
            sudo apt update
            local deb_packages=(git stow neovim tmux zsh curl)
            sudo apt install -y "${deb_packages[@]}"

            # Install modern tools via external sources
            if ! command -v starship &>/dev/null; then
                curl -sS https://starship.rs/install.sh | sh -s -- -y
            fi
            if ! command -v eza &>/dev/null; then
                sudo apt install -y gpg
                mkdir -p /etc/apt/keyrings
                wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
                echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
                sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
                sudo apt update
                sudo apt install -y eza
            fi
            # Install other tools
            sudo apt install -y bat fd-find ripgrep fzf nodejs python3 python3-pip
            ;;
        homebrew)
            print_info "Installing via Homebrew..."
            brew install git stow neovim tmux zsh starship eza bat fd ripgrep zoxide fzf node python
            ;;
        *)
            print_error "Unsupported distribution. Please install manually:"
            echo "  Required: ${all_deps[*]}"
            exit 1
            ;;
    esac

    print_success "Dependencies installed"
}

# ==============================================================================
# BACKUP EXISTING CONFIGS
# ==============================================================================

backup_existing_configs() {
    print_step "Checking for existing configurations..."

    local configs_to_backup=(
        "$HOME/.config/nvim"
        "$HOME/.config/tmux"
        "$HOME/.config/zsh"
        "$HOME/.config/yazi"
        "$HOME/.config/wezterm"
        "$HOME/.tmux.conf"
        "$HOME/.zshrc"
        "$HOME/.claude"
    )

    local needs_backup=false

    for config in "${configs_to_backup[@]}"; do
        if [ -e "$config" ] && [ ! -L "$config" ]; then
            needs_backup=true
            break
        fi
    done

    if [ "$needs_backup" = false ]; then
        print_success "No existing configs to backup"
        return 0
    fi

    print_warning "Found existing configurations"

    if ! confirm "Create backup before proceeding?"; then
        print_info "Skipping backup (manual backup recommended)"
        return 0
    fi

    mkdir -p "$BACKUP_DIR"

    for config in "${configs_to_backup[@]}"; do
        if [ -e "$config" ] && [ ! -L "$config" ]; then
            local basename
            basename=$(basename "$config")
            cp -r "$config" "$BACKUP_DIR/$basename"
            print_success "Backed up: $basename"
        fi
    done

    print_success "Backup created at: $BACKUP_DIR"
}

# ==============================================================================
# GIT SUBMODULES
# ==============================================================================

initialize_submodules() {
    print_step "Initializing git submodules..."

    cd "$DOTFILES_DIR"

    if [ ! -f .gitmodules ]; then
        print_info "No submodules to initialize"
        return 0
    fi

    git submodule update --init --recursive
    print_success "Submodules initialized"
}

# ==============================================================================
# STOW PACKAGES
# ==============================================================================

apply_stow_packages() {
    print_step "Applying dotfiles with GNU Stow..."

    cd "$DOTFILES_DIR"

    local packages=(nvim zsh zsh-plugins tmux starship yazi wezterm docker claude git)
    local success=0
    local failed=0

    for pkg in "${packages[@]}"; do
        if [ ! -d "$pkg" ]; then
            continue
        fi

        if stow -R "$pkg" 2>&1 | grep -q "LINK\|UNLINK"; then
            print_success "Stowed: $pkg"
            ((success++))
        else
            print_warning "Failed to stow: $pkg"
            ((failed++))
        fi
    done

    print_info "Stowed $success packages ($failed failed)"
}

# ==============================================================================
# SHELL CONFIGURATION
# ==============================================================================

set_default_shell() {
    print_step "Configuring default shell..."

    local zsh_path
    zsh_path=$(command -v zsh)

    if [ -z "$zsh_path" ]; then
        print_error "Zsh not found"
        return 1
    fi

    if [ "$SHELL" = "$zsh_path" ]; then
        print_success "Zsh already default shell"
        return 0
    fi

    if ! confirm "Set Zsh as default shell?"; then
        print_info "Skipped shell change"
        return 0
    fi

    if ! grep -q "$zsh_path" /etc/shells; then
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi

    chsh -s "$zsh_path"
    print_success "Default shell set to Zsh (restart required)"
}

# ==============================================================================
# POST-INSTALL
# ==============================================================================

post_install_notes() {
    print_step "Post-installation notes"
    echo ""

    print_info "Next steps:"
    echo "  1. ${CYAN}exec zsh${NC} - Start new Zsh session"
    echo "  2. ${CYAN}nvim${NC} - Open Neovim (plugins auto-install)"
    echo "  3. ${CYAN}git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm${NC}"
    echo "     Then in tmux: ${CYAN}Ctrl+s I${NC} to install plugins"
    echo ""

    print_info "Useful commands:"
    echo "  - ${CYAN}cd ~/dotfiles && ./scripts/health-check.sh${NC} - Verify installation"
    echo "  - ${CYAN}cd ~/dotfiles && ./scripts/snapshot.sh \"post-bootstrap\"${NC} - Create snapshot"
    echo ""

    if [ -d "$BACKUP_DIR" ]; then
        print_warning "Backup location: $BACKUP_DIR"
    fi

    echo -e "\n${GREEN}${BOLD}✓ Bootstrap complete!${NC}\n"
}

# ==============================================================================
# MAIN
# ==============================================================================

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Cross-platform bootstrap script for dotfiles.

OPTIONS:
    -h, --help          Show this help message
    -y, --yes           Non-interactive mode (auto-confirm)
    --no-backup         Skip backup of existing configs
    --no-deps           Skip dependency installation
    --no-stow           Skip stow application

EXAMPLES:
    ./bootstrap.sh                  # Interactive mode
    ./bootstrap.sh -y               # Auto-confirm everything
    ./bootstrap.sh --no-backup      # Skip backup step

EOF
}

main() {
    local skip_backup=false
    local skip_deps=false
    local skip_stow=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help) usage; exit 0 ;;
            -y|--yes) INTERACTIVE=false ;;
            --no-backup) skip_backup=true ;;
            --no-deps) skip_deps=true ;;
            --no-stow) skip_stow=true ;;
            *) print_error "Unknown option: $1"; usage; exit 1 ;;
        esac
        shift
    done

    print_header

    detect_os

    if [ "$skip_deps" = false ]; then
        install_package_manager
        install_dependencies
    fi

    if [ "$skip_backup" = false ]; then
        backup_existing_configs
    fi

    initialize_submodules

    if [ "$skip_stow" = false ]; then
        apply_stow_packages
    fi

    set_default_shell
    post_install_notes
}

main "$@"

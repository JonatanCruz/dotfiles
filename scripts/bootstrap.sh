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

# Required dependencies, by the BINARY each one provides (that is what
# `command -v` can check; package names differ per distro: neovim -> nvim,
# ripgrep -> rg, nodejs -> node, git-delta -> delta). "a|b" accepts either
# name: Debian/Ubuntu install bat and fd as batcat and fdfind.
readonly CORE_DEPS=(git stow)
readonly TOOL_DEPS=(nvim tmux zsh starship eza "bat|batcat" "fd|fdfind" rg zoxide fzf delta)
readonly DEV_DEPS=(node python3)

# Stow packages, shared by the backup step and the stow step
readonly STOW_PACKAGES=(nvim zsh zsh-plugins tmux starship yazi wezterm docker claude opencode git mise)

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
    local dep name found
    for dep in "${all_deps[@]}"; do
        found=false
        IFS='|' read -ra names <<< "$dep"
        for name in "${names[@]}"; do
            if command -v "$name" &>/dev/null; then
                found=true
                break
            fi
        done
        if [ "$found" = false ]; then
            to_install+=("${names[0]}")
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
            local arch_packages=(git stow neovim tmux zsh starship eza bat fd ripgrep zoxide fzf git-delta mise nodejs python)
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
                sudo mkdir -p /etc/apt/keyrings
                wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
                echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
                sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
                sudo apt update
                sudo apt install -y eza
            fi
            # Install other tools. NOTE: apt's fzf is too old on Ubuntu 24.04
            # (0.44, the zsh config needs >= 0.48); quick-setup-ubuntu.sh
            # installs a pinned release instead.
            sudo apt install -y bat fd-find ripgrep zoxide fzf git-delta nodejs python3 python3-pip
            # Debian names the binaries batcat/fdfind; expose them as bat/fd
            # (~/.local/bin is on PATH via zsh/config/environment.zsh)
            mkdir -p "$HOME/.local/bin"
            local alias_name real_name
            for alias_name in bat fd; do
                real_name=$([ "$alias_name" = bat ] && echo batcat || echo fdfind)
                if command -v "$real_name" &>/dev/null; then
                    ln -sf "$(command -v "$real_name")" "$HOME/.local/bin/$alias_name"
                fi
            done
            ;;
        homebrew)
            print_info "Installing via Homebrew..."
            brew install git stow neovim tmux zsh starship eza bat fd ripgrep zoxide fzf git-delta mise node python
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

# Prints, NUL-separated (may repeat; callers dedupe), the paths relative to
# $HOME that would block `stow <pkg>`: for every file the package provides,
#   - a symlinked parent directory that points somewhere else (the symlink
#     itself is the conflict; what it points to is never touched), or
#   - an existing target that is not the dotfiles file itself (a real file,
#     or a symlink pointing elsewhere).
# Existing real directories are fine: stow descends into them.
stow_conflicts() {
    local pkg="$1" src rel target prefix part blocked
    (cd "$DOTFILES_DIR/$pkg" && find . \( -type f -o -type l \) \
        ! -name '.gitignore' ! -path './README*' ! -path './LICENSE*' -print0) |
    while IFS= read -r -d '' src; do
        rel="${src#./}"

        # Walk the parent directories: ~/.config, ~/.config/nvim, ...
        blocked=false
        prefix=""
        IFS='/' read -ra parts <<< "$(dirname "$rel")"
        for part in "${parts[@]}"; do
            [ "$part" = "." ] && continue
            prefix="${prefix:+$prefix/}$part"
            if [ -L "$HOME/$prefix" ]; then
                # A stow-folded directory link into the repo is ours
                if [ "$(readlink -f "$HOME/$prefix")" != "$(readlink -f "$DOTFILES_DIR/$pkg/$prefix")" ]; then
                    printf '%s\0' "$prefix"
                fi
                blocked=true
                break
            fi
        done
        [ "$blocked" = true ] && continue

        target="$HOME/$rel"
        if [ -e "$target" ] || [ -L "$target" ]; then
            if [ "$(readlink -f "$target")" != "$(readlink -f "$DOTFILES_DIR/$pkg/$rel")" ]; then
                printf '%s\0' "$rel"
            fi
        fi
    done
}

backup_existing_configs() {
    print_step "Checking for existing configurations..."

    # Only what would make stow fail is backed up, and it is MOVED (not
    # copied): with `cp` the original stayed in place and stow then aborted
    # on the very files that had just been backed up. Moving whole
    # directories would also take state with them (~/.claude holds sessions
    # and credentials), so only the conflicting files move.
    local conflicts=() pkg rel
    for pkg in "${STOW_PACKAGES[@]}"; do
        [ -d "$DOTFILES_DIR/$pkg" ] || continue
        while IFS= read -r -d '' rel; do
            conflicts+=("$rel")
        done < <(stow_conflicts "$pkg" | sort -zu)
    done

    if [ ${#conflicts[@]} -eq 0 ]; then
        print_success "No existing configs to backup"
        return 0
    fi

    print_warning "Found ${#conflicts[@]} existing files that would block stow:"
    printf '    ~/%s\n' "${conflicts[@]}"

    if ! confirm "Move them to $BACKUP_DIR before proceeding?"; then
        print_info "Skipping backup: stow will fail for those packages"
        return 0
    fi

    for rel in "${conflicts[@]}"; do
        mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
        mv "$HOME/$rel" "$BACKUP_DIR/$rel"
        print_success "Moved: ~/$rel"
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

    local success=0
    local failed=0

    for pkg in "${STOW_PACKAGES[@]}"; do
        if [ ! -d "$pkg" ]; then
            continue
        fi

        # Success is stow's exit status: it only prints LINK/UNLINK with -v,
        # so grepping its output reported every package as failed.
        if stow -R -t "$HOME" "$pkg"; then
            print_success "Stowed: $pkg"
            ((++success))
        else
            print_warning "Failed to stow: $pkg"
            ((++failed))
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
    zsh_path=$(command -v zsh || true)

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
    # echo -e: without it the color variables print a literal \033[...
    echo -e "  1. ${CYAN}exec zsh${NC} - Start new Zsh session"
    echo -e "  2. ${CYAN}nvim${NC} - Open Neovim (plugins auto-install)"
    echo -e "  3. ${CYAN}git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm${NC}"
    echo -e "     Then in tmux: ${CYAN}Ctrl+s I${NC} to install plugins"
    echo -e "  4. ${CYAN}mise install${NC} - Install the node/python versions from mise/config.toml"
    echo ""

    print_info "Useful commands:"
    echo -e "  - ${CYAN}cd ~/dotfiles && ./scripts/health-check.sh${NC} - Verify installation"
    echo -e "  - ${CYAN}cd ~/dotfiles && ./scripts/snapshot.sh \"post-bootstrap\"${NC} - Create snapshot"
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

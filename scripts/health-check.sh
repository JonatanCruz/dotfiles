#!/usr/bin/env bash

# ==============================================================================
# DOTFILES HEALTH CHECK SCRIPT
# ==============================================================================
# Comprehensive verification of dotfiles installation and dependencies
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

# OS Detection
detect_os() {
    case "$(uname -s)" in
        Linux*) OS="Linux" ;;
        Darwin*) OS="macOS" ;;
        *) OS="unknown" ;;
    esac
}
detect_os

# Configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly DOTFILES_DIR

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNING=0

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

print_header() {
    echo -e "\n${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║${NC}  ${BLUE}${BOLD}DOTFILES HEALTH CHECK${NC}                                      ${CYAN}${BOLD}║${NC}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}\n"
}

print_section() {
    echo -e "\n${BOLD}${BLUE}▶ $1${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

check_pass() {
    echo -e "  ${GREEN}✓${NC} $1"
    ((++CHECKS_PASSED))
}

check_fail() {
    echo -e "  ${RED}✗${NC} $1"
    ((++CHECKS_FAILED))
}

check_warn() {
    echo -e "  ${YELLOW}⚠${NC}  $1"
    ((++CHECKS_WARNING))
}

# Ruta canónica, portable. `readlink -f` no existe en macOS anteriores a 12.3,
# así que allí se usa Python. La ruta va como ARGUMENTO (sys.argv[1]), nunca
# interpolada en el código: una ruta con una comilla rompía el script y una con
# `'); …` ejecutaba Python arbitrario. Nunca falla: con set -e, un $(…) fallido
# en una asignación abortaría el health check entero.
resolve_path() {
    if [[ "$OS" == "macOS" ]]; then
        python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "$1" 2>/dev/null || true
    else
        readlink -f "$1" 2>/dev/null || true
    fi
}

# Permisos en octal (p.ej. 600), siguiendo symlinks. GNU stat usa -c y BSD -f;
# se prueba GNU primero porque en Linux `stat -f` existe pero significa otra
# cosa (estado del sistema de archivos). Vacío si no se puede leer.
file_mode() {
    stat -L -c %a "$1" 2>/dev/null || stat -L -f %Lp "$1" 2>/dev/null || true
}

# ==============================================================================
# BINARY CHECKS
# ==============================================================================

check_binaries() {
    print_section "Required Binaries"

    local required_bins=(git stow nvim tmux zsh)
    local optional_bins=(starship eza bat fd rg zoxide fzf node python3)

    for bin in "${required_bins[@]}"; do
        if command -v "$bin" &>/dev/null; then
            local version
            case "$bin" in
                nvim)
                    version=$(nvim --version | head -n1)
                    ;;
                tmux)
                    version=$(tmux -V)
                    ;;
                zsh)
                    version=$(zsh --version)
                    ;;
                git)
                    version=$(git --version)
                    ;;
                stow)
                    # Portable version extraction (BSD grep doesn't support -P)
                    version="stow $(stow --version 2>&1 | head -n1 | sed -E 's/.*([0-9]+\.[0-9]+).*/\1/')"
                    ;;
                *)
                    version=""
                    ;;
            esac
            check_pass "$bin found${version:+ - $version}"
        else
            check_fail "$bin not found (REQUIRED)"
        fi
    done

    echo ""
    for bin in "${optional_bins[@]}"; do
        if command -v "$bin" &>/dev/null; then
            check_pass "$bin found (optional tool)"
        else
            check_warn "$bin not found (optional but recommended)"
        fi
    done
}

# ==============================================================================
# SYMLINK VERIFICATION
# ==============================================================================

check_symlinks() {
    print_section "Symlink Verification"

    # tmux is deliberately absent here: it supports two valid layouts
    # (~/.tmux.conf and ~/.config/tmux/) and is checked separately below.
    local symlinks=(
        "$HOME/.config/nvim:nvim"
        "$HOME/.config/zsh:zsh"
        "$HOME/.zsh:zsh-plugins"
        "$HOME/.config/starship.toml:starship"
        "$HOME/.config/yazi:yazi"
    )

    for entry in "${symlinks[@]}"; do
        local path="${entry%:*}"
        local name="${entry#*:}"

        if [ -L "$path" ]; then
            local target
            target=$(resolve_path "$path")
            if [[ "$target" == *"$DOTFILES_DIR/$name"* ]]; then
                check_pass "$(basename "$path") → $name"
            else
                check_warn "$(basename "$path") symlink points elsewhere: $target"
            fi
        elif [ -e "$path" ]; then
            check_warn "$(basename "$path") exists but is not a symlink"
        else
            check_warn "$(basename "$path") not found (package not installed)"
        fi
    done

    # tmux admite el clásico ~/.tmux.conf o el XDG ~/.config/tmux/. Hay que
    # aceptar ambos: comprobar solo uno da un falso "no instalado".
    local tmux_path=""
    if [ -L "$HOME/.tmux.conf" ]; then
        tmux_path="$HOME/.tmux.conf"
    elif [ -L "$HOME/.config/tmux" ]; then
        tmux_path="$HOME/.config/tmux"
    fi

    if [ -n "$tmux_path" ]; then
        local tmux_target
        tmux_target=$(resolve_path "$tmux_path")
        if [[ "$tmux_target" == *"$DOTFILES_DIR/tmux"* ]]; then
            check_pass "$(basename "$tmux_path") → tmux"
        else
            check_warn "$(basename "$tmux_path") symlink points elsewhere: $tmux_target"
        fi
    elif [ -e "$HOME/.tmux.conf" ] || [ -e "$HOME/.config/tmux" ]; then
        check_warn "tmux config exists but is not a symlink"
    else
        check_warn "tmux config not found (package not installed)"
    fi
}

# ==============================================================================
# STOW LINK COMPLETENESS
# ==============================================================================

# Un `git pull` actualiza los archivos ya enlazados, pero un archivo NUEVO en un
# paquete no existe en $HOME hasta re-correr stow, y falla en silencio (así se
# perdió ~/.tmux-colors.conf). Ojo: `stow -n` sin -v no imprime nada aunque
# falten enlaces; por eso se cuentan las líneas LINK de la salida verbose.
check_stow_links() {
    print_section "Stow Link Completeness"

    if ! command -v stow &>/dev/null; then
        check_fail "stow not installed"
        return
    fi

    local packages=(nvim zsh zsh-plugins tmux starship yazi wezterm docker claude opencode git mise)
    local stow_args=(-n -v -d "$DOTFILES_DIR" -t "$HOME")

    for pkg in "${packages[@]}"; do
        [ -d "$DOTFILES_DIR/$pkg" ] || continue

        # Un paquete sin ningún enlace no se usa en esta máquina (p. ej.
        # wezterm en un servidor sin GUI): no es un fallo, se omite. La salida
        # se captura antes de filtrarla: `stow | grep -q` con pipefail falla
        # por SIGPIPE justo cuando grep encuentra la línea.
        local output missing
        output=$(stow "${stow_args[@]}" -D "$pkg" 2>&1 || true)
        grep -q '^UNLINK:' <<<"$output" || continue

        output=$(stow "${stow_args[@]}" "$pkg" 2>&1) || {
            check_fail "$pkg: stow reports conflicts (run: stow -n -v $pkg)"
            continue
        }
        missing=$(sed -nE 's/^LINK: ([^ ]+) =>.*/\1/p' <<<"$output" | paste -sd ' ' -)

        if [ -n "$missing" ]; then
            check_fail "$pkg: missing links: $missing (run: stow -R $pkg)"
        else
            check_pass "$pkg: all links present"
        fi
    done
}

# ==============================================================================
# NEOVIM HEALTH CHECK
# ==============================================================================

check_neovim() {
    print_section "Neovim Configuration"

    if ! command -v nvim &>/dev/null; then
        check_fail "Neovim not installed"
        return
    fi

    # Check Neovim config exists
    if [ -d "$HOME/.config/nvim" ]; then
        check_pass "Neovim config directory exists"
    else
        check_fail "Neovim config directory missing"
        return
    fi

    # Check init.lua
    if [ -f "$HOME/.config/nvim/init.lua" ]; then
        check_pass "init.lua found"
    else
        check_fail "init.lua missing"
    fi

    # Check lazy.nvim
    if [ -d "$HOME/.local/share/nvim/lazy/lazy.nvim" ]; then
        check_pass "lazy.nvim plugin manager installed"
    else
        check_warn "lazy.nvim not installed (will auto-install on first run)"
    fi

    # Run Neovim health check
    echo -e "\n  ${BOLD}Running :checkhealth...${NC}"
    local health_output
    health_output=$(mktemp)

    if nvim --headless -c 'checkhealth' -c 'quitall' &>"$health_output"; then
        check_pass "Neovim health check completed"

        # Check for common issues
        if grep -qi "error" "$health_output"; then
            check_warn "Health check reported errors (check manually: nvim -c checkhealth)"
        fi
    else
        check_warn "Could not run health check (may need initialization)"
    fi

    rm -f "$health_output"
}

# ==============================================================================
# ZSH CONFIGURATION
# ==============================================================================

check_zsh() {
    print_section "Zsh Configuration"

    if ! command -v zsh &>/dev/null; then
        check_fail "Zsh not installed"
        return
    fi

    # Check default shell
    if [ "$SHELL" = "$(command -v zsh)" ]; then
        check_pass "Zsh is default shell"
    else
        check_warn "Zsh is not default shell (current: $SHELL)"
    fi

    # Check config directory
    if [ -d "$HOME/.config/zsh" ]; then
        check_pass "Zsh config directory exists"
    else
        check_warn "Zsh config directory missing"
    fi

    # Check plugins
    local plugins=(
        "$HOME/.zsh/zsh-autosuggestions"
        "$HOME/.zsh/zsh-syntax-highlighting"
        "$HOME/.zsh/zsh-history-substring-search"
    )

    for plugin in "${plugins[@]}"; do
        local name
        name=$(basename "$plugin")
        if [ -d "$plugin" ]; then
            # These plugins are git SUBMODULES, where .git is a FILE holding a
            # "gitdir:" pointer into the parent's .git/modules/ — not a
            # directory. Testing for a directory could never pass here.
            # git rev-parse handles both layouts.
            if git -C "$plugin" rev-parse --is-inside-work-tree &>/dev/null; then
                check_pass "$name installed (git submodule)"
            else
                check_warn "$name exists but not a git repository"
            fi
        else
            check_warn "$name not found"
        fi
    done

    # Check starship
    if command -v starship &>/dev/null; then
        if [ -f "$HOME/.config/starship.toml" ]; then
            check_pass "Starship prompt configured"
        else
            check_warn "Starship installed but not configured"
        fi
    else
        check_warn "Starship prompt not installed"
    fi
}

# ==============================================================================
# TMUX CONFIGURATION
# ==============================================================================

check_tmux() {
    print_section "Tmux Configuration"

    if ! command -v tmux &>/dev/null; then
        check_fail "Tmux not installed"
        return
    fi

    # Check config
    if [ -f "$HOME/.config/tmux/tmux.conf" ] || [ -f "$HOME/.tmux.conf" ]; then
        check_pass "Tmux config found"
    else
        check_warn "Tmux config not found"
    fi

    # Check TPM (Tmux Plugin Manager)
    if [ -d "$HOME/.tmux/plugins/tpm" ]; then
        check_pass "TPM (Tmux Plugin Manager) installed"

        # Check if plugins are installed
        if [ -d "$HOME/.tmux/plugins/vim-tmux-navigator" ]; then
            check_pass "Tmux plugins initialized"
        else
            check_warn "TPM installed but plugins not initialized (Press Ctrl+s I in tmux)"
        fi
    else
        check_warn "TPM not installed (run: git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm)"
    fi
}

# ==============================================================================
# GIT SUBMODULES
# ==============================================================================

check_submodules() {
    print_section "Git Submodules"

    cd "$DOTFILES_DIR"

    if [ ! -f .gitmodules ]; then
        check_warn "No submodules configured"
        return
    fi

    local submodule_status
    submodule_status=$(git submodule status 2>/dev/null || echo "error")

    if [ "$submodule_status" = "error" ]; then
        check_fail "Could not check submodule status"
        return
    fi

    # Sin `echo | grep -q`: con pipefail, la salida temprana de grep puede matar
    # a echo por SIGPIPE y la tubería daría el resultado contrario.
    if [[ "$submodule_status" == -* || "$submodule_status" == *$'\n'-* ]]; then
        check_warn "Submodules not initialized (run: git submodule update --init --recursive)"
    else
        check_pass "Git submodules initialized"
    fi
}

# ==============================================================================
# SECRET FILE PERMISSIONS
# ==============================================================================

check_secret_perms() {
    print_section "Secret File Permissions"

    local secrets=(
        "$HOME/.config/zsh/secrets.zsh"
        "$HOME/.gitconfig-local"
    )

    for file in "${secrets[@]}"; do
        local name="${file/#$HOME/\~}"
        if [ ! -e "$file" ]; then
            check_pass "$name no existe (nada que proteger)"
            continue
        fi

        local mode
        mode=$(file_mode "$file")
        if [ -z "$mode" ]; then
            check_warn "$name: no se pudieron leer sus permisos"
        elif [ "$mode" = "600" ]; then
            check_pass "$name permisos 600"
        else
            check_warn "$name tiene permisos $mode (debe ser 600): chmod 600 $name"
        fi
    done
}

# ==============================================================================
# STALE CLAUDE SESSIONS
# ==============================================================================

check_stale_claude() {
    print_section "Stale Claude Sessions"

    local reaper="$DOTFILES_DIR/scripts/reap-stale-claude.sh"

    if [ ! -x "$reaper" ]; then
        check_warn "reap-stale-claude.sh not found (skipping)"
        return
    fi

    # Read-only: run the reaper in dry-run mode and report only.
    # health-check must never kill processes — it diagnoses, it doesn't act.
    local output
    output=$("$reaper" 2>/dev/null || true)

    if [[ "$output" == *"Nothing to reap"* ]]; then
        check_pass "No stale Claude sessions"
    elif [[ "$output" == *"Found"* ]]; then
        local summary
        summary=$(echo "$output" | grep "Found" | sed -E 's/\x1b\[[0-9;]*m//g; s/^[^F]*//; s/:$//')
        check_warn "$summary — run: scripts/reap-stale-claude.sh --kill"
    else
        check_warn "Could not determine stale-session state"
    fi
}

# ==============================================================================
# SUMMARY
# ==============================================================================

print_summary() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${BOLD}Health Check Summary${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local total=$((CHECKS_PASSED + CHECKS_FAILED + CHECKS_WARNING))

    echo -e "  ${GREEN}✓ Passed:${NC}   $CHECKS_PASSED"
    echo -e "  ${RED}✗ Failed:${NC}   $CHECKS_FAILED"
    echo -e "  ${YELLOW}⚠ Warnings:${NC} $CHECKS_WARNING"
    echo -e "  ${CYAN}Total:${NC}     $total"

    echo ""

    if [ $CHECKS_FAILED -eq 0 ] && [ $CHECKS_WARNING -eq 0 ]; then
        echo -e "${GREEN}${BOLD}✓ All checks passed! Dotfiles are healthy.${NC}\n"
        return 0
    elif [ $CHECKS_FAILED -eq 0 ]; then
        echo -e "${YELLOW}${BOLD}⚠ Some warnings found. Review above for details.${NC}\n"
        return 0
    else
        echo -e "${RED}${BOLD}✗ Critical issues found. Please fix before using dotfiles.${NC}\n"
        return 1
    fi
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
    print_header

    check_binaries
    check_symlinks
    check_stow_links
    check_neovim
    check_zsh
    check_tmux
    check_submodules
    check_secret_perms
    check_stale_claude

    print_summary
}

main "$@"

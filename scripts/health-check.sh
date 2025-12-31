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
    ((CHECKS_PASSED++))
}

check_fail() {
    echo -e "  ${RED}✗${NC} $1"
    ((CHECKS_FAILED++))
}

check_warn() {
    echo -e "  ${YELLOW}⚠${NC}  $1"
    ((CHECKS_WARNING++))
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
                    version="stow $(stow --version 2>&1 | head -n1 | grep -oP '\d+\.\d+')"
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

    local symlinks=(
        "$HOME/.config/nvim:nvim"
        "$HOME/.config/tmux:tmux"
        "$HOME/.config/zsh:zsh"
        "$HOME/.zsh:zsh-plugins"
        "$HOME/.config/starship.toml:starship"
        "$HOME/.config/yazi:yazi"
        "$HOME/.config/wezterm:wezterm"
    )

    for entry in "${symlinks[@]}"; do
        local path="${entry%:*}"
        local name="${entry#*:}"

        if [ -L "$path" ]; then
            local target
            target=$(readlink -f "$path" 2>/dev/null || readlink "$path")
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
            if [ -d "$plugin/.git" ]; then
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

    if echo "$submodule_status" | grep -q "^-"; then
        check_warn "Submodules not initialized (run: git submodule update --init --recursive)"
    else
        check_pass "Git submodules initialized"
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
    check_neovim
    check_zsh
    check_tmux
    check_submodules

    print_summary
}

main "$@"

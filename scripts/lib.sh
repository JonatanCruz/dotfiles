#!/usr/bin/env bash

# ==============================================================================
# DOTFILES SHARED LIBRARY
# ==============================================================================
# Common utilities for all dotfiles scripts
# 
# Usage:
#   source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
#
# This library provides:
#   - Color constants for terminal output
#   - Print functions (success, error, warning, info, step, header)
#   - OS detection (Linux/macOS with distro detection)
#   - Portable utilities (realpath, stat, etc.)
#   - Validation functions (command checking)
# ==============================================================================

# Guard against double-sourcing
if [[ -n "${DOTFILES_LIB_LOADED:-}" ]]; then
    return 0
fi
readonly DOTFILES_LIB_LOADED=1

# Strict error handling
set -euo pipefail

# ==============================================================================
# COLOR CONSTANTS
# ==============================================================================

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly MAGENTA='\033[0;35m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'  # No Color

# ==============================================================================
# PRINT FUNCTIONS
# ==============================================================================

# Print success message with green checkmark
# Usage: print_success "Operation completed"
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Print error message with red X
# Usage: print_error "Operation failed"
print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Print warning message with yellow triangle
# Usage: print_warning "This might cause issues"
print_warning() {
    echo -e "${YELLOW}⚠${NC}  $1"
}

# Print info message with blue icon
# Usage: print_info "For your information"
print_info() {
    echo -e "${BLUE}ℹ${NC}  $1"
}

# Print section step with arrow
# Usage: print_step "Processing files..."
print_step() {
    echo -e "\n${BOLD}${BLUE}→${NC} ${BOLD}$1${NC}"
}

# Print fancy ASCII box header with custom title
# Usage: print_header "MY SCRIPT TITLE"
print_header() {
    local title="${1:-DOTFILES}"
    local title_length=${#title}
    local padding=$(( (60 - title_length) / 2 ))
    local right_padding=$(( 60 - title_length - padding ))
    
    echo -e "\n${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
    printf "${CYAN}${BOLD}║${NC}  ${MAGENTA}${BOLD}%*s%s%*s${NC}  ${CYAN}${BOLD}║${NC}\n" \
        $padding "" "$title" $right_padding ""
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}\n"
}

# Print section header with separator line
# Usage: print_section "Configuration Files"
print_section() {
    echo -e "\n${BOLD}${BLUE}▶ $1${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# ==============================================================================
# OS DETECTION
# ==============================================================================

# Global variables for OS information (set by detect_os)
# shellcheck disable=SC2034  # Variables are used by scripts that source this library
OS=""
DISTRO=""

# Detect operating system and distribution
# Sets global variables: OS (Linux/macOS) and DISTRO (arch/debian/fedora/homebrew/unknown)
# Usage: detect_os
detect_os() {
    case "$(uname -s)" in
        Linux*)
            OS="Linux"
            if [ -f /etc/os-release ]; then
                # Source OS release file to get distribution info
                # shellcheck disable=SC1091
                . /etc/os-release
                case "$ID" in
                    arch|manjaro) DISTRO="arch" ;;
                    ubuntu|debian|pop|mint) DISTRO="debian" ;;
                    fedora|rhel|centos) DISTRO="fedora" ;;
                    *) DISTRO="unknown" ;;
                esac
            else
                DISTRO="unknown"
            fi
            ;;
        Darwin*)
            OS="macOS"
            DISTRO="homebrew"
            ;;
        *)
            OS="unknown"
            # shellcheck disable=SC2034  # DISTRO is used by sourcing scripts
            DISTRO="unknown"
            return 1
            ;;
    esac
}

# Check if running on macOS
# Returns: 0 if macOS, 1 otherwise
# Usage: if is_macos; then ...; fi
is_macos() {
    [[ "$OS" == "macOS" ]]
}

# Check if running on Linux
# Returns: 0 if Linux, 1 otherwise
# Usage: if is_linux; then ...; fi
is_linux() {
    [[ "$OS" == "Linux" ]]
}

# ==============================================================================
# PATH FUNCTIONS
# ==============================================================================

# Calculate absolute path to dotfiles directory from script location
# This function should be called from scripts/ subdirectory
# Returns: Absolute path to dotfiles root directory
# Usage: DOTFILES_DIR="$(get_dotfiles_dir)"
get_dotfiles_dir() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
    # Go up one level from scripts/ to dotfiles root
    cd "$script_dir/.." && pwd
}

# ==============================================================================
# PORTABLE UTILITIES
# ==============================================================================

# Cross-platform canonical path resolution
# On Linux: uses readlink -f
# On macOS: uses Python (since BSD readlink lacks -f flag)
# Usage: canonical_path=$(portable_realpath "/some/path")
portable_realpath() {
    local path="$1"
    
    if [[ -z "$path" ]]; then
        echo "Error: portable_realpath requires a path argument" >&2
        return 1
    fi
    
    if is_macos; then
        # macOS doesn't have readlink -f, use Python for portability
        python3 -c "import os; print(os.path.realpath('$path'))" 2>/dev/null
    else
        readlink -f "$path" 2>/dev/null
    fi
}

# Get file modification time in a portable way
# On Linux: uses GNU stat -c %y
# On macOS: uses BSD stat -f "%Sm"
# Usage: mod_time=$(portable_stat_time "/path/to/file")
portable_stat_time() {
    local file="$1"
    
    if [[ -z "$file" ]]; then
        echo "Error: portable_stat_time requires a file argument" >&2
        return 1
    fi
    
    if [[ ! -e "$file" ]]; then
        echo "Error: file does not exist: $file" >&2
        return 1
    fi
    
    if is_linux; then
        # GNU stat
        stat -c %y "$file" | cut -d'.' -f1
    else
        # BSD stat (macOS)
        stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file"
    fi
}

# Get file size in human-readable format
# Usage: size=$(portable_file_size "/path/to/file")
portable_file_size() {
    local file="$1"
    
    if [[ -z "$file" ]]; then
        echo "Error: portable_file_size requires a file argument" >&2
        return 1
    fi
    
    if [[ ! -e "$file" ]]; then
        echo "Error: file does not exist: $file" >&2
        return 1
    fi
    
    du -h "$file" | cut -f1
}

# ==============================================================================
# VALIDATION FUNCTIONS
# ==============================================================================

# Check if a command exists in PATH
# Returns: 0 if command exists, 1 otherwise
# Usage: if check_command "git"; then ...; fi
check_command() {
    local cmd="$1"
    command -v "$cmd" &>/dev/null
}

# Require a command to exist, exit with error if not found
# Usage: require_command "git" "Git is required for this operation"
require_command() {
    local cmd="$1"
    local message="${2:-Command \"$cmd\" is required but not found}"
    
    if ! check_command "$cmd"; then
        print_error "$message"
        exit 1
    fi
}

# Validate that script is running inside dotfiles repository
# Checks for existence of .git directory
# Usage: validate_in_dotfiles_repo
validate_in_dotfiles_repo() {
    local dotfiles_dir
    dotfiles_dir="$(get_dotfiles_dir)"
    
    if [[ ! -d "$dotfiles_dir/.git" ]]; then
        print_error "This script must be run from within the dotfiles repository"
        print_info "Expected .git directory at: $dotfiles_dir/.git"
        exit 1
    fi
}

# ==============================================================================
# INTERACTIVE FUNCTIONS
# ==============================================================================

# Interactive yes/no confirmation prompt
# Respects INTERACTIVE environment variable (if false, always returns yes)
# Returns: 0 if user confirms (y/Y), 1 otherwise
# Usage: if confirm "Delete files?"; then ...; fi
confirm() {
    local message="$1"
    
    # Auto-confirm if non-interactive mode
    if [[ "${INTERACTIVE:-true}" == "false" ]]; then
        return 0
    fi
    
    read -p "$message (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# ==============================================================================
# LIBRARY INITIALIZATION
# ==============================================================================

# Auto-detect OS when library is sourced (unless already set)
if [[ -z "$OS" ]]; then
    detect_os
fi

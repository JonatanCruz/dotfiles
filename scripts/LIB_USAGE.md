# lib.sh - Quick Reference Guide

## 🚀 Quick Start

```bash
#!/usr/bin/env bash
set -euo pipefail

# Source the library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

# Now use any function!
print_header "MY SCRIPT"
print_success "Ready to go!"
```

---

## 📚 Function Reference

### Print Functions

```bash
print_success "Operation completed successfully"
print_error "Something went wrong"
print_warning "This might cause issues"
print_info "For your information"
print_step "Starting next phase..."
print_header "SCRIPT TITLE"
print_section "Configuration Files"
```

### OS Detection

```bash
# Auto-detected when sourced, sets: $OS and $DISTRO
print_info "Running on $OS ($DISTRO)"

# Helper functions
if is_macos; then
    print_info "Using Homebrew"
fi

if is_linux; then
    print_info "Using $DISTRO package manager"
fi
```

### Path Functions

```bash
# Get dotfiles root directory
DOTFILES_DIR="$(get_dotfiles_dir)"
readonly DOTFILES_DIR
```

### Portable Utilities

```bash
# Cross-platform canonical path (Linux readlink -f / macOS Python)
config_path=$(portable_realpath "$HOME/.config/nvim")

# Cross-platform file modification time (GNU stat / BSD stat)
mod_time=$(portable_stat_time "$config_path/init.lua")

# File size in human-readable format
size=$(portable_file_size "/path/to/file")
```

### Validation Functions

```bash
# Check if command exists (non-fatal)
if check_command "git"; then
    print_success "Git is installed"
fi

# Require command or exit (fatal)
require_command "stow" "GNU Stow is required"

# Validate running in dotfiles repo
validate_in_dotfiles_repo
```

### Interactive Functions

```bash
# Yes/no prompt (respects INTERACTIVE variable)
if confirm "Delete backup files?"; then
    rm -rf "$BACKUP_DIR"
fi

# Non-interactive mode
INTERACTIVE=false
confirm "This auto-returns yes"  # Always returns 0
```

---

## 🎨 Color Constants

Available colors for custom messages:

```bash
echo -e "${GREEN}Success${NC}"
echo -e "${RED}Error${NC}"
echo -e "${YELLOW}Warning${NC}"
echo -e "${BLUE}Info${NC}"
echo -e "${CYAN}Accent${NC}"
echo -e "${MAGENTA}Highlight${NC}"
echo -e "${BOLD}Bold text${NC}"
```

**Always end with `${NC}` to reset color!**

---

## 🔒 Global Variables

Set automatically when sourcing `lib.sh`:

- `$OS` - Operating system (`Linux`, `macOS`, `unknown`)
- `$DISTRO` - Distribution (`arch`, `debian`, `fedora`, `homebrew`, `unknown`)
- `$DOTFILES_LIB_LOADED` - Guard flag (prevents double-sourcing)

---

## ✅ Best Practices

1. **Always source at the top of script** (after shebang and set -euo pipefail)
2. **Use `readonly` for important variables** (like `DOTFILES_DIR`)
3. **Prefer portable functions** over inline OS checks
4. **Use validation functions** to fail-fast on missing requirements
5. **Check command existence** before using external tools

---

## 📖 Full Documentation

See: `claudedocs/quality-perfection/phase2-migration/lib-creation-report.md`

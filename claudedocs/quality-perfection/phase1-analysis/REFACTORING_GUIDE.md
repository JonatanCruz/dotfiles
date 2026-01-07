# Shell Scripts Refactoring Guide

**Analysis Date:** 2026-01-06  
**Quality Score:** 8/10  
**Scripts Analyzed:** bootstrap.sh, health-check.sh, snapshot.sh, install.sh

---

## Executive Summary

The shell scripts in this dotfiles repository are **well-written** with strong adherence to bash best practices. However, there is **significant code duplication** (9.1% of codebase) that can be eliminated by creating a shared library.

### 🎯 Primary Goals

1. **Eliminate 150+ lines of duplicated code** by creating `scripts/lib.sh`
2. **Fix error handling** in `install.sh` (critical safety issue)
3. **Standardize patterns** across all scripts for maintainability

---

## 🔴 Critical Issues (Fix Immediately)

### 1. Code Duplication (142 lines duplicated)

**Problem:** Same code copied 4 times across scripts

- Color constants: 36 duplicated lines
- Print functions: 20+ duplicated lines
- OS detection: 60 duplicated lines
- Utility functions: 26+ duplicated lines

**Impact:**

- Hard to maintain (fix bugs in 4 places)
- Increases file sizes unnecessarily
- Violates DRY principle

**Solution:** Create `scripts/lib.sh` (see implementation below)

---

### 2. install.sh Error Handling

**Current:**

```bash
set -e  # Exit on error
```

**Problem:**

- ❌ Won't catch unset variables (`set -u` missing)
- ❌ Won't catch pipeline failures (`set -o pipefail` missing)
- ❌ Silent bugs possible

**Fix:**

```bash
set -euo pipefail
```

**Example of bug this prevents:**

```bash
# Without set -u, this silently uses empty string:
rm -rf "$TYPO_VARIABLE/important-files"  # Deletes current dir!

# Without set -o pipefail, exit code 0 even if grep fails:
cat file.txt | grep "pattern" | wc -l
```

---

## 📦 Phase 1: Create scripts/lib.sh

### Implementation

Create `scripts/lib.sh` with this structure:

```bash
#!/usr/bin/env bash
# ==============================================================================
# DOTFILES SHARED LIBRARY
# ==============================================================================
# Common functions and constants used across dotfiles scripts
# Source this file: source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
# ==============================================================================

# Prevent multiple sourcing
[[ -n "${DOTFILES_LIB_LOADED:-}" ]] && return 0
readonly DOTFILES_LIB_LOADED=1

# ==============================================================================
# COLOR CONSTANTS
# ==============================================================================

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# ==============================================================================
# PRINT FUNCTIONS
# ==============================================================================

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC}  $1"; }
print_info() { echo -e "${BLUE}ℹ${NC}  $1"; }
print_step() { echo -e "\n${BOLD}${BLUE}→${NC} ${BOLD}$1${NC}"; }

print_header() {
    local title="${1:-DOTFILES}"
    echo -e "\n${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
    printf "${CYAN}${BOLD}║${NC}  ${MAGENTA}${BOLD}%-60s${NC} ${CYAN}${BOLD}║${NC}\n" "$title"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}\n"
}

# ==============================================================================
# OS DETECTION
# ==============================================================================

# Global variables (set by detect_os)
OS=""
DISTRO=""

detect_os() {
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
            ;;
        Darwin*)
            OS="macOS"
            DISTRO="homebrew"
            ;;
        *)
            print_error "Unsupported OS: $(uname -s)"
            return 1
            ;;
    esac

    return 0
}

# ==============================================================================
# PATH FUNCTIONS
# ==============================================================================

get_dotfiles_dir() {
    # Get absolute path to dotfiles directory
    # Call from any script: DOTFILES_DIR="$(get_dotfiles_dir)"
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"

    # If called from scripts/ directory, go up one level
    if [[ "$(basename "$script_dir")" == "scripts" ]]; then
        cd "$script_dir/.." && pwd
    else
        echo "$script_dir"
    fi
}

# ==============================================================================
# PORTABLE UTILITIES
# ==============================================================================

portable_realpath() {
    # Cross-platform realpath (BSD macOS doesn't have readlink -f)
    local path="$1"

    if [[ "$OS" == "macOS" ]]; then
        if command -v python3 &>/dev/null; then
            python3 -c "import os; print(os.path.realpath('$path'))" 2>/dev/null
        else
            # Fallback: use pwd
            if [ -d "$path" ]; then
                (cd "$path" && pwd)
            else
                echo "$path"
            fi
        fi
    else
        readlink -f "$path"
    fi
}

portable_stat_time() {
    # Get file modification time in portable way
    local file="$1"

    if [[ "$OS" == "macOS" ]]; then
        # BSD stat
        stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file"
    else
        # GNU stat
        stat -c %y "$file" | cut -d'.' -f1
    fi
}

portable_get_version() {
    # Extract version number from command output
    local cmd="$1"

    case "$cmd" in
        stow)
            stow --version 2>&1 | head -n1 | sed -E 's/.*([0-9]+\.[0-9]+).*/\1/'
            ;;
        *)
            "$cmd" --version 2>&1 | head -n1
            ;;
    esac
}

# ==============================================================================
# INTERACTIVE FUNCTIONS
# ==============================================================================

# Set to false for non-interactive mode
INTERACTIVE=${INTERACTIVE:-true}

confirm() {
    # Interactive yes/no confirmation
    # Usage: if confirm "Delete files?"; then rm -rf ...; fi
    local message="$1"

    if [ "$INTERACTIVE" = false ]; then
        return 0
    fi

    read -p "$message (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# ==============================================================================
# VALIDATION FUNCTIONS
# ==============================================================================

validate_command() {
    # Check if command exists
    # Usage: validate_command git || { print_error "git not found"; exit 1; }
    local cmd="$1"
    command -v "$cmd" &>/dev/null
}

validate_in_dotfiles_repo() {
    # Verify we're running inside dotfiles repository
    local dotfiles_dir="${1:-$(pwd)}"

    if [ ! -d "$dotfiles_dir/.git" ]; then
        print_error "Not in dotfiles repository"
        print_info "Expected .git directory in: $dotfiles_dir"
        return 1
    fi

    return 0
}

validate_file() {
    # Check if file exists and is readable
    local file="$1"

    if [ ! -f "$file" ]; then
        print_error "File not found: $file"
        return 1
    fi

    if [ ! -r "$file" ]; then
        print_error "File not readable: $file"
        return 1
    fi

    return 0
}

# ==============================================================================
# INITIALIZATION
# ==============================================================================

# Auto-detect OS when library is sourced (unless already set)
if [ -z "$OS" ]; then
    detect_os
fi
```

---

## 🔧 Phase 2: Update Existing Scripts

### Pattern for All Scripts

Replace this pattern in **bootstrap.sh**, **health-check.sh**, **snapshot.sh**, **install.sh**:

**Before:**

```bash
#!/usr/bin/env bash

set -euo pipefail  # or set -e in install.sh

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
# ... etc (9 lines)

# Configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly DOTFILES_DIR

# Utility functions
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
# ... etc
```

**After:**

```bash
#!/usr/bin/env bash

set -euo pipefail

# ==============================================================================
# BOOTSTRAP SCRIPT (or HEALTH CHECK, etc.)
# ==============================================================================

# Source shared library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

# Script-specific configuration
readonly DOTFILES_DIR="$(get_dotfiles_dir)"

# Rest of script...
```

---

## 📝 Specific Changes Per Script

### install.sh Changes

**Line 10:** Change error handling

```bash
# Before:
set -e  # Exit on error

# After:
set -euo pipefail
```

**Line 23:** Make DOTFILES_DIR readonly

```bash
# Before:
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# After:
readonly DOTFILES_DIR="$(get_dotfiles_dir)"
```

**Delete lines 13-20:** Color constants (now in lib.sh)

**Delete lines 37-55:** All print\_\* functions (now in lib.sh)

**Delete lines 61-78:** detect_os() function (now in lib.sh)

---

### bootstrap.sh Changes

**After line 10:** Add lib.sh sourcing

```bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"
```

**Delete lines 12-20:** Color constants

**Delete lines 46-50:** Print functions (print_success, print_error, etc.)

**Delete lines 65-92:** detect_os() function

**Update line 52-59:** Use library's confirm() function

```bash
# Delete local confirm() function, use the one from lib.sh
```

---

### health-check.sh Changes

**After line 9:** Add lib.sh sourcing

```bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"
```

**Delete lines 12-18:** Color constants

**Delete lines 21-28:** detect_os() (already called by lib.sh)

**Delete lines 54-67:** Print functions

**Update lines 143-148:** Use portable_realpath()

```bash
# Before:
if [[ "$OS" == "macOS" ]]; then
    target=$(python3 -c "import os; print(os.path.realpath('$path'))" 2>/dev/null)
else
    target=$(readlink -f "$path" 2>/dev/null)
fi

# After:
target=$(portable_realpath "$path")
```

**Add usage() function:** (For consistency)

```bash
usage() {
    cat <<EOF
Usage: $(basename "$0")

Comprehensive health check for dotfiles installation.

Checks:
  - Required and optional binaries
  - Symlink integrity
  - Neovim, Zsh, and Tmux configurations
  - Git submodules

EOF
}
```

---

### snapshot.sh Changes

**After line 9:** Add lib.sh sourcing

**Delete lines 12-18:** Color constants

**Delete lines 21-28:** detect_os()

**Delete lines 56-60:** Print functions

**Update lines 168-174:** Use portable_stat_time()

```bash
# Before:
if [[ "$OS" == "Linux" ]]; then
    date=$(stat -c %y "$snapshot" | cut -d'.' -f1)
else
    date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$snapshot")
fi

# After:
date=$(portable_stat_time "$snapshot")
```

---

## 📊 Expected Results

### Metrics Improvement

| Metric                         | Before    | After    | Improvement        |
| ------------------------------ | --------- | -------- | ------------------ |
| Total lines                    | 1,556     | ~1,410   | -146 lines (-9.4%) |
| Duplicated code                | 142 lines | 0 lines  | -142 lines         |
| Functions                      | 42        | 30 + lib | Centralized        |
| Scripts with set -euo pipefail | 3/4       | 4/4      | +25% safer         |

### Maintainability Improvement

**Before:** Fix a print_error() bug → Edit 4 files  
**After:** Fix a print_error() bug → Edit 1 file (lib.sh)

**Before:** Add new color constant → Copy to 4 files  
**After:** Add new color constant → Edit lib.sh once

---

## ✅ Testing Checklist

After refactoring, test each script:

### bootstrap.sh

```bash
cd ~/dotfiles
./scripts/bootstrap.sh --help
./scripts/bootstrap.sh --no-deps --no-stow  # Dry run
```

### health-check.sh

```bash
cd ~/dotfiles
./scripts/health-check.sh
```

### snapshot.sh

```bash
cd ~/dotfiles
./scripts/snapshot.sh list
./scripts/snapshot.sh create test-refactor
```

### install.sh

```bash
cd ~/dotfiles
./install.sh  # Then quit (q)
```

### Validation Commands

```bash
# All scripts should source lib.sh successfully
for script in scripts/*.sh install.sh; do
    bash -n "$script" && echo "✓ $script syntax OK" || echo "✗ $script has errors"
done

# Test error handling
bash -c 'set -euo pipefail; undefined_var="$TYPO"' && echo "FAIL" || echo "PASS: unset var caught"
```

---

## 🚀 Implementation Order

1. **Create `scripts/lib.sh`** (copy from above)
2. **Test lib.sh independently:**
   ```bash
   source scripts/lib.sh
   print_success "Library loaded"
   detect_os
   echo "OS: $OS, DISTRO: $DISTRO"
   ```
3. **Refactor install.sh first** (smallest changes)
4. **Refactor snapshot.sh** (test snapshot features)
5. **Refactor health-check.sh** (add usage function)
6. **Refactor bootstrap.sh last** (most complex)
7. **Run full test suite** (all scripts)
8. **Create snapshot** before committing:
   ```bash
   ./scripts/snapshot.sh create "pre-lib-refactor"
   ```

---

## 🔍 Additional Improvements (Future)

### Low Priority Enhancements

1. **Add shellcheck integration:**

   ```bash
   shellcheck -x scripts/*.sh install.sh
   ```

2. **Add --dry-run mode to all scripts**

3. **Create scripts/config.sh for constants:**
   - Package lists
   - Snapshot targets
   - Default paths

4. **Add unit tests for lib.sh:**

   ```bash
   # scripts/test_lib.sh
   source scripts/lib.sh
   test_print_functions
   test_os_detection
   # etc.
   ```

5. **Add logging to file option:**
   ```bash
   LOG_FILE="${LOG_FILE:-/dev/null}"
   print_success() {
       echo -e "${GREEN}✓${NC} $1" | tee -a "$LOG_FILE"
   }
   ```

---

## 📚 References

- [Bash Best Practices](https://google.github.io/styleguide/shellguide.html)
- [ShellCheck](https://www.shellcheck.net/)
- [Bash Strict Mode](http://redsymbol.net/articles/unofficial-bash-strict-mode/)

---

**Next Steps:** See `Scripts_Refactor_Plan.json` for detailed issue list with line numbers.

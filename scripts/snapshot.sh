#!/usr/bin/env bash

# ==============================================================================
# DOTFILES SNAPSHOT & ROLLBACK SCRIPT
# ==============================================================================
# Create backups and restore configurations from snapshots
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
readonly SNAPSHOT_DIR="$HOME/.dotfiles-snapshots"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
readonly TIMESTAMP

# Directories to snapshot
readonly SNAPSHOT_TARGETS=(
    "$HOME/.config/nvim"
    "$HOME/.config/tmux"
    "$HOME/.config/zsh"
    "$HOME/.config/yazi"
    "$HOME/.config/wezterm"
    "$HOME/.zsh"
    "$HOME/.tmux"
)

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

print_header() {
    echo -e "\n${CYAN}${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║${NC}  ${BLUE}${BOLD}DOTFILES SNAPSHOT${NC}                                          ${CYAN}${BOLD}║${NC}"
    echo -e "${CYAN}${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}\n"
}

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC}  $1"; }
print_info() { echo -e "${BLUE}ℹ${NC}  $1"; }
print_step() { echo -e "\n${BOLD}${BLUE}→${NC} ${BOLD}$1${NC}"; }

# ==============================================================================
# SNAPSHOT CREATION
# ==============================================================================

create_snapshot() {
    local label="${1:-manual}"
    local snapshot_name="dotfiles_${label}_${TIMESTAMP}.tar.gz"
    local snapshot_path="$SNAPSHOT_DIR/$snapshot_name"

    print_header
    print_step "Creating snapshot: $label"

    # Create snapshot directory
    mkdir -p "$SNAPSHOT_DIR"

    # Create temporary directory for staging
    local temp_dir
    temp_dir=$(mktemp -d)
    local staging_dir
    staging_dir="$temp_dir/dotfiles-snapshot"
    mkdir -p "$staging_dir"

    # Copy configurations
    local copied=0
    local skipped=0

    for target in "${SNAPSHOT_TARGETS[@]}"; do
        if [ -e "$target" ]; then
            local basename
            basename=$(basename "$target")
            local parent_dir
            parent_dir=$(dirname "$target" | sed "s|$HOME/||")

            # Preserve directory structure
            mkdir -p "$staging_dir/$parent_dir"
            cp -rL "$target" "$staging_dir/$parent_dir/" 2>/dev/null || {
                print_warning "Could not copy $basename (may be broken symlink)"
                skipped=$((skipped + 1))
                continue
            }
            print_success "Captured: $basename"
            copied=$((copied + 1))
        else
            skipped=$((skipped + 1))
        fi
    done

    # Create snapshot metadata
    cat > "$staging_dir/snapshot-info.txt" <<EOF
Dotfiles Snapshot
=================
Label: $label
Created: $(date)
Hostname: $(hostname)
User: $(whoami)
OS: $(uname -s)

Contents:
$(find "$staging_dir" -type f -o -type d | sed "s|$staging_dir/||" | grep -v "snapshot-info.txt" | sort)
EOF

    # Create tarball
    print_step "Creating archive..."
    tar -czf "$snapshot_path" -C "$temp_dir" dotfiles-snapshot 2>/dev/null

    # Cleanup
    rm -rf "$temp_dir"

    # Report
    local size
    size=$(du -h "$snapshot_path" | cut -f1)

    echo ""
    print_success "Snapshot created successfully"
    print_info "Location: $snapshot_path"
    print_info "Size: $size"
    print_info "Captured: $copied items ($skipped skipped)"
    echo ""
}

# ==============================================================================
# SNAPSHOT LISTING
# ==============================================================================

list_snapshots() {
    print_header
    print_step "Available snapshots"

    if [ ! -d "$SNAPSHOT_DIR" ] || [ -z "$(ls -A "$SNAPSHOT_DIR" 2>/dev/null)" ]; then
        print_warning "No snapshots found"
        echo ""
        return
    fi

    echo ""
    printf "%-5s %-40s %-10s %-20s\n" "No." "Snapshot" "Size" "Created"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local index=1
    for snapshot in "$SNAPSHOT_DIR"/*.tar.gz; do
        if [ -f "$snapshot" ]; then
            local name
            name=$(basename "$snapshot")
            local size
            size=$(du -h "$snapshot" | cut -f1)
            local date
            date=$(stat -c %y "$snapshot" 2>/dev/null | cut -d'.' -f1 || stat -f "%Sm" "$snapshot")

            printf "%-5s %-40s %-10s %-20s\n" "$index" "$name" "$size" "$date"
            ((index++))
        fi
    done

    echo ""
}

# ==============================================================================
# SNAPSHOT ROLLBACK
# ==============================================================================

rollback_snapshot() {
    local snapshot_file="$1"

    print_header
    print_step "Rolling back from snapshot"

    # Validate snapshot file
    if [ ! -f "$snapshot_file" ]; then
        # Try to find it in snapshot directory
        if [ -f "$SNAPSHOT_DIR/$snapshot_file" ]; then
            snapshot_file="$SNAPSHOT_DIR/$snapshot_file"
        else
            print_error "Snapshot not found: $snapshot_file"
            exit 1
        fi
    fi

    print_info "Snapshot: $(basename "$snapshot_file")"
    echo ""

    # Warning
    print_warning "This will replace current configurations!"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Rollback cancelled"
        exit 0
    fi

    # Create backup of current state before rollback
    print_step "Creating pre-rollback backup..."
    create_snapshot "pre-rollback" >/dev/null 2>&1

    # Extract snapshot to temporary location
    local temp_dir
    temp_dir=$(mktemp -d)

    print_step "Extracting snapshot..."
    tar -xzf "$snapshot_file" -C "$temp_dir"

    local extracted_dir="$temp_dir/dotfiles-snapshot"

    if [ ! -d "$extracted_dir" ]; then
        print_error "Invalid snapshot format"
        rm -rf "$temp_dir"
        exit 1
    fi

    # Restore configurations
    print_step "Restoring configurations..."

    local restored=0
    local failed=0

    # Remove current symlinks
    for target in "${SNAPSHOT_TARGETS[@]}"; do
        if [ -L "$target" ]; then
            rm "$target"
        fi
    done

    # Copy from snapshot
    for item in "$extracted_dir"/.config/* "$extracted_dir"/.zsh "$extracted_dir"/.tmux; do
        if [ -e "$item" ]; then
            local basename
            basename=$(basename "$item")
            local target_path

            if [[ "$item" == *".config/"* ]]; then
                target_path="$HOME/.config/$basename"
            else
                target_path="$HOME/$basename"
            fi

            if cp -r "$item" "$target_path" 2>/dev/null; then
                print_success "Restored: $basename"
                ((restored++))
            else
                print_error "Failed to restore: $basename"
                ((failed++))
            fi
        fi
    done

    # Cleanup
    rm -rf "$temp_dir"

    echo ""
    print_success "Rollback completed"
    print_info "Restored: $restored items ($failed failed)"
    echo ""
}

# ==============================================================================
# USAGE
# ==============================================================================

usage() {
    cat <<EOF
Usage: $(basename "$0") [COMMAND] [OPTIONS]

Create and manage dotfiles snapshots.

COMMANDS:
    create [LABEL]          Create snapshot with optional label
    list                    List all available snapshots
    rollback <SNAPSHOT>     Restore from snapshot
    help                    Show this help message

EXAMPLES:
    $(basename "$0") create "pre-update"       # Create labeled snapshot
    $(basename "$0") create                    # Create snapshot with 'manual' label
    $(basename "$0") list                      # List all snapshots
    $(basename "$0") rollback snapshot.tar.gz  # Restore from specific snapshot

SNAPSHOT LOCATION:
    $SNAPSHOT_DIR

EOF
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
    local command="${1:-create}"

    case "$command" in
        create)
            create_snapshot "${2:-manual}"
            ;;
        list|ls)
            list_snapshots
            ;;
        rollback|restore)
            if [ -z "${2:-}" ]; then
                print_error "Snapshot file required"
                usage
                exit 1
            fi
            rollback_snapshot "$2"
            ;;
        help|-h|--help)
            usage
            ;;
        *)
            # Default: treat as label for create
            create_snapshot "$1"
            ;;
    esac
}

main "$@"

#!/usr/bin/env bash

# ==============================================================================
# UPDATE ZSH PLUGINS
# ==============================================================================
# Updates all zsh-plugin git submodules to their latest commits and creates
# a commit pinning the new SHAs. Lock-by-SHA is our package manager.
#
# Usage: ./scripts/update-plugins.sh [--no-commit]
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./lib.sh
source "${SCRIPT_DIR}/lib.sh"

REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
NO_COMMIT=0
[[ "${1:-}" == "--no-commit" ]] && NO_COMMIT=1

print_header "Updating zsh plugin submodules"
cd "${REPO_ROOT}"

# Capture current SHAs for change detection
before="$(git submodule status zsh-plugins/ 2>/dev/null | awk '{print $1, $2}')"

print_step "git submodule update --remote --merge zsh-plugins/"
git submodule update --remote --merge zsh-plugins/

after="$(git submodule status zsh-plugins/ 2>/dev/null | awk '{print $1, $2}')"

if [[ "${before}" == "${after}" ]]; then
    print_info "All plugins already at latest. Nothing to do."
    exit 0
fi

print_success "Updated plugins:"
diff <(echo "${before}") <(echo "${after}") | grep -E '^[<>]' || true

if [[ "${NO_COMMIT}" -eq 1 ]]; then
    print_warning "--no-commit set; skipping commit."
    exit 0
fi

print_step "Staging and committing"
git add zsh-plugins/
git commit -m "chore(zsh): bump plugin submodules to latest"
print_success "Done. Push with: git push"

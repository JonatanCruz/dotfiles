# ==============================================================================
# DOTFILES TASK RUNNER
# ==============================================================================
# Single entry point for all maintenance tasks. Run `just` to list.
# Requires: just (brew install just), hyperfine (brew install hyperfine)
# ==============================================================================

# Default recipe: list all available tasks
default:
    @just --list --unsorted

# ---------- Setup & install ----------

# Bootstrap dotfiles on a fresh machine (macOS / Debian / Arch)
bootstrap:
    ./scripts/bootstrap.sh

# Quick setup for Ubuntu (assumes brew + stow already installed)
setup-ubuntu:
    ./scripts/quick-setup-ubuntu.sh

# Verify dotfiles installation and dependencies
health:
    ./scripts/health-check.sh

# ---------- Plugins & dependencies ----------

# Update all zsh plugin submodules and commit
update-plugins:
    ./scripts/update-plugins.sh

# Update plugins without auto-committing (review first)
update-plugins-dry:
    ./scripts/update-plugins.sh --no-commit

# ---------- Backup & rollback ----------

# Create a timestamped snapshot of current configs
snapshot:
    ./scripts/snapshot.sh

# ---------- Benchmarks & diagnostics ----------

# Benchmark zsh interactive startup (10 runs)
bench-zsh:
    hyperfine --warmup 3 --runs 10 'zsh -i -c exit'

# Benchmark nvim startup (cold + warm)
bench-nvim:
    hyperfine --warmup 1 --runs 5 'nvim --headless +qa'

# Compare ripgrep vs grep on this repo
bench-search pattern="TODO":
    hyperfine --warmup 2 'rg "{{pattern}}" .' 'grep -r "{{pattern}}" .'

# ---------- Git ----------

# Show repo status summary (branch, ahead/behind, dirty)
status:
    @git status -sb
    @echo ""
    @git log --oneline -5

# ---------- Stow ----------

# Dry-run stow for all packages (safe diagnostic)
stow-check:
    @for pkg in nvim zsh tmux starship yazi docker git wezterm opencode zsh-plugins claude; do \
        if [ -d "$pkg" ]; then \
            echo "=== $pkg ==="; \
            stow -n -v "$pkg" 2>&1 | grep -v "WARNING: in simulation mode" || true; \
        fi; \
    done

# Apply all stow packages (use with care — overwrites symlinks)
stow-all:
    stow nvim zsh tmux starship yazi docker git wezterm opencode zsh-plugins claude

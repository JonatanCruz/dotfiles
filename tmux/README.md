# Tmux Configuration

> Terminal multiplexer with Catppuccin Mocha, SessionX, and Vim navigation

## Quick Reference

- **Config File**: `~/.tmux.conf`
- **Documentation**: [docs/services/tmux.md](../docs/services/tmux.md)
- **Prefix Key**: `Ctrl+s` (not `Ctrl+b`)
- **Key Features**: SessionX manager, Resurrect/Continuum persistence, Vim-tmux-navigator
- **Plugins**: TPM, Thumbs, FZF, Catppuccin theme

## Quick Start

```bash
# Install TPM (Tmux Plugin Manager)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Apply config
cd ~/dotfiles && stow tmux

# Start tmux and install plugins
tmux
# Press: Ctrl+s then Shift+I
```

For complete documentation, see [docs/services/tmux.md](../docs/services/tmux.md)

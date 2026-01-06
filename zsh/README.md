# Zsh Configuration

> Modular Zsh with Vi mode, modern tools, and organized aliases

## Quick Reference

- **Config Path**: `~/.config/zsh/`
- **Documentation**: [docs/services/zsh.md](../docs/services/zsh.md)
- **Key Features**: Modular structure, Vi mode, autosuggestions, syntax highlighting
- **Modern Tools**: eza, bat, fd, ripgrep, zoxide, fzf, Starship prompt
- **Aliases**: Organized by category (git, docker, gh, gcloud, tmux, navigation, tools)

## Quick Start

```bash
# Apply config
cd ~/dotfiles && stow zsh

# Change default shell
chsh -s $(which zsh)

# Install tools
brew install eza bat fd ripgrep fzf zoxide starship
# or: sudo apt install eza bat fd-find ripgrep fzf
```

For complete documentation, see [docs/services/zsh.md](../docs/services/zsh.md)

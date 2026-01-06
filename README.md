# 💻 Dotfiles - Professional Development Environment

[![CI/CD](https://github.com/JonatanCruz/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/JonatanCruz/dotfiles/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey.svg)](https://github.com/JonatanCruz/dotfiles)
[![GNU Stow](https://img.shields.io/badge/managed_by-GNU_Stow-orange.svg)](https://www.gnu.org/software/stow/)

> Modern, keyboard-driven development environment with unified Catppuccin Mocha theming and transparent backgrounds. Optimized for Linux and macOS.

![Catppuccin Mocha Theme](https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/mocha.png)

## ✨ Features

- 🎨 **Unified Theme**: Catppuccin Mocha across all tools
- ⌨️ **Vim-Style Navigation**: Keyboard-first workflow
- 🔄 **GNU Stow Management**: Modular, version-controlled configuration
- 🚀 **Modern CLI Tools**: Fast alternatives to traditional Unix tools
- 🤖 **AI Integration**: Claude Code configuration included
- 🔧 **Automated Setup**: Interactive installer with conflict detection
- ✅ **CI/CD Pipeline**: Automated testing and validation via GitHub Actions

## 🛠️ Stack

| Category | Tools |
|----------|-------|
| **Core** | [GNU Stow](https://www.gnu.org/software/stow/), [Neovim](https://neovim.io/), [Tmux](https://github.com/tmux/tmux), [Zsh](https://www.zsh.org/) |
| **Modern CLI** | [eza](https://github.com/eza-community/eza), [bat](https://github.com/sharkdp/bat), [fd](https://github.com/sharkdp/fd), [ripgrep](https://github.com/BurntSushi/ripgrep), [zoxide](https://github.com/ajeetdsouza/zoxide) |
| **Terminal** | [WezTerm](https://wezfurlong.org/wezterm/) (macOS), [Starship](https://starship.rs/) prompt |
| **Git Tools** | [LazyGit](https://github.com/jesseduffield/lazygit), [Delta](https://github.com/dandavison/delta), [GitHub CLI](https://cli.github.com/) |
| **File Explorer** | [Yazi](https://github.com/sxyazi/yazi), NvimTree |
| **AI Assistant** | [Claude Code](https://claude.com/claude-code) |
| **DevOps** | [direnv](https://direnv.net/), [btop](https://github.com/aristocratos/btop), [tldr](https://github.com/tldr-pages/tldr) |

## 🚀 Quick Start

### Automated Installation (Recommended)

```bash
# Clone repository with submodules
git clone --recurse-submodules https://github.com/JonatanCruz/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run interactive installer
./install.sh
```

The installer will:
- ✓ Detect OS (Linux/macOS)
- ✓ Verify dependencies
- ✓ Let you select packages
- ✓ Detect conflicts
- ✓ Create backups
- ✓ Apply configurations

### Manual Installation

<details>
<summary><b>Click to expand manual installation steps</b></summary>

**1. Prerequisites**

```bash
# Linux (Ubuntu/Debian)
sudo apt install stow git

# macOS
brew install stow git
```

**2. Clone and Setup**

```bash
git clone --recurse-submodules https://github.com/JonatanCruz/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

**3. Install Dependencies**

For detailed dependency installation, see [docs/INSTALL.md](docs/INSTALL.md)

**4. Apply Configurations**

```bash
# Apply all configurations
stow */

# Or selectively:
stow nvim zsh tmux starship
```

**5. Set Zsh as Default Shell**

```bash
chsh -s $(which zsh)
```

</details>

## 📂 Repository Structure

```
dotfiles/
├── .github/workflows/      # CI/CD automation
│   └── ci.yml             # Linting, testing, security scans
├── scripts/               # Utility scripts
│   ├── bootstrap.sh      # Fresh system setup
│   ├── health-check.sh   # Environment validation
│   └── snapshot.sh       # Configuration backup
├── nvim/                  # Neovim configuration
│   └── .config/nvim/     # Modular Lua config with lazy.nvim
├── claude/                # Claude Code global config
│   └── .claude/          # SuperClaude framework
├── tmux/                  # Tmux multiplexer
├── zsh/                   # Zsh shell config
├── zsh-plugins/           # Zsh plugins (submodules)
├── starship/              # Starship prompt
├── yazi/                  # Yazi file manager
├── wezterm/               # WezTerm (macOS)
├── docker/                # Docker completion
└── git/                   # Git configuration
```

## 🔧 Utility Scripts

| Script | Description | Usage |
|--------|-------------|-------|
| `bootstrap.sh` | Fresh system setup | `./scripts/bootstrap.sh` |
| `health-check.sh` | Validate environment | `./scripts/health-check.sh` |
| `snapshot.sh` | Backup configurations | `./scripts/snapshot.sh create backup-name` |

## ⚙️ Key Technologies

### Neovim Configuration

- **Plugin Manager**: [lazy.nvim](https://github.com/folke/lazy.nvim) (lazy loading)
- **LSP**: Mason for automatic server installation
- **Completion**: nvim-cmp with intelligent snippets
- **Fuzzy Finder**: Telescope
- **Git Integration**: LazyGit, Gitsigns
- **Theme**: Catppuccin with transparency

**Structure**: Modular Lua configuration in `lua/config/` and `lua/plugins/`

### GNU Stow Management

Stow creates symlinks from repository to home directory:

```bash
stow nvim      # Link ~/.config/nvim → ~/dotfiles/nvim/.config/nvim
stow -R nvim   # Restow (update links)
stow -D nvim   # Unlink configuration
stow -n nvim   # Dry-run (preview changes)
```

### CI/CD Pipeline

GitHub Actions workflow validates:
- ✓ ShellCheck linting (Bash scripts)
- ✓ Luacheck linting (Neovim configs)
- ✓ Stow dry-run tests (all packages)
- ✓ Neovim config validation
- ✓ Security scanning (TruffleHog)
- ✓ Health check execution
- ✓ Bootstrap script testing

## 🎨 Theming

**Catppuccin Mocha** unified across:
- Neovim (`mocha` flavor with transparency)
- Tmux (`catppuccin/tmux` plugin)
- WezTerm (60% transparency with blur)
- Git Delta (Mocha syntax highlighting)
- Starship (Mocha color palette)

**Color Palette**: [View Catppuccin Mocha](https://github.com/catppuccin/catppuccin#-palette)

## ⌨️ Essential Keybindings

<details>
<summary><b>Tmux (Prefix: Ctrl+a)</b></summary>

| Key | Action |
|-----|--------|
| `Prefix + \|` | Horizontal split |
| `Prefix + -` | Vertical split |
| `Prefix + h/j/k/l` | Navigate panes |
| `Prefix + H/J/K/L` | Resize panes |
| `Prefix + r` | Reload config |

</details>

<details>
<summary><b>Neovim (Leader: Space)</b></summary>

| Key | Action |
|-----|--------|
| `<leader>w` | Save file |
| `<leader>q` | Quit |
| `<leader>e` | File explorer |
| `<leader>ff` | Find files |
| `<leader>fg` | Search text |
| `<leader>gg` | LazyGit |
| `gd` | Go to definition |
| `gr` | References |
| `K` | Hover docs |

</details>

<details>
<summary><b>Yazi (Vim-style)</b></summary>

| Key | Action |
|-----|--------|
| `h/j/k/l` | Navigate |
| `Enter` | Open file |
| `Esc` or `q` | Exit |

</details>

## 🔄 Updates

```bash
cd ~/dotfiles
git pull --recurse-submodules
stow -R */  # Restow all packages
```

## 📚 Documentation

- [Installation Guide](docs/INSTALL.md) - Detailed setup instructions
- [Neovim Configuration](nvim/.config/nvim/README.md) - Editor customization
- [Tmux Guide](docs/TMUX.md) - Multiplexer usage
- [Scripts Reference](scripts/README.md) - Utility script documentation

## 🐛 Troubleshooting

### Stow Conflicts

```bash
# Backup existing config
mv ~/.config/nvim ~/.config/nvim.backup

# Apply dotfiles
stow nvim
```

### Neovim Plugins Not Loading

```bash
# Open Neovim and sync plugins
nvim
:Lazy sync
```

### Zsh Not Default Shell

```bash
chsh -s $(which zsh)
# Logout and login again
```

## 🤝 Contributing

Issues and pull requests are welcome. For major changes, please open an issue first.

## 📜 License

MIT License - See [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

- [Catppuccin](https://github.com/catppuccin/catppuccin) - Soothing pastel theme
- [GNU Stow](https://www.gnu.org/software/stow/) - Symlink management
- [Dotfiles Community](https://dotfiles.github.io/) - Best practices and inspiration

---

<div align="center">

**[⬆ Back to Top](#-dotfiles---professional-development-environment)**

Made with ❤️ by [JonatanCruz](https://github.com/JonatanCruz)

</div>

<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:1e1e2e,50:313244,100:45475a&height=220&section=header&text=.dotfiles&fontSize=72&fontColor=cdd6f4&fontAlignY=35&desc=modern%20development%20environment&descSize=18&descColor=89b4fa&descAlignY=55&animation=fadeIn" width="100%"/>

<br/>

[![CI/CD](https://img.shields.io/github/actions/workflow/status/JonatanCruz/dotfiles/ci.yml?branch=main&style=for-the-badge&logo=githubactions&logoColor=a6e3a1&label=CI&color=1e1e2e)](https://github.com/JonatanCruz/dotfiles/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-MIT-89b4fa?style=for-the-badge&logo=opensourceinitiative&logoColor=89b4fa&color=1e1e2e)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-linux%20%7C%20macos-cba6f7?style=for-the-badge&logo=apple&logoColor=cba6f7&color=1e1e2e)](https://github.com/JonatanCruz/dotfiles)
[![Stow](https://img.shields.io/badge/managed%20by-GNU%20Stow-fab387?style=for-the-badge&logo=gnu&logoColor=fab387&color=1e1e2e)](https://www.gnu.org/software/stow/)
[![Theme](https://img.shields.io/badge/theme-catppuccin%20mocha-f5c2e7?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0Ij48Y2lyY2xlIGN4PSIxMiIgY3k9IjEyIiByPSIxMCIgZmlsbD0iI2Y1YzJlNyIvPjwvc3ZnPg==&color=1e1e2e)](https://github.com/catppuccin/catppuccin)

<br/>

> Keyboard-driven development environment with unified theming and transparent backgrounds.
> <br/>Optimized for Linux and macOS.

<br/>

<img src="https://skillicons.dev/icons?i=neovim,lua,bash,git,github,docker,linux,apple&theme=dark" alt="Tech Stack" />

<br/><br/>

</div>

---

## Quick Start

```bash
# Clone and install
git clone --recurse-submodules https://github.com/JonatanCruz/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh
```

The installer detects your OS, verifies dependencies, handles conflicts with backups, and applies configurations.

<details>
<summary><strong>Ubuntu 24.04 — One-command setup</strong></summary>

```bash
cd ~/dotfiles && ./scripts/bootstrap.sh -y
```

Installs everything (Neovim, Tmux, Zsh, Starship, CLI tools, fonts) automatically.

See the full [Ubuntu Setup Guide](docs/QUICK_SETUP_UBUNTU.md) for step-by-step or Homebrew options.

</details>

<details>
<summary><strong>Manual / Selective install</strong></summary>

```bash
# Prerequisites
sudo apt install stow git   # Linux
brew install stow git        # macOS

# Apply specific configs
stow nvim zsh tmux starship

# Set Zsh as default shell
chsh -s $(which zsh)
```

</details>

---

## Stack

<table>
<tr>
<td width="140"><strong>Core</strong></td>
<td>

[Neovim](https://neovim.io/) · [Tmux](https://github.com/tmux/tmux) · [Zsh](https://www.zsh.org/) · [GNU Stow](https://www.gnu.org/software/stow/) · [Starship](https://starship.rs/)

</td>
</tr>
<tr>
<td><strong>Modern CLI</strong></td>
<td>

[eza](https://github.com/eza-community/eza) · [bat](https://github.com/sharkdp/bat) · [fd](https://github.com/sharkdp/fd) · [ripgrep](https://github.com/BurntSushi/ripgrep) · [fzf](https://github.com/junegunn/fzf) · [zoxide](https://github.com/ajeetdsouza/zoxide)

</td>
</tr>
<tr>
<td><strong>Git Tools</strong></td>
<td>

[LazyGit](https://github.com/jesseduffield/lazygit) · [Delta](https://github.com/dandavison/delta) · [Diffview](https://github.com/sindrets/diffview.nvim) · [GitHub CLI](https://cli.github.com/)

</td>
</tr>
<tr>
<td><strong>Dev Tools</strong></td>
<td>

[Yazi](https://github.com/sxyazi/yazi) · [btop](https://github.com/aristocratos/btop) · [direnv](https://direnv.net/) · [Claude Code](https://claude.com/claude-code)

</td>
</tr>
</table>

---

## Repository Structure

```
dotfiles/
├── nvim/              Neovim — modular Lua config with lazy.nvim, LSP, DAP, Neotest
├── zsh/               Zsh — 10 alias categories, lazy-loading, vi mode
├── tmux/              Tmux — SessionX, Resurrect, vim-tmux-navigator
├── starship/          Starship — Catppuccin Mocha prompt
├── yazi/              Yazi — terminal file manager
├── git/               Git — Delta diff, rerere, aliases
├── claude/            Claude Code — SuperClaude framework
├── wezterm/           WezTerm — GPU-accelerated terminal (macOS)
├── docker/            Docker — completion scripts
├── zsh-plugins/       Zsh plugins (git submodules)
├── scripts/           bootstrap, health-check, snapshot
└── docs/              Full documentation
```

---

## Keybindings

<details>
<summary><strong>Tmux</strong> — Prefix: <code>Ctrl+s</code></summary>

| Key | Action |
|-----|--------|
| `Prefix + v` | Split horizontal (top/bottom) |
| `Prefix + h` | Split vertical (left/right) |
| `Ctrl+h/j/k/l` | Navigate panes (no prefix) |
| `Alt+h/j/k/l` | Resize panes (vim-aware) |
| `Prefix + m` | Zoom pane toggle |
| `Prefix + s` | Session manager (SessionX) |
| `Prefix + r` | Reload config |

</details>

<details>
<summary><strong>Neovim</strong> — Leader: <code>Space</code></summary>

| Key | Action |
|-----|--------|
| `<leader>w` | Save |
| `<leader>q` | Quit |
| `<leader>e` | File explorer |
| `<leader>ff` | Find files |
| `<leader>fg` | Search text |
| `<leader>gg` | LazyGit |
| `gd` / `gr` / `K` | Go to definition / References / Hover |
| `<leader>db` | Toggle breakpoint (DAP) |
| `<leader>dc` | Start/Continue debug |
| `<leader>tt` | Run nearest test (Neotest) |
| `<leader>re` | Extract function (Refactoring) |
| `<leader>gd` | Open Diffview |

</details>

---

## Theming

**Catppuccin Mocha** — unified across every tool:

<table>
<tr>
<td align="center"><img src="https://img.shields.io/badge/-%20-89b4fa?style=flat-square&logoColor=white" width="24"/> Blue</td>
<td align="center"><img src="https://img.shields.io/badge/-%20-cba6f7?style=flat-square&logoColor=white" width="24"/> Mauve</td>
<td align="center"><img src="https://img.shields.io/badge/-%20-f5c2e7?style=flat-square&logoColor=white" width="24"/> Pink</td>
<td align="center"><img src="https://img.shields.io/badge/-%20-a6e3a1?style=flat-square&logoColor=white" width="24"/> Green</td>
<td align="center"><img src="https://img.shields.io/badge/-%20-f9e2af?style=flat-square&logoColor=white" width="24"/> Yellow</td>
<td align="center"><img src="https://img.shields.io/badge/-%20-fab387?style=flat-square&logoColor=white" width="24"/> Peach</td>
<td align="center"><img src="https://img.shields.io/badge/-%20-f38ba8?style=flat-square&logoColor=white" width="24"/> Red</td>
<td align="center"><img src="https://img.shields.io/badge/-%20-94e2d5?style=flat-square&logoColor=white" width="24"/> Teal</td>
</tr>
</table>

Applied to: Neovim · Tmux · Starship · WezTerm · Git Delta · Yazi

---

## CI/CD

GitHub Actions validates on every push:

![ShellCheck](https://img.shields.io/badge/shellcheck-passing-a6e3a1?style=flat-square&logo=gnu-bash&logoColor=a6e3a1&color=1e1e2e)
![Luacheck](https://img.shields.io/badge/luacheck-passing-89b4fa?style=flat-square&logo=lua&logoColor=89b4fa&color=1e1e2e)
![Stow](https://img.shields.io/badge/stow%20dry--run-passing-cba6f7?style=flat-square&logo=gnu&logoColor=cba6f7&color=1e1e2e)
![Security](https://img.shields.io/badge/trufflehog-clean-f9e2af?style=flat-square&logo=trufflehog&logoColor=f9e2af&color=1e1e2e)

ShellCheck · Luacheck · Stow dry-run · Neovim config validation · TruffleHog security scan · Health check · Bootstrap test

---

## Documentation

<table>
<tr>
<td width="50%">

**Getting Started**
- [Ubuntu Quick Setup](docs/QUICK_SETUP_UBUNTU.md)
- [Installation Guide](docs/INSTALL.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Installation Checklist](docs/CHECKLIST_INSTALACION.md)

</td>
<td>

**Reference**
- [All Aliases](docs/reference/aliases.md)
- [Keybindings](docs/guides/keybindings.md)
- [Scripts](docs/reference/scripts.md)
- [Troubleshooting](docs/reference/troubleshooting.md)

</td>
</tr>
<tr>
<td>

**Services**
- [Neovim](docs/services/nvim.md) · [Tmux](docs/services/tmux.md) · [Zsh](docs/services/zsh.md)
- [Starship](docs/services/starship.md) · [Yazi](docs/services/yazi.md) · [Git](docs/services/git.md)
- [Claude Code](docs/services/claude.md) · [WezTerm](docs/services/wezterm.md)

</td>
<td>

**Advanced**
- [Neovim Plugins](docs/advanced/neovim-plugins.md)
- [Tmux Workflows](docs/advanced/tmux-workflows.md)
- [Tool Integration](docs/advanced/integration.md)
- [Customization](docs/guides/customization.md)

</td>
</tr>
</table>

Full documentation: **[docs/](docs/README.md)**

---

## Troubleshooting

```bash
# Stow conflicts — backup and retry
mv ~/.config/nvim ~/.config/nvim.backup && stow nvim

# Neovim plugins not loading
nvim -c "Lazy sync"

# Zsh not default shell
chsh -s $(which zsh)  # then logout/login

# Full environment health check
./scripts/health-check.sh
```

---

<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:1e1e2e,50:313244,100:45475a&height=120&section=footer&animation=fadeIn" width="100%"/>

<sub>

MIT License · Made by [JonatanCruz](https://github.com/JonatanCruz)

[Catppuccin](https://github.com/catppuccin/catppuccin) · [GNU Stow](https://www.gnu.org/software/stow/) · [Dotfiles Community](https://dotfiles.github.io/)

</sub>

</div>

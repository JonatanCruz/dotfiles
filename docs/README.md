<div align="center">

<img src="https://capsule-render.vercel.app/api?type=rect&color=1e1e2e&height=1" width="100%"/>

# Documentation

<sub>Complete reference for the dotfiles development environment</sub>

<br/>

[![Neovim](https://img.shields.io/badge/neovim-docs-89b4fa?style=flat-square&logo=neovim&logoColor=89b4fa&color=1e1e2e)](services/nvim.md)
[![Tmux](https://img.shields.io/badge/tmux-docs-a6e3a1?style=flat-square&logo=tmux&logoColor=a6e3a1&color=1e1e2e)](services/tmux.md)
[![Zsh](https://img.shields.io/badge/zsh-docs-cba6f7?style=flat-square&logo=zsh&logoColor=cba6f7&color=1e1e2e)](services/zsh.md)
[![Git](https://img.shields.io/badge/git-docs-fab387?style=flat-square&logo=git&logoColor=fab387&color=1e1e2e)](services/git.md)

<br/>

</div>

---

## Getting Started

If you're new, follow this path:

| Step | Resource | Description |
|:----:|----------|-------------|
| 1 | **[Quick Setup Ubuntu](QUICK_SETUP_UBUNTU.md)** | Automated install in 5-10 min (includes Homebrew option) |
| 2 | **[Installation Checklist](CHECKLIST_INSTALACION.md)** | Verify everything is working |
| 3 | **[Architecture](ARCHITECTURE.md)** | Understand how GNU Stow manages configs |
| 4 | **[Keybindings](guides/keybindings.md)** | Learn the key shortcuts |

For other platforms, start with the [Complete Installation Guide](INSTALL.md).

---

## Services

Detailed documentation for each configured tool:

<table>
<tr>
<td width="50%">

| Service | Description |
|---------|-------------|
| **[Neovim](services/nvim.md)** | Editor with LSP, DAP debugging, Neotest, AI completion |
| **[Tmux](services/tmux.md)** | Multiplexer with SessionX, Resurrect, vim-tmux nav |
| **[Zsh](services/zsh.md)** | Shell with 10 alias categories, lazy-loading, vi mode |
| **[Starship](services/starship.md)** | Prompt with Catppuccin Mocha colors |

</td>
<td>

| Service | Description |
|---------|-------------|
| **[Yazi](services/yazi.md)** | Terminal file manager with vim navigation |
| **[Git](services/git.md)** | Delta diff viewer, rerere, aliases |
| **[Docker](services/docker.md)** | Completions and container aliases |
| **[Claude Code](services/claude.md)** | SuperClaude framework, MCP servers |

</td>
</tr>
</table>

Additional: [WezTerm](services/wezterm.md) (macOS) · [OpenCode](guides/opencode.md) · [OpenCode Best Practices](guides/opencode-best-practices.md)

---

## Guides

| Guide | What you'll learn |
|-------|-------------------|
| **[Getting Started](guides/getting-started.md)** | First steps after installation |
| **[Keybindings](guides/keybindings.md)** | Complete shortcut reference |
| **[Workflows](guides/workflows.md)** | Common development workflows |
| **[Customization](guides/customization.md)** | How to adapt configs to your needs |

---

## Reference

| Resource | Content |
|----------|---------|
| **[Aliases](reference/aliases.md)** | All aliases: Git, Docker, Node.js, Tmux, GCloud, and more |
| **[Scripts](reference/scripts.md)** | bootstrap, health-check, snapshot utilities |
| **[Troubleshooting](reference/troubleshooting.md)** | Common issues and solutions |
| **[LSP Requirements](reference/lsp-requirements.md)** | Language server dependencies |

---

## Advanced

| Topic | Description |
|-------|-------------|
| **[Neovim Plugins](advanced/neovim-plugins.md)** | Adding and configuring plugins |
| **[Tmux Workflows](advanced/tmux-workflows.md)** | Advanced multiplexer usage |
| **[Integration](advanced/integration.md)** | How tools work together |

---

<div align="center">
<sub>

[Back to main README](../README.md)

</sub>
</div>

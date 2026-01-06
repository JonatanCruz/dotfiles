# Neovim Configuration

> Modular Neovim with lazy.nvim, LSP, and Catppuccin Mocha theme

## Quick Reference

- **Config Path**: `~/.config/nvim/`
- **Documentation**: [docs/services/nvim.md](../../docs/services/nvim.md)
- **Architecture**: Modular structure with utils, constants, and categorized plugins
- **Key Features**: Lazy.nvim, Mason LSP, Telescope, LazyGit, nvim-cmp, Supermaven AI
- **Theme**: Catppuccin Mocha with centralized transparency system

## Structure

```
nvim/.config/nvim/
├── init.lua                # Entry point
├── lua/
│   ├── config/             # Core configuration (options, keymaps, autocmds)
│   ├── utils/              # Shared utilities (icons, colors, transparency)
│   └── plugins/            # Categorized plugins (ui/, editor/, coding/, lsp/, git/, tools/)
└── docs/                   # Architecture and contribution guides
```

## Quick Start

```bash
# Apply config
cd ~/dotfiles && stow nvim

# Open Neovim (plugins auto-install)
nvim

# Manage plugins
:Lazy sync    # Install/update all plugins
:Mason        # Install LSP servers
```

For complete documentation, see [docs/services/nvim.md](../../docs/services/nvim.md)

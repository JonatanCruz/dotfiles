# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **dotfiles repository** for a Linux development environment, managed with **GNU Stow** and Git. The configuration follows the Dracula color scheme throughout, emphasizing keyboard-driven navigation (Vim-style) and transparent backgrounds.

## Architecture

### GNU Stow Structure

Each top-level directory represents a "Stow package" that contains configuration files in their target directory structure:

```
package-name/
└── .config/app/     # Maps to ~/.config/app/
    └── config.file
```

When you run `stow nvim` from the repository root, Stow creates symlinks from the home directory to the repository files:
- `~/dotfiles/nvim/.config/nvim/` → `~/.config/nvim/`

### Key Packages

- **nvim**: Modular Neovim configuration using lazy.nvim
- **zsh**: Zsh shell configuration with custom aliases
- **zsh-plugins**: Managed as git submodules
- **tmux**: Terminal multiplexer with custom keybindings
- **starship**: Command prompt configuration
- **yazi**: File explorer configuration
- **docker**: Docker completion scripts and configuration

## Commands for Development

### Managing Dotfiles with Stow

```bash
# Apply specific configuration (run from ~/dotfiles)
stow nvim
stow tmux
stow zsh

# Apply all configurations
stow */

# Reinstall configuration (useful after updates)
stow -R nvim

# Remove configuration
stow -D nvim

# Simulate installation (dry run)
stow -n nvim
```

### Neovim Development

```bash
# Open Neovim plugin manager
nvim
:Lazy

# Sync all plugins (install/update)
:Lazy sync

# Clean unused plugins
:Lazy clean

# Check Neovim health
:checkhealth

# Manage LSP servers
:Mason

# Restart LSP server
:LspRestart

# Complete reinstall (if needed)
rm -rf ~/.local/share/nvim ~/.cache/nvim
nvim  # Plugins will auto-install
```

### Git Submodules (for zsh-plugins)

```bash
# Initialize submodules after clone
git submodule update --init --recursive

# Update all submodules
git submodule update --remote

# Add a new submodule
git submodule add <repo-url> zsh-plugins/.zsh/<plugin-name>
```

### Tmux Plugin Management

```bash
# Install TPM (Tmux Plugin Manager) if not present
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install plugins (inside tmux)
# Press: Prefix + I (Ctrl+s then Shift+I)

# Update plugins
# Press: Prefix + U

# Uninstall plugins
# Press: Prefix + alt + u
```

## Neovim Configuration Architecture

### Entry Point and Loading Order

1. **init.lua**: Sets leader key and bootstraps lazy.nvim
2. **lua/config/lazy.lua**:
   - Auto-installs lazy.nvim if missing
   - Loads core configuration (globals, options, keymaps, autocmds)
   - Imports all plugins from `lua/plugins/`

### Core Configuration Files (lua/config/)

- **globals.lua**: Global variables
- **options.lua**: Neovim settings (line numbers, tabs, etc.)
- **keymaps.lua**: Global keybindings (Leader is `<Space>`)
- **autocmds.lua**: Autocommands and events
- **lsp_servers.lua**: List of LSP servers to auto-install via Mason

### Plugin Organization (lua/plugins/)

Plugins are organized by function:
- **colorscheme.lua**: Dracula theme with transparency
- **completion.lua**: nvim-cmp and snippets
- **editing.lua**: Autopairs, comments, editing utilities
- **lsp.lua**: Mason, LSP configuration, Treesitter
- **telescope.lua**: Fuzzy finder
- **tools.lua**: LazyGit integration
- **ui.lua**: lualine, nvim-tree, notifications

### Adding New Plugins

Create or edit a file in `lua/plugins/`:

```lua
return {
  {
    'author/plugin-name',
    event = 'VeryLazy',  -- Lazy load when appropriate
    config = function()
      -- Configuration here
    end,
  }
}
```

Lazy.nvim auto-detects changes and prompts to sync.

### Adding New LSP Servers

Edit `lua/config/lsp_servers.lua` and add the server name. Mason will auto-install on next Neovim launch.

## Important Keybindings

### Tmux (Prefix: Ctrl+s)

- Split horizontal: `Prefix + |`
- Split vertical: `Prefix + -`
- Navigate panes: `Prefix + h/j/k/l`
- Resize panes: `Prefix + H/J/K/L` (hold for repeat)
- Reload config: `Prefix + r`

### Neovim (Leader: Space)

**File Operations:**
- Save: `<leader>w`
- Quit: `<leader>q`
- Close buffer: `<leader>bd`

**Navigation:**
- File explorer: `<leader>e`
- Find files: `<leader>ff`
- Search text: `<leader>fg`
- Switch buffers: `Shift+h/l`

**LSP:**
- Hover docs: `K`
- Go to definition: `gd`
- References: `gr`
- Rename: `<leader>rn`
- Diagnostics: `<leader>d`
- Next/prev diagnostic: `]d` / `[d`

**Git:**
- LazyGit: `<leader>gg`

## Configuration Philosophy

1. **Vim-style navigation**: All tools use h/j/k/l navigation
2. **Lazy loading**: Neovim plugins load on-demand for fast startup
3. **Transparency**: Background set to transparent in Neovim, Tmux
4. **Dracula theme**: Consistent purple/cyan color scheme
5. **Modular structure**: Easy to add/remove components independently

## Tool Ecosystem

This configuration uses modern CLI alternatives:
- `eza` replaces `ls` (aliased in .zshrc)
- `bat` replaces `cat`
- `fd` replaces `find`
- `ripgrep` replaces `grep`
- `zoxide` replaces `cd` (smart directory jumping)
- `fzf` for fuzzy finding

All aliases are defined in `zsh/.zshrc`.

## Tmux-Neovim Integration

The configuration includes vim-tmux-navigator plugin for seamless navigation between Tmux panes and Neovim splits using Ctrl+h/j/k/l.

## Adding New Configurations

To add a new tool:

```bash
# Create directory structure
mkdir -p new-tool/.config/new-tool

# Add configuration files
# ... add your configs ...

# Apply with Stow
stow new-tool

# Commit
git add new-tool/
git commit -m "Add new-tool configuration"
```

## Shell Configuration Note

The prefix in `.tmux.conf` is `Ctrl+s`, NOT the traditional `Ctrl+b` mentioned in some files. The zsh configuration sources plugins from `~/.zsh/` and must be loaded in this order:
1. zsh-autosuggestions
2. zsh-history-substring-search
3. zsh-syntax-highlighting (MUST be last)
4. Starship init (MUST be very last line)

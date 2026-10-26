# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) and OpenCode when working with code in this repository.

## 🤖 Navegación de Código: Serena + codebase-memory (grafo)

Dos MCP complementarios. **Engram sigue siendo el único sistema de memoria** — ninguno guarda memoria entre sesiones.

- **codebase-memory (grafo)** → navegar/entender **barato** (solo lectura, ~120x menos tokens). `search_code`, `query_graph` (Cypher), `trace_path`, `get_architecture`. Indexa una vez con `index_repository(repo_path=...)`.
- **Serena** → **editar/refactorizar** por símbolo, que el grafo NO hace: `serena_rename_symbol`, `serena_replace_symbol_body`, `serena_insert_after_symbol`.

**Regla**: grafo para leer, Serena para escribir. No dupliques Serena (plugin **o** servidor `.mcp.json`, nunca ambos → procesos `uvx` huérfanos).

---

## 🧠 Memoria: Engram + CLAUDE.md

El protocolo completo (cuándo `mem_save`/`mem_search`, formato, sesión) vive en
`claude/.claude/CLAUDE.md`, que se carga en todas las sesiones como `~/.claude/CLAUDE.md`.
Resumen: **hechos y decisiones entre sesiones → Engram**; **reglas del dueño → un CLAUDE.md**
(este si son del repo, el global si no). Nunca `MEMORY.md` ni `memory/*.md`.

---

## Repository Overview

This is a **dotfiles repository** for a macOS/Linux development environment, managed with **GNU Stow** and Git. The configuration follows the **Catppuccin Mocha** color scheme throughout, emphasizing keyboard-driven navigation (Vim-style) and transparent backgrounds.

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
- **wezterm**: Terminal emulator configuration
- **git**: `.gitconfig`, global gitignore and generated colors (`.gitconfig-colors`)
- **opencode**: OpenCode agent config (`~/.config/opencode/`)
- **mise**: Runtime version manager config (`~/.config/mise/`)
- **claude**: Claude Code config linked as `~/.claude/` (CLAUDE.md, hooks, settings.json, agents)
- **theme**: NOT a Stow package. `theme/palette.sh` is the single color source;
  `theme/apply.sh` generates the color files of git, tmux, claude, starship and yazi
  (`theme/apply.sh --check` fails if they drift; CI runs it)

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

# Simulate installation (dry run). Without -v, `stow -n` prints nothing.
stow -n -v nvim
```

**After a `git pull` that adds new files to a package, run `stow -R <pkg>`.**
Stow only links what existed when the package was stowed: when a whole directory is
linked (folded) new files show up on their own, but inside a directory that Stow had
to create (unfolded, e.g. `~/.config` shared by several packages) a new file stays
unlinked until you restow. `scripts/health-check.sh` detects this in its "Stow Link
Completeness" section. To check by hand, `stow -n -v <pkg> | grep ^LINK` — without
`-v`, `stow -n` prints nothing even when links are missing.

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

- **globals.lua**, **constants.lua**: Global variables and shared constants
- **options.lua**: Neovim settings (line numbers, tabs, etc.)
- **keymaps.lua**: Global keybindings (Leader is `<Space>`, set in `init.lua`)
- **autocmds.lua**: Autocommands (includes hiding the tmux status bar inside Neovim)
- **diagnostics.lua**: `vim.diagnostic` configuration
- **lsp_servers.lua**: List of LSP servers to auto-install via Mason
- **lazy.lua**: lazy.nvim bootstrap and plugin import

### Plugin Organization (lua/plugins/)

One file per plugin, grouped in subdirectories by function:

- **colorscheme.lua**: Catppuccin Mocha theme with transparency
- **lsp.lua**: Mason + LSP configuration and LSP keymaps (`LspAttach`)
- **coding/**: completion (`cmp.lua`) and AI assistant (`ai.lua`)
- **editor/**: autopairs, comments, formatting, goto-preview, treesitter
- **git/**: gitsigns, diffview, lazygit
- **lsp/**: diagnostics UI, linting, neodev
- **debug/**: nvim-dap and dap-ui
- **test/**: neotest (NOT imported in `lua/config/lazy.lua` today, so it does not load)
- **tools/**: telescope, aerial, neogen, refactoring, session
- **ui/**: statusline, bufferline, nvim-tree, which-key, noice, notify, alpha, etc.

Other `lua/` dirs: `snippets/` (LuaSnip snippets per language) and `utils/`
(`error_handler.safe_require`, colors, icons, transparency).

### Adding New Plugins

Create or edit a file in `lua/plugins/<group>/`. Each subdirectory must be listed as `{ import = 'plugins.<group>' }` in `lua/config/lazy.lua`, or its files never load:

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

- Split horizontal (arriba/abajo): `Prefix + -`
- Split vertical (izquierda/derecha): `Prefix + |`
- Navigate panes: `Ctrl+h/j/k/l` (sin prefix, via vim-tmux-navigator)
- Resize panes: `Alt+h/j/k/l` (vim-aware, sin prefix)
- Zoom pane: `Prefix + m`
- Toggle status bar: `Prefix + \`
- Reload config: `Prefix + r`
- Session manager: `Prefix + s` (SessionX con fzf+zoxide)

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
- Rename: `<leader>cr`
- Code action: `<leader>ca`
- Line diagnostics: `<leader>cd` (also `gl`)
- Next/prev diagnostic: `]d` / `[d`

**Git:**

- LazyGit: `<leader>gg`

## Configuration Philosophy

1. **Vim-style navigation**: All tools use h/j/k/l navigation
2. **Lazy loading**: Neovim plugins load on-demand for fast startup
3. **Transparency**: Background set to transparent in Neovim, Tmux
4. **Catppuccin Mocha theme**: Consistent pastel color scheme (blue: #89b4fa, mauve: #cba6f7, pink: #f5c2e7)
5. **Modular structure**: Easy to add/remove components independently
6. **Performance-focused**: Optimized configurations for minimal startup time

## Tool Ecosystem

This configuration uses modern CLI alternatives:

- `eza` replaces `ls` (aliased in `aliases/tools.zsh`)
- `bat` replaces `cat`
- `fd` replaces `find`
- `ripgrep` replaces `grep`
- `zoxide` replaces `cd` (smart directory jumping)
- `fzf` for fuzzy finding

Aliases are organized in modular files under `zsh/.config/zsh/aliases/` (tools, git, gh, docker, gcloud, navigation, editor, tmux, utils, node).

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

`zsh/.config/zsh/plugins.zsh` sources the plugins from `~/.zsh/` (no plugin manager) and must keep this order:

1. zsh-autosuggestions
2. zsh-history-substring-search
3. zsh-you-should-use
4. zsh-syntax-highlighting (MUST be last plugin before tools)
5. Starship init (MUST be the last line of `plugins.zsh`)

## OpenCode Integration

This dotfiles repository is designed to work seamlessly with OpenCode. To ensure OpenCode adapts to your terminal configuration:

### Recommended OpenCode Configuration

Create or edit `~/.config/opencode/opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "theme": "system"
}
```

The `system` theme ensures OpenCode:

- ✅ Respects terminal transparency and opacity
- ✅ Uses your Catppuccin Mocha ANSI colors
- ✅ Maintains visual consistency with Neovim, Tmux, and Starship
- ✅ Adapts to your terminal's font configuration

### Verify Truecolor Support

Ensure your terminal supports 24-bit color for proper theme rendering:

```bash
# Check truecolor support
echo $COLORTERM
# Should output: truecolor or 24bit

# If not set, add to your shell config
export COLORTERM=truecolor
```

### Quick Commands

```bash
# Change OpenCode theme (inside OpenCode)
/theme

# Initialize OpenCode for a project
/init

# Share a conversation
/share
```

## Bootstrap: mise (versiones de runtimes)

`mise` sustituye a nvm + pyenv como gestor único. Maneja versiones distintas
**por proyecto y por servidor** desde una sola herramienta.

La config base está versionada en `mise/.config/mise/config.toml` y se aplica
con Stow. En cada servidor nuevo hay que instalar el binario una vez:

```bash
# macOS / Linux con Homebrew
brew install mise

# Linux sin brew
curl https://mise.run | sh

# Luego, desde el repo:
stow mise
mise install          # instala las versiones declaradas en la config global
```

### Uso diario

```bash
mise use node@20      # fija node 20 en el proyecto actual (crea mise.toml)
mise ls               # qué hay instalado
mise outdated         # qué se puede actualizar
mise install          # instala lo declarado que falte
```

Cada proyecto puede declarar sus versiones en `mise.toml`. Los archivos
`.nvmrc` y `.python-version` de proyectos existentes **también funcionan**
(`idiomatic_version_file_enable_tools` en la config global lo habilita).

`mise activate` instala un hook de precmd que reescribe el PATH al cambiar de
directorio; no usa shims, así que `node` es el binario real y no un wrapper.
Cuesta ~20ms de arranque; a cambio, el primer `node` ya no paga los ~310ms que
costaba el lazy-load de nvm.

---

## Bootstrap: Engram Plugin

Engram es el sistema de memoria persistente. El `settings.json` lo habilita automáticamente vía Stow, pero el plugin debe instalarse una vez en cada nuevo servidor:

```bash
# Instalar Engram (correr desde cualquier directorio, una sola vez por servidor)
claude plugin install engram@engram
```

Esto descarga el plugin desde `Gentleman-Programming/engram` (ya registrado como marketplace en `settings.json`).

### Verificar instalación

```bash
# Verificar que Engram aparece como plugin instalado
claude plugin list
```

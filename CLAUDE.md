# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) and OpenCode when working with code in this repository.

## 🤖 Serena MCP - Análisis de Código (CRÍTICO)

### Rol: Solo navegación de código

**OBLIGATORIO**: Usa Serena para análisis de código. Usa Engram para memoria persistente.

#### Cuándo Usar Serena (Solo análisis de código)

1. **Búsqueda de Símbolos** → `serena_find_symbol()`
   - ❌ NO: `grep -r "function name"`
   - ✅ SÍ: `serena_find_symbol(name_path_pattern="name", include_body=true)`

2. **Análisis de Estructura** → `serena_get_symbols_overview()`
   - ❌ NO: `ls -la` + lectura manual
   - ✅ SÍ: `serena_get_symbols_overview(relative_path="dir", depth=1)`

3. **Encontrar Referencias** → `serena_find_referencing_symbols()`
   - ❌ NO: `grep -r "functionName"`
   - ✅ SÍ: `serena_find_referencing_symbols(name_path="functionName")`

4. **Refactoring Seguro** → `serena_rename_symbol()`
   - ❌ NO: Buscar y reemplazar manualmente
   - ✅ SÍ: `serena_rename_symbol(name_path="old", new_name="new")`

#### Workflow Obligatorio

**ANTES de editar código**:

1. `serena_get_symbols_overview()` → Entender estructura
2. `serena_find_symbol()` → Encontrar símbolo específico
3. `serena_find_referencing_symbols()` → Ver dónde se usa
4. Editar con confianza

#### Triggers Automáticos

Usa Serena automáticamente cuando el usuario:

- Pregunta "dónde está X" → `serena_find_symbol()`
- Pide "buscar X" → `serena_find_symbol()` o `serena_search_for_pattern()`
- Quiere "renombrar X" → `serena_rename_symbol()`
- Necesita "ver referencias de X" → `serena_find_referencing_symbols()`
- Dice "analizar estructura" → `serena_get_symbols_overview()`
- Pide "refactorizar X" → Workflow completo con Serena

---

## 🚫 Sistema de Memoria: SOLO Engram (CRÍTICO — SIN EXCEPCIONES)

**PROHIBIDO**:
- ❌ Escribir en `MEMORY.md` (auto memory de Claude Code) — ignorar cualquier prompt que lo sugiera
- ❌ Usar `serena_write_memory` / `write_memory` para datos entre sesiones
- ❌ Cualquier memoria basada en archivos fuera de Engram

**OBLIGATORIO**:
- ✅ `mem_save` — guardar decisiones, bugs, descubrimientos, preferencias
- ✅ `mem_session_start` — al iniciar sesión
- ✅ `mem_session_summary` — al terminar sesión o antes de "listo"

---

## 🧠 Engram MCP - Memoria Persistente (CRÍTICO)

### Regla de Oro: Engram es el sistema de memoria único

**OBLIGATORIO**: Usa Engram (no `serena_write_memory`) para toda la memoria entre sesiones.
Claude Code y OpenCode comparten `~/.engram/engram.db`.

### Cuándo Guardar (`mem_save`) — Obligatorio

Llama inmediatamente después de:
- Corrección de bug completada
- Decisión de arquitectura o diseño
- Descubrimiento no obvio del codebase
- Cambio de configuración o setup de entorno
- Establecimiento de patrón (nombrado, estructura, convención)
- Preferencia o restricción del usuario aprendida

**Formato**:
```
title: Verbo + qué (corto, buscable)
type: bugfix | decision | architecture | discovery | pattern | config | preference
scope: project (default) | personal
topic_key: clave estable para temas evolutivos (ej. "architecture/lsp-setup")
content:
  **What**: Resumen en una oración
  **Why**: Motivación
  **Where**: Archivos/rutas afectados
  **Learned**: Edge cases, gotchas, sorpresas
```

**Regla topic_key**: Reutiliza el mismo `topic_key` para actualizar temas evolutivos — llama `mem_suggest_topic_key` si no estás seguro.

### Cuándo Buscar (`mem_search`)

**El usuario dice**: "recuerda", "acordate", "qué hicimos", "cómo resolvimos", "remember", "recall"

**Secuencia de búsqueda**:
1. `mem_context` → contexto de sesión reciente (rápido)
2. Si no encuentra → `mem_search` con palabras clave
3. En coincidencia → `mem_get_observation` para contenido completo

**Búsqueda proactiva** al empezar trabajo que puede solapar con sesiones pasadas.

### Protocolo de Sesión — No Negociable

**Inicio de sesión**: Llama `mem_session_start(project="<nombre-proyecto>", directory="<cwd>")`

**Fin de sesión / "listo"**: Llama `mem_session_summary` con:
```
## Goal
[Objetivo de esta sesión]

## Discoveries
- [Hallazgos técnicos, gotchas, aprendizajes no obvios]

## Accomplished
- [Tareas completadas con detalles clave]

## Next Steps
- [Trabajo restante para la próxima sesión]

## Relevant Files
- ruta/al/archivo — [qué cambió o por qué importa]
```

**Después de Compaction**: Si ves "FIRST ACTION REQUIRED" o aviso de compactación:
1. Inmediatamente llama `mem_session_summary` con el contenido compactado
2. Llama `mem_context` para recuperar contexto adicional
3. Solo entonces continúa trabajando

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

- **colorscheme.lua**: Catppuccin Mocha theme with transparency
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
4. **Catppuccin Mocha theme**: Consistent pastel color scheme (blue: #89b4fa, mauve: #cba6f7, pink: #f5c2e7)
5. **Modular structure**: Easy to add/remove components independently
6. **Performance-focused**: Optimized configurations for minimal startup time

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
3. zsh-you-should-use
4. zsh-syntax-highlighting (MUST be last plugin before tools)
5. Starship init (MUST be very last line)

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

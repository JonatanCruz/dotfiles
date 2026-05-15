# Neovim - Editor de Código Modular

Configuración modular de Neovim con lazy.nvim, LSP completo, 60+ highlight groups transparentes y tema Catppuccin Mocha.

## Características Principales

- **🎨 Tema Catppuccin Mocha**: Con 60+ highlight groups transparentes
- **⚡ Lazy Loading**: Optimizado con lazy.nvim para inicio rápido
- **🔍 LSP Completo**: Mason auto-instala servidores LSP
- **📝 Autocompletado**: nvim-cmp con múltiples fuentes y snippets
- **🔭 Telescope**: Búsqueda fuzzy de archivos, texto y símbolos
- **🌲 Treesitter**: Resaltado sintáctico avanzado
- **🎯 Git Integration**: LazyGit integrado con `<leader>gg`
- **🤖 AI**: Supermaven para autocompletado con IA
- **🔗 Tmux Integration**: Navegación seamless con vim-tmux-navigator

## Arquitectura Modular

```
nvim/.config/nvim/
├── init.lua                  # Punto de entrada
├── lua/
│   ├── config/              # Configuración base
│   │   ├── lazy.lua         # Bootstrap de lazy.nvim
│   │   ├── options.lua      # Opciones de Neovim
│   │   ├── keymaps.lua      # Keymaps globales
│   │   ├── autocmds.lua     # Autocomandos
│   │   └── lsp_servers.lua  # Lista de LSP servers
│   │
│   ├── utils/              # Utilidades reutilizables
│   │   ├── init.lua        # Helpers generales
│   │   ├── icons.lua       # Iconos centralizados
│   │   └── colors.lua      # Helpers de colores Catppuccin
│   │
│   └── plugins/            # Plugins organizados por categoría
│       ├── colorscheme.lua
│       ├── ui/            # 11 plugins de interfaz
│       ├── editor/        # Edición y formateo
│       ├── coding/        # Autocompletado
│       ├── lsp/           # LSP y diagnósticos
│       ├── git/           # Herramientas Git
│       └── tools/         # Herramientas generales
```

## Keybindings Esenciales

**Leader**: `<Space>`

### Navegación de Archivos
- `<leader>e` - Toggle file explorer (nvim-tree)
- `<leader>ff` - Buscar archivos (Telescope)
- `<leader>fg` - Buscar texto en archivos
- `<leader>fb` - Buscar buffers abiertos
- `<leader>fo` - Buscar archivos recientes

### Edición
- `<leader>w` - Guardar archivo
- `<leader>q` - Cerrar ventana
- `<leader>bd` - Cerrar buffer
- `Shift+h/l` - Navegar entre buffers
- `gcc` - Comentar/descomentar línea
- `gc` + motion - Comentar con movimiento

### LSP
- `K` - Hover documentation
- `gd` - Ir a definición
- `gr` - Ver referencias
- `gi` - Ir a implementación
- `<leader>rn` - Renombrar símbolo
- `<leader>ca` - Code actions
- `<leader>d` - Ver diagnósticos
- `]d` / `[d` - Siguiente/anterior diagnóstico

### Git
- `<leader>gg` - Abrir LazyGit
- `<leader>gs` - Git status
- `<leader>gc` - Git commits
- `<leader>gb` - Git branches
- `]c` / `[c` - Siguiente/anterior cambio

### Diffview (Git avanzado)
- `<leader>gd` - Abrir Diffview (diff completo)
- `<leader>gD` - Cerrar Diffview
- `<leader>gfh` - Historial de archivos (todo el repo)
- `<leader>gff` - Historial del archivo actual
- `<leader>gm` - Conflictos de merge
- `<leader>gc` - Diff del último commit

### Debugging (DAP)
- `<leader>db` - Toggle breakpoint
- `<leader>dB` - Breakpoint condicional
- `<leader>dc` - Continuar/Iniciar debug
- `<leader>di` - Step into
- `<leader>dO` - Step over
- `<leader>do` - Step out
- `<leader>dC` - Run to cursor
- `<leader>dl` - Re-ejecutar último debug
- `<leader>dt` - Terminar debug
- `<leader>du` - Toggle DAP UI
- `<leader>dr` - Toggle REPL
- `<leader>de` - Evaluar expresión (normal/visual)
- `<leader>dw` - Hover widgets
- `<leader>dk` / `<leader>dj` - Navegar stack arriba/abajo

Lenguajes soportados: JavaScript, TypeScript, React (TSX/JSX), Python

### Testing (Neotest)
- `<leader>tt` - Ejecutar test más cercano
- `<leader>tf` - Ejecutar tests del archivo
- `<leader>ta` - Ejecutar todos los tests
- `<leader>tl` - Re-ejecutar último test
- `<leader>ts` - Toggle resumen de tests
- `<leader>to` - Abrir output del test
- `<leader>tO` - Toggle panel de output
- `<leader>tw` - Toggle watch mode
- `<leader>td` - Debug test más cercano (integración DAP)
- `<leader>tS` - Detener tests
- `<leader>tn` / `<leader>tp` - Siguiente/anterior test fallido

Frameworks soportados: Jest, Vitest (auto-detección)

### Refactoring
- `<leader>re` - Extract function (visual)
- `<leader>rf` - Extract function to file (visual)
- `<leader>rv` - Extract variable (visual)
- `<leader>ri` - Inline variable (normal/visual)
- `<leader>rI` - Inline function
- `<leader>rb` - Extract block
- `<leader>rbf` - Extract block to file
- `<leader>rs` - Seleccionar refactoring (Telescope)
- `<leader>rd` - Debug: print variable
- `<leader>rc` - Debug: cleanup prints

### Terminal
- `<leader>tt` - Toggle terminal flotante
- `<C-\>` - Toggle terminal en split

## Sistema de Transparencia

La configuración incluye 60+ highlight groups transparentes para integración perfecta con el terminal:

- Background transparente completo
- Sidebar transparente (nvim-tree)
- Statusline semi-transparente
- Floating windows con transparency
- Telescope con fondo transparente

## Plugins Principales

### UI (11 plugins)
- **lualine**: Statusline minimalista
- **bufferline**: Tabs para buffers
- **nvim-tree**: File explorer
- **which-key**: Guía de keybindings
- **noice**: UI mejorada para mensajes
- **indent-blankline**: Guías de indentación
- **dressing**: Mejoras de UI nativas

### LSP & Completion
- **mason.nvim**: Gestor de LSP servers
- **nvim-lspconfig**: Configuración LSP
- **nvim-cmp**: Autocompletado
- **LuaSnip**: Snippets
- **treesitter**: Parsing y resaltado

### Herramientas
- **telescope.nvim**: Búsqueda fuzzy
- **lazygit.nvim**: Integración Git
- **vim-tmux-navigator**: Navegación Tmux
- **supermaven-nvim**: AI completion
- **aerial.nvim**: Symbol outline panel

### Debug & Testing
- **nvim-dap**: Debug Adapter Protocol (Node.js, TypeScript, Python)
- **nvim-dap-ui**: Interfaz visual para debugging
- **nvim-dap-virtual-text**: Valores inline durante debug
- **neotest**: Testing framework (Jest, Vitest)

### Git Avanzado
- **diffview.nvim**: Diff viewer y resolución de conflictos
- **gitsigns.nvim**: Indicadores de cambios en gutter

### Refactoring & Code Quality
- **refactoring.nvim**: Extract function/variable/block, inline
- **conform.nvim**: Auto-formateo on save
- **nvim-lint**: Linting asíncrono

### Focus & UX
- **zen-mode.nvim**: Modo Zen para focus
- **persistence.nvim**: Sesiones automáticas
- **todo-comments.nvim**: Highlight y búsqueda de TODOs
- **neogen**: Generación de docstrings

## Personalización

### Agregar Plugins

Para guía completa sobre cómo agregar plugins, ver [Neovim Plugins Avanzados](../advanced/neovim-plugins.md).

**Ejemplo rápido**:

1. Crear archivo en `lua/plugins/categoria/mi-plugin.lua`:

```lua
return {
  "autor/nombre-plugin",
  event = "VeryLazy",
  keys = {
    { "<leader>x", "<cmd>Comando<cr>", desc = "Descripción" },
  },
  opts = {
    -- configuración
  },
}
```

2. Reiniciar Neovim - lazy.nvim detecta el cambio automáticamente

### Agregar LSP Servers

Editar `lua/config/lsp_servers.lua` y agregar el servidor:

```lua
return {
  -- ... otros servidores
  "nuevo_servidor",
}
```

Mason lo instalará automáticamente en el próximo inicio.

### Personalizar Colores

Los colores de Catppuccin están centralizados en `lua/utils/colors.lua`:

```lua
local colors = require("utils.colors")

-- Usar en configuración de plugins
fg = colors.primary  -- Azul
bg = colors.bg       -- Fondo
error_color = colors.diagnostic.error
```

## Comandos Útiles

```vim
:Lazy               " Gestor de plugins
:Lazy sync          " Sincronizar plugins
:Mason              " Gestor de LSP servers
:LspInfo            " Info de LSP
:LspRestart         " Reiniciar LSP
:checkhealth        " Diagnóstico completo
:Telescope          " Ver comandos Telescope
```

## Instalación

```bash
# Aplicar con Stow
cd ~/dotfiles
stow nvim

# Al abrir Neovim:
# 1. lazy.nvim se instala automáticamente
# 2. Los plugins se instalan automáticamente
# 3. Mason instala LSP servers automáticamente
```

## Solución de Problemas

### Plugins no se cargan
```bash
rm -rf ~/.local/share/nvim ~/.cache/nvim
nvim  # Se reinstalará todo automáticamente
```

### LSP no funciona
```vim
:LspInfo          " Ver si el servidor está corriendo
:Mason            " Reinstalar servidor si es necesario
:LspRestart       " Reiniciar el servidor
```

### Colores incorrectos
- Verifica que tu terminal soporte 24-bit color
- Configura `TERM=xterm-256color` en tu shell
- Usa WezTerm, iTerm2, o Alacritty para mejor soporte

## Integración con Otras Herramientas

- **Tmux**: Navegación seamless con `Ctrl+h/j/k/l`
- **LazyGit**: Integrado con `<leader>gg`
- **Yazi**: Se puede abrir desde Neovim con integración
- **Terminal**: Terminal flotante integrado

## Recursos Adicionales

- [Guía de Personalización](../guides/customization.md)
- [Plugins Avanzados](../advanced/neovim-plugins.md)
- [Keybindings Completos](../guides/keybindings.md)
- [Workflows](../guides/workflows.md)

## Referencias

- [Neovim](https://neovim.io/)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [Catppuccin](https://github.com/catppuccin/nvim)
- [Mason.nvim](https://github.com/williamboman/mason.nvim)

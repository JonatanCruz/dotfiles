# Configuración de Neovim

Configuración modular de Neovim usando Lua y lazy.nvim como gestor de plugins.

## 📚 Documentación

- **[STRUCTURE.md](docs/STRUCTURE.md)** - Arquitectura completa del proyecto (200+ líneas)
- **[CONTRIBUTING.md](docs/CONTRIBUTING.md)** - Guía detallada para agregar plugins (250+ líneas)

## 📑 Tabla de Contenidos

- [Estructura del Proyecto](#estructura-del-proyecto)
  - [Arquitectura Escalable](#️-arquitectura-escalable)
  - [Utilidades Compartidas](#️-utilidades-compartidas)
- [Características Principales](#características-principales)
- [Instalación](#instalación)
- [Comandos Útiles](#comandos-útiles)
- [Atajos de Teclado](#atajos-de-teclado-principales)
- [Personalización](#personalización)
- [Configuración de AI y Linting](#configuración-de-ai-y-linting)
- [Migración y Limpieza](#migración-y-limpieza)
- [Solución de Problemas](#solución-de-problemas)
- [Recursos](#recursos)

## Estructura del Proyecto

```
nvim/
└── .config/nvim/
    ├── init.lua                    # Punto de entrada principal (7 líneas)
    ├── lazy-lock.json              # Versiones bloqueadas de plugins
    ├── .luacheckrc                 # Configuración de luacheck
    │
    ├── lua/
    │   ├── config/                 # Configuración base de Neovim
    │   │   ├── autocmds.lua        # Autocomandos
    │   │   ├── constants.lua       # ⭐ Constantes compartidas (borders, colores, LSP, etc)
    │   │   ├── globals.lua         # Variables globales
    │   │   ├── keymaps.lua         # Atajos de teclado globales
    │   │   ├── lazy.lua            # Configuración de lazy.nvim
    │   │   ├── lsp_servers.lua     # Lista de servidores LSP
    │   │   └── options.lua         # Opciones de Neovim
    │   │
    │   ├── utils/                  # ⭐ Utilidades reutilizables
    │   │   ├── init.lua            # Helpers generales (map, autocmd, notify, etc)
    │   │   ├── icons.lua           # 130+ iconos Nerd Font organizados
    │   │   ├── colors.lua          # Paleta Catppuccin + helpers (hex_to_rgb, blend)
    │   │   └── transparency.lua    # ⭐ Sistema centralizado de transparencia (60+ groups)
    │   │
    │   └── plugins/                # ⭐ Plugins organizados en subcategorías
    │       ├── colorscheme.lua     # Tema Catppuccin Mocha
    │       │
    │       ├── ui/                 # Interfaz de usuario (11 archivos)
    │       │   ├── statusline.lua  # Lualine
    │       │   ├── bufferline.lua  # Bufferline con pestañas
    │       │   ├── tree.lua        # Nvim-tree con navegación l/h
    │       │   ├── whichkey.lua    # Which-key con iconos
    │       │   ├── alpha.lua       # Dashboard de inicio
    │       │   ├── notify.lua      # Notificaciones
    │       │   ├── noice.lua       # UI mejorada de mensajes y cmdline
    │       │   ├── indent.lua      # Guías de indentación
    │       │   ├── colorizer.lua   # Preview de colores
    │       │   ├── dressing.lua    # UI mejorada
    │       │   └── todo.lua        # TODOs destacados
    │       │
    │       ├── editor/             # Edición y formateo (4 archivos)
    │       │   ├── formatting.lua  # Conform (formateo automático)
    │       │   ├── treesitter.lua  # Treesitter
    │       │   ├── autopairs.lua   # Autopairs con integración cmp
    │       │   └── comments.lua    # Comment.nvim
    │       │
    │       ├── coding/             # Autocompletado (2 archivos)
    │       │   ├── cmp.lua         # Nvim-cmp completo con cmdline
    │       │   └── ai.lua          # Supermaven AI
    │       │
    │       ├── lsp.lua             # LSP + Mason + Trouble
    │       │
    │       ├── lsp/                # Herramientas LSP adicionales
    │       │   └── linting.lua     # Nvim-lint
    │       │
    │       ├── git/                # Herramientas Git
    │       │   ├── gitsigns.lua    # Gitsigns
    │       │   └── lazygit.lua     # LazyGit TUI
    │       │
    │       └── tools/              # Herramientas generales
    │           └── telescope.lua   # Telescope
    │
    ├── docs/                       # ⭐ Documentación
    │   ├── CONTRIBUTING.md         # Guía para agregar plugins (250+ líneas)
    │   └── STRUCTURE.md            # Arquitectura del proyecto (200+ líneas)
    │
    └── README.md                   # Este archivo
```

### 🏗️ Arquitectura Escalable

Esta configuración está diseñada para ser **escalable y mantenible**:

- **Archivos pequeños**: Cada plugin en su propio archivo (20-80 líneas vs 376 líneas antes)
- **Utilidades compartidas**: Icons, colors, transparency reutilizables
- **Constantes centralizadas**: Configuraciones compartidas en un solo lugar
- **Documentación inline**: Cada archivo con headers descriptivos
- **Lazy loading inteligente**: Optimizado por archivo individual

### ⚙️ Utilidades Compartidas

#### 🎨 **Sistema de Transparencia Centralizado** (`utils/transparency.lua`)

Sistema completo para gestionar transparencia en todos los plugins:

```lua
local transparency = require("utils.transparency")

-- Aplicar transparencia a 60+ highlight groups automáticamente
transparency.apply_transparency()

-- Transparencia específica con opciones
transparency.set_transparent("GroupName", { fg = "#color" })

-- Link transparente
transparency.link_transparent("From", "To")

-- Autocomando para persistir al cambiar tema
transparency.setup_autocmd()
```

**Grupos transparentes incluidos (60+)**:
- Ventanas principales y flotantes
- Nvim-tree, Telescope, Which-key, Alpha
- nvim-cmp, Trouble, Lazy, Mason
- Pmenu, Borders, Statusline

#### 🎯 **Iconos Centralizados** (`utils/icons.lua`)

130+ iconos Nerd Font organizados por categoría:

```lua
local icons = require("utils.icons")

-- Categorías disponibles
icons.diagnostics.error  --
icons.git.branch         --
icons.ui.search          -- 󰍉
icons.whichkey.buffer    -- 󰓩
icons.todo.TODO          --
icons.kind.Function      -- 󰊕
```

#### 🌈 **Helpers de Colores** (`utils/colors.lua`)

Paleta Catppuccin Mocha completa + funciones helper:

```lua
local colors = require("utils.colors")

-- Paleta completa
colors.catppuccin.blue     -- #89b4fa
colors.catppuccin.pink     -- #f5c2e7

-- Alias comunes
colors.primary             -- Azul
colors.secondary           -- Rosa
colors.diagnostic.error    -- Rojo

-- Helpers
colors.hex_to_rgb("#89b4fa")           -- {r=137, g=180, b=250}
colors.with_alpha("#89b4fa", 0.5)      -- rgba(137, 180, 250, 0.50)
colors.blend("#color1", "#color2", 0.5) -- Color mezclado
```

#### 🛠️ **Helpers Generales** (`utils/init.lua`)

Funciones reutilizables:

```lua
local utils = require("utils")

-- Keymaps
utils.map("n", "<leader>x", ":Command<cr>", { desc = "Descripción" })
utils.buf_map(bufnr, "n", "K", vim.lsp.buf.hover, "Hover docs")

-- Autocomandos
utils.autocmd("BufEnter", { pattern = "*.lua", callback = fn })
utils.augroup("MyGroup", { clear = true })

-- Utilidades
utils.notify("Message", "info")
utils.safe_require("module")
utils.has_plugin("telescope.nvim")
utils.executable_exists("rg")
```

#### 📐 **Constantes Compartidas** (`config/constants.lua`)

Configuraciones centralizadas para todos los plugins:

```lua
local constants = require("config.constants")

-- Borders
constants.borders.style              -- "rounded"

-- UI
constants.ui.sidebar_width           -- 30
constants.ui.timeout                 -- 300

-- LSP
constants.lsp.signs                  -- Signos de diagnóstico
constants.lsp.diagnostic_config      -- Config de diagnósticos

-- Transparencia
constants.transparency.enabled       -- true

-- Treesitter
constants.treesitter.ensure_installed -- Lista de lenguajes
```

## Características Principales

### 🎨 Interfaz
- **Tema:** Catppuccin Mocha con fondo transparente
- **Statusline:** lualine.nvim - Barra de estado elegante
- **Bufferline:** bufferline.nvim - Pestañas de buffers en la parte superior con integración Catppuccin
- **Explorador de archivos:** nvim-tree - Navegación con `l` (abrir) y `h` (cerrar), auto-apertura con `nvim .`
- **Pantalla de inicio:** alpha-nvim - Dashboard con ASCII art y accesos rápidos
- **Notificaciones:** nvim-notify - Notificaciones modernas y elegantes
- **UI mejorada de mensajes:** noice.nvim - Cmdline (comandos `:` y búsqueda `/`), mensajes y LSP progress con interfaz moderna
- **Keybinding Discovery:** which-key.nvim v3 - Muestra atajos disponibles con iconos Nerd Font personalizados
- **Guías de indentación:** indent-blankline.nvim - Líneas verticales para visualizar estructura
- **Preview de colores:** nvim-colorizer.lua - Muestra colores hex/RGB en tiempo real
- **UI mejorada:** dressing.nvim - Inputs y selects más bonitos
- **TODOs destacados:** todo-comments.nvim - Resalta TODO, HACK, FIX, NOTE, WARN, PERF

### ⚡ Productividad
- **Búsqueda difusa:** Telescope
- **Git integrado:**
  - Gitsigns - Cambios git en el gutter, blame, navegación de hunks
  - LazyGit - Interfaz TUI completa para git
- **Autocompletado:**
  - nvim-cmp - Autocompletado LSP, snippets, buffer, path
  - **Autocompletado en cmdline** - Sugerencias al escribir `:` (comandos) y `/` (búsqueda)
  - **Supermaven AI** - Autocompletado AI en tiempo real (gratis, 1M token context)
- **Snippets:** friendly-snippets - Biblioteca de templates para múltiples lenguajes
- **Formateo automático:** conform.nvim

### 🔧 LSP y Análisis de Código
- **LSP Manager:** Mason + mason-lspconfig
- **Linting:** nvim-lint - Linting asíncrono para ESLint, Stylelint, Pylint, etc.
- **UI de Diagnósticos:** Trouble.nvim - Vista mejorada de errores y warnings
- **Resaltado de sintaxis:** Treesitter
- **Servidores LSP configurados:**
  - HTML, CSS, Tailwind
  - TypeScript/JavaScript
  - Lua
  - Emmet

### ✨ Edición Mejorada
- Autopairs para paréntesis y comillas
- Comentarios con Comment.nvim
- Resaltado de texto copiado
- Eliminación automática de espacios en blanco

## Instalación

1. Asegúrate de tener Neovim >= 0.9.0
2. Aplica la configuración con Stow desde el repositorio principal:
   ```bash
   cd ~/dotfiles
   stow nvim
   ```
3. Abre Neovim - lazy.nvim se instalará automáticamente
4. Los plugins se instalarán automáticamente en el primer inicio

## Comandos Útiles

### Gestión de Plugins
- `:Lazy` - Abrir interfaz de lazy.nvim
- `:Lazy sync` - Instalar/actualizar todos los plugins
- `:Lazy clean` - Eliminar plugins no usados
- `:Lazy profile` - Ver rendimiento de carga

### LSP
- `:Mason` - Abrir interfaz de Mason
- `:LspInfo` - Ver estado de LSP en el buffer actual
- `:LspRestart` - Reiniciar servidor LSP

### Diagnósticos
- `:Trouble` - Abrir lista de diagnósticos
- `:TroubleToggle` - Toggle vista de diagnósticos

### Linting
- `:Lint` - Ejecutar linting manualmente en el buffer actual

### AI (Supermaven)
- `:SupermavenStart` - Iniciar Supermaven
- `:SupermavenStop` - Detener Supermaven
- `:SupermavenToggle` - Toggle Supermaven
- `:SupermavenUseFree` - Usar tier gratuito (al iniciar primera vez)
- `:SupermavenShowLog` - Ver logs de Supermaven

### Explorador de Archivos (nvim-tree)
- `:NvimTreeToggle` - Abrir/cerrar nvim-tree
- `:NvimTreeFocus` - Enfocar nvim-tree
- `:NvimTreeFindFile` - Ubicar archivo actual en el árbol
- `:NvimTreeCollapse` - Colapsar todo el árbol

### Buffers (bufferline)
- `:BufferLineCycleNext` - Siguiente buffer
- `:BufferLineCyclePrev` - Buffer anterior
- `:BufferLinePick` - Elegir buffer
- `:BufferLinePickClose` - Cerrar buffer (elegir)

### Noice (UI de Mensajes)
- `:Noice` - Ver historial de mensajes
- `:Noice last` - Ver último mensaje
- `:Noice dismiss` - Cerrar todas las notificaciones
- `:Noice stats` - Ver estadísticas de rendimiento
- `:Noice telescope` - Buscar mensajes con Telescope

### Otros
- `:checkhealth` - Diagnóstico del sistema
- `:Telescope` - Abrir selector de Telescope
- `:ConformInfo` - Ver configuración de formateo
- `:WhichKey` - Ver todos los keybindings disponibles
- `:TodoTelescope` - Buscar TODOs en el proyecto

## Atajos de Teclado Principales

### General
- `<Space>` - Leader key
- `<leader>w` - Guardar archivo
- `<leader>q` - Cerrar ventana
- `<leader>rr` - Recargar configuración

### Gestión de Paquetes
- `<leader>pl` - Abrir Lazy
- `<leader>ps` - **Lazy Sync** (instalar/actualizar todos los plugins)
- `<leader>pu` - Lazy Update (actualizar plugins)
- `<leader>pc` - Lazy Clean (limpiar plugins no usados)
- `<leader>pC` - Lazy Check (verificar actualizaciones disponibles)
- `<leader>pr` - Lazy Restore (restaurar desde lock file)
- `<leader>pp` - Lazy Profile (ver rendimiento de carga)
- `<leader>pm` - Abrir Mason
- `<leader>pM` - **Mason Update** (actualizar LSP/linters/formatters)

### Navegación
- `<C-h/j/k/l>` - Navegar entre splits
- `<S-h/l>` - Cambiar entre buffers
- `<leader>bd` - Cerrar buffer actual
- `<Tab>` - Siguiente buffer (bufferline)
- `<S-Tab>` - Buffer anterior (bufferline)
- `<leader>bp` - Elegir buffer interactivamente
- `<leader>bc` - Cerrar buffer (elegir cual)

### Búsqueda (Telescope)
- `<leader>ff` - Buscar archivos
- `<leader>fg` - Buscar texto en proyecto
- `<leader>fb` - Buscar en buffers
- `<leader>fh` - Buscar en ayuda
- `<leader>ft` - Buscar TODOs en el proyecto

### Explorador de Archivos (nvim-tree)
- `<leader>e` - Toggle nvim-tree
- `l` - Abrir carpeta o archivo
- `h` - Cerrar carpeta (volver al padre)
- `j` / `k` - Navegar arriba/abajo
- `v` - Abrir en split vertical
- `s` - Abrir en split horizontal
- `q` - Cerrar nvim-tree
- **Nota:** `nvim .` abre automáticamente nvim-tree

### Git
- `<leader>gg` - Abrir LazyGit
- `]c` / `[c` - Siguiente/anterior hunk de git
- `<leader>hs` - Stage hunk
- `<leader>hr` - Reset hunk
- `<leader>hp` - Preview hunk
- `<leader>hb` - Blame línea completa
- `<leader>tb` - Toggle blame inline
- `<leader>hd` - Diff contra index

### LSP y Diagnósticos
- `K` - Mostrar documentación
- `gd` - Ir a definición
- `gr` - Ver referencias
- `gR` - Ver referencias con Trouble
- `<leader>rn` - Renombrar símbolo
- `<leader>d` - Ver diagnóstico
- `[d` / `]d` - Navegar entre diagnósticos
- `<leader>xx` - Toggle Trouble
- `<leader>xw` - Workspace diagnostics
- `<leader>xd` - Document diagnostics
- `<leader>xq` - Quickfix list
- `<leader>xl` - Location list

### Linting
- `<leader>ll` - Ejecutar linting manualmente

### System/Mensajes (Noice)
- `<leader>sn` - Ver historial de mensajes
- `<leader>sl` - Ver último mensaje
- `<leader>sd` - Cerrar todas las notificaciones

### AI (Supermaven)
- `<Tab>` - Aceptar sugerencia completa de Supermaven (solo en modo Insert)
- `<C-j>` - Aceptar palabra de sugerencia
- `<C-]>` - Descartar sugerencia
- **Nota:** Las sugerencias aparecen automáticamente mientras escribes

### Autocompletado en Cmdline
- `:` + escribir - Muestra comandos disponibles
- `/` + escribir - Muestra sugerencias del buffer
- `<Tab>` / `<S-Tab>` - Navegar sugerencias en cmdline
- `<C-n>` / `<C-p>` - Navegar sugerencias en cmdline
- `<Enter>` - Aceptar sugerencia
- **Nota:** Comandos de plugins (Supermaven, Mason, Telescope, etc.) están disponibles

### Edición
- `gcc` - Comentar/descomentar línea
- `gc` (visual) - Comentar selección
- `J/K` (visual) - Mover líneas arriba/abajo
- `<leader>p` (visual) - Pegar sin perder registro

## Personalización

### Añadir un Nuevo Plugin

**Ver documentación completa**: `docs/CONTRIBUTING.md`

1. **Elegir categoría** apropiada:
   - `plugins/ui/` - Interfaz (statusline, dashboard, etc)
   - `plugins/editor/` - Edición (formateo, comentarios, etc)
   - `plugins/coding/` - Autocompletado y snippets
   - `plugins/lsp/` - LSP y diagnósticos
   - `plugins/git/` - Herramientas Git
   - `plugins/tools/` - Herramientas generales

2. **Crear archivo** `plugins/categoria/mi-plugin.lua`:
   ```lua
   -- ============================================================================
   -- [Nombre] - [Descripción breve]
   -- ============================================================================
   -- [Descripción detallada]
   -- Documentación: [URL del repo]
   -- ============================================================================

   local icons = require("utils.icons")
   local colors = require("utils.colors")
   local constants = require("config.constants")

   return {
     "autor/plugin",
     event = "VeryLazy",
     keys = {
       { "<leader>x", "<cmd>Comando<cr>", desc = "Descripción" },
     },
     opts = {
       icon = icons.ui.search,
       color = colors.primary,
       border = constants.borders.style,
     },
   }
   ```

3. **Guardar** - lazy.nvim detectará el cambio automáticamente

4. **Si usa `<leader>`**, registrar en `plugins/ui/whichkey.lua`:
   ```lua
   { "<leader>x", group = "Nombre", icon = icons.whichkey.nombre },
   ```

### Usar Utilidades Compartidas

**Iconos**:
```lua
local icons = require("utils.icons")
icon = icons.diagnostics.error  --
```

**Colores**:
```lua
local colors = require("utils.colors")
fg = colors.primary              -- #89b4fa
bg = colors.catppuccin.surface0  -- #313244
```

**Transparencia**:
```lua
local transparency = require("utils.transparency")
transparency.set_transparent("MiPlugin", { fg = "#color" })
```

**Constantes**:
```lua
local constants = require("config.constants")
border = constants.borders.style
timeout = constants.ui.timeout
```

### Añadir un Nuevo LSP

1. Edita `lua/config/lsp_servers.lua`
2. Añade el servidor a la lista
3. Reinicia Neovim - Mason lo instalará automáticamente

### Modificar Opciones

- **Opciones de Neovim:** `lua/config/options.lua`
- **Constantes compartidas:** `lua/config/constants.lua`

### Añadir Keymaps

- **Keymaps globales:** `lua/config/keymaps.lua`
- **Keymaps de plugin:** En el archivo del plugin en `lua/plugins/categoria/`
- **Usar helper:** `utils.map("n", "lhs", "rhs", { desc = "..." })`

## Integración con Tmux

La configuración incluye integración automática con tmux:
- La barra de estado de tmux se oculta al entrar a Neovim
- Se restaura al salir de Neovim
- Navegación compartida entre splits de Neovim y paneles de tmux

## Configuración de AI y Linting

### Supermaven (Autocompletado AI)

**Primera vez:**
1. Abre Neovim - Supermaven se instalará automáticamente
2. Ejecuta `:SupermavenUseFree` para activar el tier gratuito
3. Las sugerencias aparecerán automáticamente mientras escribes

**Uso:**
- Las sugerencias AI aparecen en gris mientras escribes
- Presiona `Tab` para aceptar la sugerencia completa
- Presiona `C-j` para aceptar solo una palabra
- Presiona `C-]` para descartar

**Tier gratuito incluye:**
- Autocompletado ilimitado
- Context window de 1 millón de tokens
- Soporte para todos los lenguajes

### Linting con nvim-lint

**Linters soportados (instalar por separado):**

```bash
# JavaScript/TypeScript - ESLint
npm install -g eslint

# CSS/SCSS - Stylelint
npm install -g stylelint

# Python - Pylint
pip install pylint

# Lua - Luacheck (ya instalado)
brew install luacheck  # macOS
# o sudo apt install lua-check  # Linux

# Markdown - markdownlint
npm install -g markdownlint-cli

# YAML - yamllint
pip install yamllint

# Shell - shellcheck
brew install shellcheck  # macOS
# o sudo apt install shellcheck  # Linux

# Docker - hadolint
brew install hadolint  # macOS
```

**Configuración:**
- El linting se ejecuta automáticamente al guardar, entrar al buffer o salir de insert mode
- Si no tienes un linter instalado, simplemente se omitirá sin errores
- Ejecuta `:Lint` manualmente cuando quieras
- Luacheck viene preconfigurado con `.luacheckrc` para reconocer variables globales de Neovim

**Nota:** Solo instala los linters que necesites para tus proyectos.

### Spell Checking (Corrección Ortográfica)

**Configuración actual:**
- Spell checking habilitado automáticamente en archivos Markdown y texto
- Idioma: Inglés (en)

**Agregar español:**
```vim
" Dentro de Neovim, en un archivo .md o .txt:
:set spelllang=es,en
```

Neovim descargará automáticamente los diccionarios de español la primera vez.

**Comandos útiles:**
- `]s` - Ir a la siguiente palabra mal escrita
- `[s` - Ir a la palabra mal escrita anterior
- `z=` - Ver sugerencias de corrección
- `zg` - Agregar palabra al diccionario personal
- `zw` - Marcar palabra como mal escrita

## Migración y Limpieza

### Archivos Antiguos (Si existen)

Después de la refactorización a la nueva estructura modular, algunos archivos monolíticos antiguos pueden seguir existiendo. Si encuentras estos archivos en `lua/plugins/`, **puedes eliminarlos de forma segura**:

```bash
# Archivos que fueron divididos en subcarpetas:
rm -f lua/plugins/ui.lua          # → Dividido en plugins/ui/*
rm -f lua/plugins/editing.lua     # → Dividido en plugins/editor/*
rm -f lua/plugins/completion.lua  # → Dividido en plugins/coding/*
rm -f lua/plugins/git.lua         # → Dividido en plugins/git/*
rm -f lua/plugins/telescope.lua   # → Movido a plugins/tools/telescope.lua
rm -f lua/plugins/linting.lua     # → Movido a plugins/lsp/linting.lua
rm -f lua/plugins/tools.lua       # → Dividido en plugins/tools/*
```

**Nota:** Los archivos nuevos en las subcarpetas (`ui/`, `editor/`, `coding/`, etc.) son los que deben permanecer.

## Solución de Problemas

### Plugins no se cargan
```bash
:Lazy sync
```

### LSP no funciona
```bash
:Mason
# Instala manualmente el servidor que necesites
:LspRestart
```

### Errores al iniciar
```bash
:checkhealth
# Revisa las advertencias y sigue las recomendaciones
```

### Limpiar completamente y reinstalar
```bash
rm -rf ~/.local/share/nvim
rm -rf ~/.cache/nvim
nvim  # Los plugins se reinstalarán
```

## Rendimiento

La configuración está optimizada para carga rápida:
- Plugins cargados de forma diferida cuando sea posible
- Providers innecesarios deshabilitados
- Cache de lazy.nvim habilitado
- Plugins predeterminados de Neovim deshabilitados

## Recursos

### Core
- [Lazy.nvim](https://github.com/folke/lazy.nvim)
- [Mason](https://github.com/williamboman/mason.nvim)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- [Telescope](https://github.com/nvim-telescope/telescope.nvim)

### UI & Theme
- [Catppuccin](https://github.com/catppuccin/nvim)
- [Which-key](https://github.com/folke/which-key.nvim)
- [Trouble](https://github.com/folke/trouble.nvim)
- [Noice](https://github.com/folke/noice.nvim)

### Git
- [Gitsigns](https://github.com/lewis6991/gitsigns.nvim)
- [LazyGit](https://github.com/kdheepak/lazygit.nvim)

### Completion & Snippets
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
- [friendly-snippets](https://github.com/rafamadriz/friendly-snippets)

### AI & Linting
- [Supermaven](https://github.com/supermaven-inc/supermaven-nvim) - Autocompletado AI gratuito
- [nvim-lint](https://github.com/mfussenegger/nvim-lint) - Linting asíncrono

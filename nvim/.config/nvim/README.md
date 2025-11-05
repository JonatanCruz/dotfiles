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
    │       ├── git/                # Herramientas Git (3 archivos)
    │       │   ├── gitsigns.lua    # Gitsigns (hunks, blame)
    │       │   ├── lazygit.lua     # LazyGit TUI
    │       │   └── diffview.lua    # Diffview (diffs completos, merge)
    │       │
    │       ├── debug/              # Debugging (2 archivos)
    │       │   ├── dap.lua         # Debug Adapter Protocol
    │       │   └── dap-ui.lua      # DAP UI
    │       │
    │       ├── test/               # Testing (1 archivo)
    │       │   └── neotest.lua     # Neotest con Jest/Vitest
    │       │
    │       └── tools/              # Herramientas generales (6 archivos)
    │           ├── telescope.lua   # Telescope
    │           ├── session.lua     # Persistence (sesiones)
    │           ├── aerial.lua      # Symbol outline
    │           ├── neogen.lua      # Doc generation
    │           └── refactoring.lua # Refactoring tools
    │
    │   └── snippets/               # ⭐ Custom snippets (89+ snippets)
    │       ├── init.lua            # Loader
    │       ├── typescript.lua      # 18 TS snippets
    │       ├── typescriptreact.lua # 18 React snippets
    │       ├── lua.lua             # 26 Lua/Neovim snippets
    │       └── javascript.lua      # 27 JS snippets
    │
    ├── docs/                       # ⭐ Documentación
    │   ├── CONTRIBUTING.md         # Guía para agregar plugins (250+ líneas)
    │   ├── STRUCTURE.md            # Arquitectura del proyecto (200+ líneas)
    │   ├── SNIPPETS.md             # Guía de custom snippets
    │   └── SNIPPETS_TESTING.md     # Testing de snippets
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
- **Búsqueda difusa:** Telescope - Fuzzy finder para archivos, texto, buffers, comandos
- **Git integrado:**
  - **Gitsigns** - Cambios git en el gutter, blame, navegación de hunks
  - **LazyGit** - Interfaz TUI completa para git
  - **Diffview** - Vista completa de diffs, merge conflicts, file history
- **Autocompletado:**
  - **nvim-cmp** - Autocompletado LSP, snippets, buffer, path
  - **Autocompletado en cmdline** - Sugerencias al escribir `:` (comandos) y `/` (búsqueda)
  - **Supermaven AI** - Autocompletado AI en tiempo real (gratis, 1M token context)
- **Snippets:**
  - **friendly-snippets** - Biblioteca de templates para múltiples lenguajes
  - **Custom snippets** - 89+ snippets personalizados (TS/React/Lua/JS)
- **Formateo automático:** conform.nvim
- **Sesiones:** persistence.nvim - Auto-save/restore de sesiones por proyecto

### 🔧 LSP y Análisis de Código
- **LSP Manager:** Mason + mason-lspconfig
- **Navegación inteligente:**
  - LSP - gd (definition), gr (references), gi (implementation)
  - **Treesitter Textobjects** - ]m/[m (funciones), ]c/[c (clases), text objects (vif, vac)
  - **Aerial** - Symbol outline con panel lateral navegable
- **Linting:** nvim-lint - Linting asíncrono para ESLint, Stylelint, Pylint, etc.
- **UI de Diagnósticos:** Trouble.nvim - Vista mejorada de errores y warnings
- **Resaltado de sintaxis:** Treesitter con incremental selection
- **Servidores LSP configurados:**
  - HTML, CSS, Tailwind
  - TypeScript/JavaScript
  - Lua
  - Emmet

### 🐛 Debugging y Testing
- **Debugging (DAP):**
  - **nvim-dap** - Debug Adapter Protocol para debugging interactivo
  - **nvim-dap-ui** - Interfaz visual para debugging (variables, watches, stack)
  - **Debuggers configurados:** Node.js/TypeScript
  - Breakpoints, step-through, variable inspection, REPL
- **Testing (Neotest):**
  - Framework de testing integrado con Neovim
  - **Adapters:** Jest, Vitest
  - Watch mode, test runner, debug tests con DAP
  - UI con signos de estado (✅ pass, ❌ fail)

### 🔄 Refactoring y Documentación
- **Refactoring (refactoring.nvim):**
  - Extract function/variable
  - Inline variable/function
  - Debug helpers (print statements)
  - Telescope integration para selector de refactorings
- **Generación de Docs (Neogen):**
  - Auto-generación de JSDoc/TSDoc/LDoc
  - Soporte: JS/TS/React/Python/Lua/Rust/Go
  - Templates con placeholders navegables

### ✨ Edición Mejorada
- **Autopairs** - Paréntesis y comillas automáticas con integración cmp
- **Comment.nvim** - Comentarios inteligentes (gcc, gc visual)
- **Resaltado de texto copiado** - Highlight al copiar
- **Eliminación automática de espacios** - Clean trailing whitespace
- **Error handling** - Sistema robusto con safe_require y try/catch

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

### Navegación de Windows y Buffers
- `<C-h/j/k/l>` - Navegar entre splits
- `<S-h/l>` - Cambiar entre buffers
- `<leader>bd` - Cerrar buffer actual
- `<Tab>` - Siguiente buffer (bufferline)
- `<S-Tab>` - Buffer anterior (bufferline)
- `<leader>bp` - Elegir buffer interactivamente
- `<leader>bc` - Cerrar buffer (elegir cual)

### Navegación de Código (LSP + Treesitter)

#### 🎯 Ir a Definiciones (LSP)
- `gd` - **Go to Definition** - Ir a donde se define la función/clase/variable
- `gD` - **Go to Declaration** - Ir a la declaración (headers, interfaces)
- `gi` - **Go to Implementation** - Ir a la implementación concreta
- `gt` - **Go to Type Definition** - Ir a la definición del tipo

#### 🔍 Ver Referencias y Usos
- `gr` - **References** - Ver todos los usos del símbolo (lista nativa)
- `gR` - **References en Trouble** - Ver referencias con UI mejorada
- `K` - **Hover** - Ver documentación del símbolo bajo el cursor
- `gK` - **Signature Help** - Ver firma y parámetros de función

#### 📍 Navegación por Funciones/Clases (Treesitter)
- `]m` - Ir a **siguiente función** (function start)
- `[m` - Ir a **función anterior** (function start)
- `]M` - Ir a **fin de siguiente función** (function end)
- `[M` - Ir a **fin de función anterior** (function end)
- `]c` - Ir a **siguiente clase** (class start)
- `[c` - Ir a **clase anterior** (class start)
- `]C` - Ir a **fin de siguiente clase** (class end)
- `[C` - Ir a **fin de clase anterior** (class end)
- `]a` - Ir a **siguiente parámetro**
- `[a` - Ir a **parámetro anterior**

#### 🗂️ Symbol Outline (Aerial)
- `<leader>o` - **Toggle Outline** - Panel lateral con todos los símbolos del archivo
- `<leader>on` - **Next Symbol** - Saltar a siguiente símbolo (función/clase/método)
- `<leader>op` - **Previous Symbol** - Saltar a símbolo anterior
- **Dentro de Aerial:**
  - `Enter` - Saltar al símbolo seleccionado
  - `j/k` - Navegar por la lista
  - `za` - Plegar/desplegar secciones
  - `q` - Cerrar panel

#### 📦 Selección de Text Objects (Treesitter)
- **Funciones:**
  - `vif` - Seleccionar **dentro** de función (inner function)
  - `vaf` - Seleccionar función **completa** (around function)
- **Clases:**
  - `vic` - Seleccionar **dentro** de clase (inner class)
  - `vac` - Seleccionar clase **completa** (around class)
- **Parámetros/Argumentos:**
  - `via` - Seleccionar **dentro** de parámetro (inner argument)
  - `vaa` - Seleccionar parámetro **completo** (around argument)
- **Bloques:**
  - `vib` - Seleccionar **dentro** de bloque (inner block)
  - `vab` - Seleccionar bloque **completo** (around block)

#### 🔄 Swap de Parámetros (Treesitter)
- `<leader>sn` - **Swap Next** - Intercambiar parámetro con el siguiente
- `<leader>sp` - **Swap Previous** - Intercambiar parámetro con el anterior

#### 💡 Ejemplos de Uso

**Escenario 1: Explorar función desconocida**
```
1. Cursor sobre función → K (ver docs)
2. gd (ir a definición)
3. gr (ver todos los usos)
```

**Escenario 2: Navegar archivo grande**
```
1. <leader>o (abrir outline)
2. j/k para navegar lista
3. Enter para saltar
```

**Escenario 3: Refactorizar función**
```
1. ]m (ir a siguiente función)
2. vaf (seleccionar función completa)
3. <leader>re (extract function con refactoring.nvim)
```

**Escenario 4: Reordenar parámetros**
```
1. Cursor en primer parámetro
2. <leader>sn (mover a la derecha)
3. <leader>sp (mover a la izquierda)
```

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

#### 🚀 LazyGit
- `<leader>gg` - **Abrir LazyGit** - Interfaz TUI completa para git

#### 📊 Git Diff (Diffview)
- `<leader>gd` - **Open Diff View** - Ver todos los cambios en vista completa
- `<leader>gD` - **Close Diff View** - Cerrar vista de diff
- `<leader>gh` - **File History (all)** - Historia de commits de todo el repo
- `<leader>gH` - **File History (current)** - Historia del archivo actual
- `<leader>gm` - **Merge Conflicts** - Resolver conflictos con 3-way diff
- **Dentro de Diffview:**
  - `[x` / `]x` - Navegar conflictos (anterior/siguiente)
  - `<leader>co` - **Choose Ours** - Elegir cambios nuestros
  - `<leader>ct` - **Choose Theirs** - Elegir cambios de ellos
  - `<leader>cb` - **Choose Base** - Elegir versión base
  - `<leader>ca` - **Choose All** - Elegir todos los cambios
  - `-` - Stage/unstage archivo desde diff

#### 🔍 Hunks (Gitsigns)
- `]c` / `[c` - **Navegar hunks** - Siguiente/anterior cambio de git
- `<leader>hs` - **Stage hunk** - Añadir hunk al stage
- `<leader>hr` - **Reset hunk** - Deshacer cambios del hunk
- `<leader>hp` - **Preview hunk** - Vista previa del hunk
- `<leader>hb` - **Blame línea** - Ver quién modificó la línea
- `<leader>tb` - **Toggle blame inline** - Mostrar/ocultar blame en línea
- `<leader>hd` - **Diff** - Diff contra index

### Diagnósticos y Debugging

#### 🐛 Diagnósticos (Errores/Warnings)
- `<leader>xe` - **Examine diagnostic** - Ver diagnóstico flotante en línea actual
- `gl` - Ver diagnóstico en línea (alias de xe)
- `[d` / `]d` - **Navegar** diagnósticos (siguiente/anterior)
- `[e` / `]e` - **Navegar errores** (solo errores, ignora warnings)
- `<leader>xx` - **Toggle Trouble** - Panel con todos los diagnósticos
- `<leader>xw` - **Workspace diagnostics** - Diagnósticos de todo el workspace
- `<leader>xd` - **Document diagnostics** - Diagnósticos del archivo actual
- `<leader>xq` - **Quickfix list** - Lista de quickfix
- `<leader>xl` - **Location list** - Lista de ubicaciones
- `<leader>xr` - **LSP References** - Ver referencias en Trouble

#### 🔧 Debugging (DAP)
- `<leader>db` - **Toggle Breakpoint** - Añadir/quitar breakpoint
- `<leader>dc` - **Continue/Start** - Continuar o iniciar debugging
- `<leader>di` - **Step Into** - Entrar en función
- `<leader>do` - **Step Over** - Pasar por encima
- `<leader>dO` - **Step Out** - Salir de función
- `<leader>du` - **Toggle DAP UI** - Mostrar/ocultar interfaz de debugging
- `<leader>dt` - **Terminate** - Terminar sesión de debug
- `<leader>dr` - **Toggle REPL** - Abrir/cerrar REPL de debugging

#### 🧪 Testing (Neotest)
- `<leader>tt` - **Run Test** - Ejecutar test más cercano
- `<leader>tf` - **Run File** - Ejecutar todos los tests del archivo
- `<leader>ts` - **Toggle Summary** - Mostrar/ocultar resumen de tests
- `<leader>to` - **Show Output** - Ver output del test
- `<leader>tw` - **Toggle Watch** - Modo watch (re-ejecutar al guardar)
- `<leader>td` - **Debug Test** - Debuggear test con DAP

#### 🔄 Code Actions y Refactoring
- `<leader>ca` - **Code Action** - Menú de acciones de código (normal y visual)
- `<leader>rn` - **Rename Symbol** - Renombrar símbolo (LSP)
- `<leader>f` - **Format** - Formatear archivo con LSP
- **Refactoring (visual mode):**
  - `<leader>re` - **Extract Function** - Extraer función de código seleccionado
  - `<leader>rv` - **Extract Variable** - Extraer variable
  - `<leader>ri` - **Inline Variable** - Inline variable (normal/visual)
  - `<leader>rs` - **Select Refactor** - Selector de refactorings con Telescope
- **Debug Helpers:**
  - `<leader>rd` - **Print Variable** - Añadir print statement para debugging
  - `<leader>rc` - **Cleanup Prints** - Limpiar prints de debugging

#### 📝 Generación de Documentación (Neogen)
- `<leader>nf` - **Generate Function Docs** - Generar JSDoc/TSDoc para función
- `<leader>nc` - **Generate Class Docs** - Generar documentación para clase
- `<leader>nt` - **Generate Type Docs** - Generar documentación para tipo
- `<leader>ng` - **Auto Generate** - Auto-detectar y generar documentación

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

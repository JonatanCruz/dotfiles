# Configuración de Neovim

Configuración modular de Neovim usando Lua y lazy.nvim como gestor de plugins.

## Estructura del Proyecto

```
nvim/
└── .config/nvim/
    ├── init.lua                    # Punto de entrada principal
    ├── lazy-lock.json              # Versiones bloqueadas de plugins
    ├── lua/
    │   ├── config/                 # Configuración base
    │   │   ├── globals.lua         # Variables globales
    │   │   ├── options.lua         # Opciones de Neovim
    │   │   ├── keymaps.lua         # Atajos de teclado globales
    │   │   ├── autocmds.lua        # Autocomandos
    │   │   ├── lazy.lua            # Configuración de lazy.nvim
    │   │   └── lsp_servers.lua     # Lista de servidores LSP
    │   └── plugins/                # Plugins organizados por categoría
    │       ├── colorscheme.lua     # Tema Catppuccin Mocha
    │       ├── completion.lua      # Autocompletado (nvim-cmp + Supermaven AI)
    │       ├── editing.lua         # Herramientas de edición
    │       ├── git.lua             # Gitsigns + LazyGit
    │       ├── linting.lua         # Linting con nvim-lint
    │       ├── lsp.lua             # Configuración LSP + Trouble
    │       ├── telescope.lua       # Búsqueda difusa
    │       └── ui.lua              # Interfaz (lualine, nvim-tree, which-key)
    └── README.md                   # Este archivo
```

## Características Principales

### 🎨 Interfaz
- **Tema:** Catppuccin Mocha con fondo transparente
- **Statusline:** lualine.nvim - Barra de estado elegante
- **Bufferline:** bufferline.nvim - Pestañas de buffers en la parte superior con integración Catppuccin
- **Explorador de archivos:** nvim-tree - Navegación con `l` (abrir) y `h` (cerrar), auto-apertura con `nvim .`
- **Pantalla de inicio:** alpha-nvim - Dashboard con ASCII art y accesos rápidos
- **Notificaciones:** nvim-notify - Notificaciones modernas y elegantes
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

1. Crea un archivo en `lua/plugins/` o edita uno existente:
   ```lua
   return {
     {
       'autor/nombre-plugin',
       event = 'VeryLazy',  -- Carga diferida
       config = function()
         -- Tu configuración aquí
       end,
     }
   }
   ```

2. Guarda el archivo - lazy.nvim detectará el cambio automáticamente

### Añadir un Nuevo LSP

1. Edita `lua/config/lsp_servers.lua`
2. Descomenta o añade el servidor que necesites
3. Reinicia Neovim - Mason lo instalará automáticamente

### Modificar Opciones

Edita `lua/config/options.lua` para cambiar comportamientos del editor.

### Añadir Keymaps

- **Keymaps globales:** `lua/config/keymaps.lua`
- **Keymaps de plugin:** En el archivo del plugin correspondiente en `lua/plugins/`

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

### Git
- [Gitsigns](https://github.com/lewis6991/gitsigns.nvim)
- [LazyGit](https://github.com/kdheepak/lazygit.nvim)

### Completion & Snippets
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
- [friendly-snippets](https://github.com/rafamadriz/friendly-snippets)

### AI & Linting
- [Supermaven](https://github.com/supermaven-inc/supermaven-nvim) - Autocompletado AI gratuito
- [nvim-lint](https://github.com/mfussenegger/nvim-lint) - Linting asíncrono

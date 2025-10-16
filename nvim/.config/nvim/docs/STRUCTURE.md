# Estructura del Proyecto Neovim

## 📖 Resumen

Esta configuración está organizada para ser escalable, mantenible y fácil de extender.

## 🏗️ Arquitectura

### Principios de Organización

1. **Separación de Conceptos** - Cada plugin en su propio archivo
2. **Utilidades Compartidas** - Iconos, colores y helpers reutilizables
3. **Constantes Centralizadas** - Configuraciones compartidas en un solo lugar
4. **Categorización Clara** - Plugins organizados por funcionalidad

### Flujo de Carga

```
init.lua
  ↓
config/lazy.lua
  ↓ (carga configuración base)
  ├→ config/globals.lua
  ├→ config/options.lua
  ├→ config/keymaps.lua
  └→ config/autocmds.lua
  ↓ (inicializa lazy.nvim)
  └→ plugins/** (carga todos los plugins)
```

## 📂 Estructura Detallada

```
nvim/.config/nvim/
├── init.lua                    # Punto de entrada (7 líneas)
│
├── lua/
│   ├── config/                # Configuración base de Neovim
│   │   ├── autocmds.lua       # Autocomandos
│   │   ├── constants.lua      # ⭐ Constantes compartidas
│   │   ├── globals.lua        # Variables globales
│   │   ├── keymaps.lua        # Keymaps globales
│   │   ├── lazy.lua           # Configuración de lazy.nvim
│   │   ├── lsp_servers.lua    # Lista de servidores LSP
│   │   └── options.lua        # Opciones de Neovim
│   │
│   ├── utils/                 # ⭐ Utilidades reutilizables
│   │   ├── init.lua           # Helpers generales
│   │   ├── icons.lua          # Iconos Nerd Font centralizados
│   │   └── colors.lua         # Paleta Catppuccin y helpers
│   │
│   └── plugins/               # Plugins organizados por categoría
│       │
│       ├── colorscheme.lua    # Tema principal
│       │
│       ├── ui/                # ⭐ Interfaz de usuario (10 archivos)
│       │   ├── statusline.lua # Lualine
│       │   ├── bufferline.lua # Bufferline
│       │   ├── tree.lua       # Nvim-tree
│       │   ├── whichkey.lua   # Which-key
│       │   ├── alpha.lua      # Dashboard
│       │   ├── notify.lua     # Notificaciones
│       │   ├── indent.lua     # Guías de indentación
│       │   ├── colorizer.lua  # Preview de colores
│       │   ├── dressing.lua   # UI mejorada
│       │   └── todo.lua       # TODOs destacados
│       │
│       ├── editor/            # ⭐ Edición y formateo (4 archivos)
│       │   ├── formatting.lua # Conform (formateo)
│       │   ├── treesitter.lua # Treesitter
│       │   ├── autopairs.lua  # Autopairs
│       │   └── comments.lua   # Comment.nvim
│       │
│       ├── coding/            # ⭐ Autocompletado (2 archivos)
│       │   ├── cmp.lua        # Nvim-cmp
│       │   └── ai.lua         # Supermaven AI
│       │
│       ├── lsp/               # LSP y diagnósticos
│       │   ├── lspconfig.lua  # (pendiente separar)
│       │   ├── trouble.lua    # (pendiente separar)
│       │   └── linting.lua    # Nvim-lint
│       │
│       ├── git/               # Herramientas Git
│       │   ├── gitsigns.lua   # (pendiente separar)
│       │   └── lazygit.lua    # (pendiente separar)
│       │
│       └── tools/             # Herramientas generales
│           └── telescope.lua  # Telescope
│
├── docs/                      # ⭐ Documentación
│   ├── CONTRIBUTING.md        # Guía para agregar plugins
│   └── STRUCTURE.md           # Este archivo
│
└── README.md                  # Documentación principal
```

## ⭐ Características Clave

### 1. Archivos Pequeños y Enfocados

- **Antes**: `ui.lua` tenía 376 líneas con 10 plugins
- **Ahora**: Cada plugin en su propio archivo (~20-80 líneas)

### 2. Reutilización de Código

**utils/icons.lua** - 130+ iconos organizados por categoría
```lua
local icons = require("utils.icons")
icon = icons.diagnostics.error
```

**utils/colors.lua** - Paleta Catppuccin + helpers
```lua
local colors = require("utils.colors")
fg = colors.primary
```

**config/constants.lua** - Configuraciones compartidas
```lua
local constants = require("config.constants")
border = constants.borders.style
```

### 3. Documentación Inline

Cada archivo de plugin incluye:
- Encabezado descriptivo
- URL de documentación oficial
- Comandos útiles
- Explicación de configuración personalizada

### 4. Lazy Loading Inteligente

Cada plugin usa el evento apropiado:
- `cmd` - Solo al ejecutar comando
- `keys` - Solo al presionar tecla
- `event` - En eventos específicos
- `dependencies` - Gestión de dependencias

## 🔄 Migración Realizada

### Archivos Creados

- ✅ 3 archivos de utilidades (`utils/`)
- ✅ 1 archivo de constantes (`config/constants.lua`)
- ✅ 10 archivos UI (`plugins/ui/`)
- ✅ 4 archivos de edición (`plugins/editor/`)
- ✅ 2 archivos de coding (`plugins/coding/`)
- ✅ 2 archivos de documentación (`docs/`)

**Total**: 22 archivos nuevos organizados

### Beneficios

1. **Mantenibilidad** - Fácil encontrar y modificar plugins
2. **Escalabilidad** - Agregar nuevos plugins sin saturar archivos
3. **Reutilización** - Constantes y utilidades compartidas
4. **Documentación** - Cada archivo auto-documentado
5. **Rendimiento** - Lazy loading optimizado

## 📚 Próximos Pasos

Para completar la migración:

1. Separar `lsp.lua` en `lspconfig.lua` y `trouble.lua`
2. Separar `git.lua` en archivos individuales
3. Eliminar archivos antiguos (`ui.lua`, `editing.lua`, `completion.lua`)
4. Probar que todo funcione correctamente

## 🎯 Guías de Uso

- Ver `docs/CONTRIBUTING.md` para agregar nuevos plugins
- Ver `README.md` para documentación general
- Ver archivos individuales para ejemplos de configuración

# Neovim Plugins Avanzados - Guía Completa

Guía detallada para agregar, configurar y extender plugins en Neovim con lazy.nvim y arquitectura modular.

## Índice

- [Arquitectura de Plugins](#arquitectura-de-plugins)
- [Agregar un Nuevo Plugin](#agregar-un-nuevo-plugin)
- [Configuración Avanzada](#configuración-avanzada)
- [Lazy Loading Strategies](#lazy-loading-strategies)
- [Utilidades Compartidas](#utilidades-compartidas)
- [LSP y Servidores](#lsp-y-servidores)
- [Debugging y Troubleshooting](#debugging-y-troubleshooting)

## Arquitectura de Plugins

### Estructura Modular

La configuración de Neovim está organizada en una estructura escalable:

```
lua/plugins/
├── colorscheme.lua       # Tema principal
├── ui/                   # 11 plugins de interfaz
│   ├── statusline.lua
│   ├── bufferline.lua
│   ├── tree.lua
│   └── ...
├── editor/               # 4 plugins de edición
│   ├── formatting.lua
│   ├── treesitter.lua
│   └── ...
├── coding/               # 2 plugins de autocompletado
│   ├── cmp.lua
│   └── ai.lua
├── lsp.lua               # LSP core
├── lsp/                  # Herramientas LSP adicionales
│   └── linting.lua
├── git/                  # Herramientas Git
│   ├── gitsigns.lua
│   └── lazygit.lua
└── tools/                # Herramientas generales
    └── telescope.lua
```

**Ventajas de esta estructura:**
- **Archivos pequeños**: 20-80 líneas por archivo vs monolitos de 376+ líneas
- **Lazy loading granular**: Optimización por plugin individual
- **Mantenibilidad**: Fácil localizar y modificar plugins específicos
- **Escalabilidad**: Agregar plugins sin tocar otros

### Sistema de Utilidades

Utilidades compartidas centralizadas en `lua/utils/`:

| Archivo | Propósito | Uso Principal |
|---------|-----------|---------------|
| **init.lua** | Helpers generales | map(), autocmd(), notify() |
| **icons.lua** | 130+ iconos Nerd Font | Iconos organizados por categoría |
| **colors.lua** | Paleta Catppuccin | Colores + helpers (hex_to_rgb) |
| **transparency.lua** | Sistema de transparencia | 60+ highlight groups transparentes |

### Constantes Compartidas

`lua/config/constants.lua` centraliza configuraciones:

```lua
local constants = require("config.constants")

-- Usar en cualquier plugin
border = constants.borders.style              -- "rounded"
width = constants.ui.sidebar_width            -- 30
signs = constants.lsp.signs                   -- Signos de diagnóstico
langs = constants.treesitter.ensure_installed -- Lista de lenguajes
```

## Agregar un Nuevo Plugin

### Proceso Básico

**1. Elegir Categoría Apropiada**

| Categoría | Ubicación | Para plugins de... |
|-----------|-----------|-------------------|
| **UI** | `plugins/ui/` | Statusline, dashboard, notificaciones |
| **Editor** | `plugins/editor/` | Formateo, comentarios, autopairs |
| **Coding** | `plugins/coding/` | Autocompletado, snippets, AI |
| **LSP** | `plugins/lsp/` | LSP, linting, diagnósticos |
| **Git** | `plugins/git/` | Gitsigns, LazyGit, fugitive |
| **Tools** | `plugins/tools/` | Telescope, terminal, debugger |

**2. Crear Archivo del Plugin**

```bash
# Ejemplo: Agregar plugin de terminal
touch lua/plugins/tools/terminal.lua
```

**3. Estructura del Archivo**

```lua
-- ============================================================================
-- [Nombre] - [Descripción breve en una línea]
-- ============================================================================
-- [Descripción detallada de funcionalidad y propósito]
-- Documentación: [URL del repositorio en GitHub]
-- ============================================================================

-- Importar utilidades compartidas
local icons = require("utils.icons")
local colors = require("utils.colors")
local constants = require("config.constants")
local utils = require("utils")

return {
  -- Especificación del plugin
  "autor/nombre-plugin",

  -- Lazy loading (ver sección siguiente)
  event = "VeryLazy",

  -- Keybindings específicos del plugin
  keys = {
    { "<leader>x", "<cmd>Comando<cr>", desc = "Descripción para Which-key" },
  },

  -- Dependencias (si las hay)
  dependencies = {
    "otro/plugin-requerido",
  },

  -- Configuración
  opts = {
    -- Usar utilidades compartidas
    icon = icons.ui.search,
    color = colors.primary,
    border = constants.borders.style,
  },

  -- Configuración avanzada (si opts no es suficiente)
  config = function()
    local plugin = require("plugin-name")

    plugin.setup({
      -- Configuración compleja aquí
    })

    -- Keymaps adicionales con helper
    utils.map("n", "<leader>y", ":Comando<cr>", { desc = "Descripción" })
  end,
}
```

**4. Guardar y Detectar**

- Lazy.nvim detecta el cambio automáticamente
- Abre Neovim → el plugin se instalará
- O ejecuta `:Lazy sync` manualmente

**5. Registrar en Which-key (si usa `<leader>`)**

Editar `plugins/ui/whichkey.lua`:

```lua
-- Agregar a la sección correspondiente
{ "<leader>x", group = "Nombre Descriptivo", icon = icons.whichkey.categoria },
```

### Ejemplo Completo: Terminal Flotante

```lua
-- ============================================================================
-- ToggleTerm - Terminal flotante integrado
-- ============================================================================
-- Terminal flotante con soporte para múltiples terminales y LazyGit.
-- Documentación: https://github.com/akinsho/toggleterm.nvim
-- ============================================================================

local icons = require("utils.icons")
local colors = require("utils.colors")
local constants = require("config.constants")

return {
  "akinsho/toggleterm.nvim",
  version = "*",
  event = "VeryLazy",

  keys = {
    { "<leader>tt", "<cmd>ToggleTerm direction=float<cr>", desc = "Terminal flotante" },
    { "<C-\\>", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal horizontal" },
  },

  opts = {
    -- Usar constantes compartidas
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.4
      end
    end,

    -- Configuración de ventana flotante
    float_opts = {
      border = constants.borders.style,
      winblend = 3,
    },

    -- Usar colores de Catppuccin
    highlights = {
      Normal = { link = "Normal" },
      NormalFloat = { link = "NormalFloat" },
      FloatBorder = {
        fg = colors.catppuccin.blue,
      },
    },

    -- Keymaps en modo terminal
    on_open = function(term)
      vim.api.nvim_buf_set_keymap(
        term.bufnr,
        "t",
        "<Esc>",
        "<C-\\><C-n>",
        { noremap = true, silent = true }
      )
    end,
  },
}
```

**Registrar en Which-key:**

```lua
-- En plugins/ui/whichkey.lua
{ "<leader>t", group = "Terminal", icon = icons.whichkey.terminal },
```

## Configuración Avanzada

### Opciones vs Config Function

**`opts` - Para configuración simple:**

```lua
return {
  "plugin/name",
  opts = {
    enable = true,
    border = "rounded",
  },
}
```

Lazy.nvim llama automáticamente a `require("plugin").setup(opts)`.

**`config` - Para configuración compleja:**

```lua
return {
  "plugin/name",
  config = function()
    local plugin = require("plugin")

    -- Configuración programática
    plugin.setup({
      enable = vim.fn.has("nvim-0.10") == 1,
      callback = function()
        -- Lógica compleja
      end,
    })

    -- Keymaps adicionales
    vim.keymap.set("n", "<leader>x", ":Comando<cr>")

    -- Autocomandos
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "*.lua",
      callback = function()
        -- Lógica custom
      end,
    })
  end,
}
```

### Dependencies (Dependencias)

**Dependencias automáticas:**

```lua
return {
  "plugin-principal",
  dependencies = {
    "dependencia-1",
    "dependencia-2",
    {
      "dependencia-3",
      -- Configuración específica de esta dependencia
      config = function()
        require("dependencia-3").setup({})
      end,
    },
  },
}
```

**Orden de carga:**
1. Lazy.nvim carga dependencias primero
2. Luego carga el plugin principal
3. Garantiza que todo esté disponible

### Init Function (Ejecución Temprana)

```lua
return {
  "plugin/name",
  init = function()
    -- Se ejecuta ANTES de cargar el plugin
    -- Útil para configurar variables globales
    vim.g.plugin_setting = true
  end,
  config = function()
    -- Se ejecuta DESPUÉS de cargar el plugin
    require("plugin").setup({})
  end,
}
```

## Lazy Loading Strategies

### Estrategias de Carga

| Estrategia | Cuándo usar | Ejemplo |
|------------|-------------|---------|
| **event** | Cargar en eventos | `VeryLazy`, `BufEnter`, `InsertEnter` |
| **cmd** | Cargar al ejecutar comando | `:Telescope`, `:Mason` |
| **keys** | Cargar al presionar atajo | `<leader>ff` |
| **ft** | Cargar por filetype | `lua`, `python`, `javascript` |
| **lazy = false** | Cargar inmediatamente | Temas, plugins críticos |

### Event Loading

```lua
return {
  "plugin/name",

  -- Cargar muy tarde en el startup
  event = "VeryLazy",

  -- Cargar al entrar a un buffer
  event = "BufEnter",

  -- Cargar al entrar a Insert mode
  event = "InsertEnter",

  -- Cargar en múltiples eventos
  event = { "BufReadPost", "BufNewFile" },
}
```

**Eventos comunes:**
- `VeryLazy` - Después de que todo lo esencial ha cargado
- `BufEnter` - Al entrar a cualquier buffer
- `BufReadPost` - Después de leer un archivo
- `InsertEnter` - Al entrar a modo Insert
- `UIEnter` - Cuando la UI está lista

### Command Loading

```lua
return {
  "plugin/name",
  cmd = "ComandoPlugin",
  -- O múltiples comandos
  cmd = { "Comando1", "Comando2" },
}
```

Lazy.nvim crea comandos "lazy" que cargan el plugin al ejecutarse.

### Keymap Loading

```lua
return {
  "plugin/name",
  keys = {
    { "<leader>x", "<cmd>Comando<cr>", desc = "Descripción" },
    { "<leader>y", function() require("plugin").action() end, desc = "Otra acción" },
    -- Con modo específico
    { "<C-s>", "<cmd>Save<cr>", mode = "i", desc = "Guardar en Insert" },
  },
}
```

### Filetype Loading

```lua
return {
  "plugin/python-specific",
  ft = "python",
  -- O múltiples filetypes
  ft = { "python", "lua", "javascript" },
}
```

### Priority (Prioridad)

```lua
return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,      -- Cargar inmediatamente
  priority = 1000,   -- Antes que otros plugins
  config = function()
    vim.cmd.colorscheme("catppuccin-mocha")
  end,
}
```

**Niveles de prioridad:**
- `1000` - Temas (deben cargar primero)
- `500-999` - Plugins core (LSP, Treesitter)
- `<500` - Plugins normales (default: 50)

## Utilidades Compartidas

### Iconos (utils/icons.lua)

130+ iconos organizados por categoría:

```lua
local icons = require("utils.icons")

-- Diagnósticos
icons.diagnostics.error     --
icons.diagnostics.warn      --
icons.diagnostics.hint      -- 󰌵
icons.diagnostics.info      --

-- Git
icons.git.branch            --
icons.git.added             --
icons.git.modified          --
icons.git.removed           --

-- UI
icons.ui.search             -- 󰍉
icons.ui.close              -- 󰅖
icons.ui.folder             -- 󰉋
icons.ui.file               -- 󰈙

-- LSP Kinds
icons.kind.Function         -- 󰊕
icons.kind.Variable         -- 󰀫
icons.kind.Class            -- 󰠱
icons.kind.Method           -- 󰆧

-- Which-key
icons.whichkey.telescope    -- 󰭎
icons.whichkey.git          --
icons.whichkey.lsp          --

-- TODOs
icons.todo.TODO             --
icons.todo.FIX              --
icons.todo.HACK             --
```

### Colores (utils/colors.lua)

Paleta Catppuccin Mocha completa + helpers:

```lua
local colors = require("utils.colors")

-- Paleta completa Catppuccin Mocha
colors.catppuccin.blue      -- #89b4fa
colors.catppuccin.pink      -- #f5c2e7
colors.catppuccin.mauve     -- #cba6f7
colors.catppuccin.green     -- #a6e3a1
colors.catppuccin.red       -- #f38ba8

-- Alias comunes
colors.primary              -- Azul (#89b4fa)
colors.secondary            -- Rosa (#f5c2e7)
colors.bg                   -- Fondo (#1e1e2e)
colors.fg                   -- Texto (#cdd6f4)

-- Alias de diagnóstico
colors.diagnostic.error     -- Rojo
colors.diagnostic.warn      -- Amarillo
colors.diagnostic.info      -- Azul
colors.diagnostic.hint      -- Verde

-- Helpers de color
colors.hex_to_rgb("#89b4fa")              -- {r=137, g=180, b=250}
colors.with_alpha("#89b4fa", 0.5)         -- "rgba(137, 180, 250, 0.50)"
colors.blend("#89b4fa", "#f5c2e7", 0.5)   -- Color mezclado (blend)
```

### Transparencia (utils/transparency.lua)

Sistema centralizado para 60+ highlight groups:

```lua
local transparency = require("utils.transparency")

-- Aplicar transparencia a todos los grupos predefinidos
transparency.apply_transparency()

-- Configurar un grupo específico como transparente
transparency.set_transparent("MiPlugin", { fg = "#89b4fa" })

-- Link transparente
transparency.link_transparent("NuevoGrupo", "Normal")

-- Autocomando para persistir transparencia
transparency.setup_autocmd()
```

**Grupos transparentes incluidos:**
- Normal, NormalFloat, SignColumn
- Nvim-tree (sidebar completo)
- Telescope (prompts y results)
- Which-key (ventana flotante)
- Alpha (dashboard)
- nvim-cmp (menú y documentación)
- Trouble, Lazy, Mason
- Pmenu, borders, statusline

### Helpers Generales (utils/init.lua)

```lua
local utils = require("utils")

-- Keymaps con helper
utils.map("n", "<leader>x", ":Comando<cr>", { desc = "Descripción" })
utils.buf_map(bufnr, "n", "K", vim.lsp.buf.hover, "Hover docs")

-- Autocomandos
utils.autocmd("BufEnter", {
  pattern = "*.lua",
  callback = function()
    -- Lógica custom
  end,
})

utils.augroup("MiGrupo", { clear = true })

-- Utilidades
utils.notify("Mensaje", "info")                  -- Notificación
utils.safe_require("modulo")                     -- Require seguro
utils.has_plugin("telescope.nvim")               -- Verificar plugin
utils.executable_exists("rg")                    -- Verificar ejecutable
```

## LSP y Servidores

### Agregar un LSP Server

**1. Editar lista de servidores**

`lua/config/lsp_servers.lua`:

```lua
return {
  -- Frontend
  "html",
  "cssls",
  "tailwindcss",
  "tsserver",
  "emmet_ls",

  -- Backend
  "lua_ls",
  "pyright",      -- ← Agregar nuevo servidor aquí
  "rust_analyzer",

  -- Otros
  "jsonls",
  "yamlls",
}
```

**2. Reiniciar Neovim**

Mason instalará el servidor automáticamente.

**3. Verificar instalación**

```vim
:LspInfo    " Ver servidores activos
:Mason      " Ver servidores instalados
```

### Configuración LSP Personalizada

Para configuración avanzada de un LSP específico, editar `lua/plugins/lsp.lua`:

```lua
-- En la sección lspconfig.setup
local servers = require("config.lsp_servers")

for _, server in ipairs(servers) do
  local opts = {
    on_attach = on_attach,
    capabilities = capabilities,
  }

  -- Configuración personalizada para servidor específico
  if server == "lua_ls" then
    opts.settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
      },
    }
  elseif server == "tsserver" then
    opts.settings = {
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = "all",
        },
      },
    }
  end

  lspconfig[server].setup(opts)
end
```

### Agregar Formatters (Conform)

Editar `lua/plugins/editor/formatting.lua`:

```lua
opts = {
  formatters_by_ft = {
    -- Lenguajes existentes
    lua = { "stylua" },
    python = { "isort", "black" },
    javascript = { { "prettierd", "prettier" } },

    -- Agregar nuevo lenguaje
    rust = { "rustfmt" },
    go = { "goimports", "gofmt" },
  },
}
```

Instalar el formatter:

```bash
# Formatters de Mason
:Mason

# O instalar manualmente
cargo install rustfmt        # Rust
go install golang.org/x/tools/cmd/goimports@latest  # Go
```

### Agregar Linters (nvim-lint)

Editar `lua/plugins/lsp/linting.lua`:

```lua
local lint = require("lint")

lint.linters_by_ft = {
  -- Linters existentes
  javascript = { "eslint" },
  python = { "pylint" },
  lua = { "luacheck" },

  -- Agregar nuevo linter
  rust = { "clippy" },
  go = { "golangcilint" },
}
```

Instalar el linter:

```bash
# JavaScript/TypeScript
npm install -g eslint

# Python
pip install pylint

# Rust (viene con cargo)
rustup component add clippy

# Go
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

## Debugging y Troubleshooting

### Ver Rendimiento de Plugins

```vim
:Lazy profile
```

Muestra tiempo de carga de cada plugin. Identifica plugins lentos.

### Ver Configuración de un Plugin

```vim
:Lazy
```

- Buscar plugin (tecla `/`)
- Presionar `Enter` para ver detalles
- Ver keymaps, comandos, carga

### Logs de Lazy.nvim

```vim
:Lazy log
```

Ver eventos de instalación, actualización y errores.

### Recargar Plugin Sin Reiniciar

```vim
:Lazy reload nombre-plugin
```

Útil para desarrollo de plugins.

### Verificar Health de Plugin

```vim
:checkhealth nombre-plugin
```

Diagnóstico específico si el plugin lo soporta.

### Plugin No Se Carga

**Verificaciones:**

1. **Sintaxis del archivo:**
```bash
# Verificar errores de sintaxis
nvim --headless -c "luafile lua/plugins/categoria/mi-plugin.lua" -c "q"
```

2. **Lazy loading configurado correctamente:**
```vim
:Lazy
# Buscar el plugin y ver por qué no se cargó
```

3. **Dependencias instaladas:**
```vim
:Lazy
# Ver si dependencias están instaladas
```

4. **Conflictos de keymaps:**
```vim
:verbose map <leader>x
# Ver si el keymap está siendo sobrescrito
```

### LSP No Funciona

**Diagnóstico:**

```vim
:LspInfo              " Ver si el servidor está corriendo
:Mason                " Verificar instalación del servidor
:checkhealth lspconfig " Diagnóstico completo
```

**Soluciones comunes:**

```vim
:LspRestart           " Reiniciar servidor LSP
:Mason                " Reinstalar servidor si está corrupto
```

**Verificar logs:**

```vim
:lua vim.cmd('e ' .. vim.lsp.get_log_path())
```

### Limpiar y Reinstalar Todo

```bash
# Eliminar cache y datos
rm -rf ~/.local/share/nvim
rm -rf ~/.cache/nvim

# Reiniciar Neovim
nvim  # Todo se reinstalará automáticamente
```

## Recursos Adicionales

- [Lazy.nvim Documentation](https://github.com/folke/lazy.nvim)
- [Neovim LSP Configuration](https://github.com/neovim/nvim-lspconfig)
- [Mason Registry](https://mason-registry.dev/registry/list)
- [Awesome Neovim Plugins](https://github.com/rockerBOO/awesome-neovim)
- [Catppuccin Integrations](https://github.com/catppuccin/nvim#integrations)

## Referencias

- [Configuración Principal](../services/nvim.md)
- [Workflows de Desarrollo](../guides/workflows.md)
- [Integración de Herramientas](../advanced/integration.md)

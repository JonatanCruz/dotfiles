# Guía para Contribuir y Agregar Plugins

Esta guía explica cómo mantener y extender la configuración de Neovim de forma escalable.

## 📁 Estructura del Proyecto

```
nvim/.config/nvim/
├── init.lua                  # Punto de entrada
├── lua/
│   ├── config/              # Configuración base
│   │   ├── constants.lua    # Constantes compartidas
│   │   ├── lsp_servers.lua  # Lista de servidores LSP
│   │   ├── options.lua      # Opciones de Neovim
│   │   ├── keymaps.lua      # Keymaps globales
│   │   ├── autocmds.lua     # Autocomandos
│   │   └── lazy.lua         # Configuración de lazy.nvim
│   │
│   ├── utils/              # Utilidades reutilizables
│   │   ├── init.lua        # Helpers generales
│   │   ├── icons.lua       # Iconos centralizados
│   │   └── colors.lua      # Helpers de colores
│   │
│   └── plugins/            # Plugins organizados por categoría
│       ├── colorscheme.lua
│       ├── ui/            # Interfaz de usuario
│       ├── editor/        # Edición y formateo
│       ├── coding/        # Autocompletado
│       ├── lsp/           # LSP y diagnósticos
│       ├── git/           # Herramientas Git
│       └── tools/         # Herramientas generales
```

## ➕ Agregar un Nuevo Plugin

### 1. Decidir la Categoría

Coloca el plugin en la categoría apropiada:

- **ui/** - Interfaz (statusline, bufferline, notificaciones)
- **editor/** - Edición (formateo, comentarios, autopairs)
- **coding/** - Autocompletado y snippets
- **lsp/** - LSP, diagnósticos, linting
- **git/** - Herramientas Git
- **tools/** - Telescope, terminal, etc.

### 2. Crear el Archivo del Plugin

Crea un archivo en la carpeta correspondiente con este formato:

```lua
-- ============================================================================
-- [Nombre] - [Descripción breve]
-- ============================================================================
-- [Descripción detallada de 1-2 líneas]
-- Documentación: [URL del repositorio]
--
-- Comandos útiles (opcional):
-- :ComandoX - Descripción
-- ============================================================================

local icons = require("utils.icons")  -- Si necesitas iconos
local colors = require("utils.colors")  -- Si necesitas colores
local constants = require("config.constants")  -- Si necesitas constantes

return {
  "autor/nombre-plugin",
  event = "VeryLazy",  -- o el evento apropiado
  dependencies = { "otros-plugins" },
  keys = {
    { "<leader>x", "<cmd>Comando<cr>", desc = "Descripción" },
  },
  opts = {
    -- Configuración básica
  },
  config = function(_, opts)
    -- Configuración avanzada si es necesaria
    require("plugin").setup(opts)
  end,
}
```

### 3. Usar Utilidades Compartidas

#### Iconos

```lua
local icons = require("utils.icons")

-- Usar iconos predefinidos
icon = icons.diagnostics.error
icon = icons.git.branch
icon = icons.ui.search
```

#### Colores

```lua
local colors = require("utils.colors")

-- Usar colores de Catppuccin
fg = colors.primary  -- Azul
bg = colors.bg       -- Fondo
error_color = colors.diagnostic.error
```

#### Constantes

```lua
local constants = require("config.constants")

-- Usar configuraciones compartidas
border = constants.borders.style
timeout = constants.ui.timeout
```

### 4. Documentar el Plugin

Agrega comentarios claros:

- **Encabezado** con nombre y descripción
- **URL de documentación** oficial
- **Comandos útiles** si los hay
- **Configuración personalizada** explicada

### 5. Registrar Keymaps en Which-key

Si agregas keymaps con `<leader>`, agrégalos en `plugins/ui/whichkey.lua`:

```lua
wk.add({
  { "<leader>x", group = "Nombre del Grupo", icon = icons.whichkey.nombre },
})
```

## 🎨 Agregar Nuevos Iconos

Edita `lua/utils/icons.lua` y agrega a la sección apropiada:

```lua
M.mi_categoria = {
  icono_nuevo = "",
}
```

## 🎨 Agregar Nuevos Colores

Si necesitas colores personalizados, agrégalos a `lua/utils/colors.lua`:

```lua
M.mi_color = M.catppuccin.nombre_color
```

## ⚙️ Agregar Nuevas Constantes

Para valores compartidos, agrégalos a `lua/config/constants.lua`:

```lua
M.mi_config = {
  valor = 123,
}
```

## 🔧 Agregar LSP Server

1. Edita `lua/config/lsp_servers.lua`
2. Agrega el servidor a la lista:

```lua
return {
  -- ... otros servidores
  "nombre_servidor",
}
```

3. Reinicia Neovim - Mason lo instalará automáticamente

## 📝 Convenciones de Código

### Estilo

- **Indentación**: 2 espacios
- **Comillas**: Usar dobles `"` para strings
- **Tablas**: Coma final en el último elemento

### Nombres

- **Archivos**: Minúsculas con guiones: `mi-plugin.lua`
- **Variables locales**: snake_case: `mi_variable`
- **Constantes**: UPPER_CASE en constants.lua

### Comentarios

- Usa encabezados con `--` y líneas de `=`
- Documenta configuraciones no obvias
- Incluye enlaces a documentación oficial

### Lazy Loading

Usa el evento apropiado:

- `VeryLazy` - Comandos que deben estar disponibles pronto
- `BufReadPost` - Al leer un archivo
- `InsertEnter` - Al entrar a modo insert
- `cmd = { "Comando" }` - Solo al ejecutar el comando
- `keys = { ... }` - Solo al presionar la tecla

## 🧪 Probar Cambios

1. Guarda el archivo
2. Reinicia Neovim o ejecuta `:source %`
3. Ejecuta `:Lazy sync` si agregaste un nuevo plugin
4. Verifica que funcione correctamente
5. Revisa `:checkhealth` para problemas

## 🐛 Debugging

- `:Lazy` - Ver estado de plugins
- `:LspInfo` - Información de LSP
- `:checkhealth` - Diagnóstico general
- `:messages` - Ver mensajes de error

## 📚 Recursos

- [Lazy.nvim](https://github.com/folke/lazy.nvim)
- [Awesome Neovim](https://github.com/rockerBOO/awesome-neovim)
- [Catppuccin Colors](https://github.com/catppuccin/catppuccin#-palette)
- [Nerd Fonts](https://www.nerdfonts.com/cheat-sheet)

## ✅ Checklist para Agregar un Plugin

- [ ] Crear archivo en la categoría correcta
- [ ] Agregar encabezado con documentación
- [ ] Usar utils compartidas (icons, colors, constants)
- [ ] Configurar lazy loading apropiado
- [ ] Agregar keymaps con descripciones
- [ ] Registrar grupo en which-key si usa `<leader>`
- [ ] Probar que funcione correctamente
- [ ] Documentar configuración personalizada
- [ ] Actualizar README.md si es relevante

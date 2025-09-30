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
    │       ├── colorscheme.lua     # Tema Dracula
    │       ├── completion.lua      # Autocompletado (nvim-cmp)
    │       ├── editing.lua         # Herramientas de edición
    │       ├── lsp.lua             # Configuración LSP
    │       ├── telescope.lua       # Búsqueda difusa
    │       ├── tools.lua           # LazyGit
    │       └── ui.lua              # Interfaz (lualine, nvim-tree)
    └── README.md                   # Este archivo
```

## Características Principales

### 🎨 Interfaz
- **Tema:** Dracula con fondo transparente
- **Statusline:** lualine.nvim
- **Explorador de archivos:** nvim-tree
- **Notificaciones:** nvim-notify

### ⚡ Productividad
- **Búsqueda difusa:** Telescope
- **Git UI:** LazyGit
- **Autocompletado:** nvim-cmp con múltiples fuentes
- **Formateo automático:** conform.nvim

### 🔧 LSP y Análisis de Código
- **LSP Manager:** Mason + mason-lspconfig
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

### Otros
- `:checkhealth` - Diagnóstico del sistema
- `:Telescope` - Abrir selector de Telescope
- `:ConformInfo` - Ver configuración de formateo

## Atajos de Teclado Principales

### General
- `<Space>` - Leader key
- `<leader>w` - Guardar archivo
- `<leader>q` - Cerrar ventana
- `<leader>rr` - Recargar configuración

### Navegación
- `<C-h/j/k/l>` - Navegar entre splits
- `<S-h/l>` - Cambiar entre buffers
- `<leader>bd` - Cerrar buffer actual

### Búsqueda (Telescope)
- `<leader>ff` - Buscar archivos
- `<leader>fg` - Buscar texto en proyecto
- `<leader>fb` - Buscar en buffers
- `<leader>fh` - Buscar en ayuda

### Explorador de Archivos
- `<leader>e` - Toggle nvim-tree

### Git
- `<leader>gg` - Abrir LazyGit

### LSP
- `K` - Mostrar documentación
- `gd` - Ir a definición
- `gr` - Ver referencias
- `<leader>rn` - Renombrar símbolo
- `<leader>d` - Ver diagnóstico
- `[d` / `]d` - Navegar entre diagnósticos

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

- [Lazy.nvim](https://github.com/folke/lazy.nvim)
- [Mason](https://github.com/williamboman/mason.nvim)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- [Telescope](https://github.com/nvim-telescope/telescope.nvim)
- [Dracula Theme](https://github.com/Mofiqul/dracula.nvim)

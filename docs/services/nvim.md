![Neovim](https://img.shields.io/badge/neovim-editor-89b4fa?style=for-the-badge&logo=neovim&logoColor=cdd6f4&color=1e1e2e)
![lazy.nvim](https://img.shields.io/badge/lazy.nvim-plugin%20manager-cba6f7?style=for-the-badge&color=1e1e2e)
![Catppuccin](https://img.shields.io/badge/catppuccin-mocha-f5c2e7?style=for-the-badge&color=1e1e2e)

# Neovim - Editor de Código Modular

Configuración modular de Neovim con lazy.nvim, LSP completo, 60+ highlight groups transparentes y tema Catppuccin Mocha. El diseño prioriza la carga diferida (lazy loading) para tiempos de inicio mínimos y la separación de responsabilidades mediante plugins organizados por categoría.

---

## Arquitectura

```
nvim/.config/nvim/
├── init.lua                        # Punto de entrada: define leader y bootstrapea lazy.nvim
└── lua/
    ├── config/
    │   ├── lazy.lua                # Inicialización y carga de plugins
    │   ├── options.lua             # Opciones del editor (tabs, scroll, UI)
    │   ├── keymaps.lua             # Keymaps globales por prefijo
    │   ├── autocmds.lua            # Autocomandos y eventos
    │   └── lsp_servers.lua         # Lista de LSP servers para Mason
    │
    ├── utils/
    │   ├── init.lua                # Helpers generales
    │   ├── icons.lua               # Iconos centralizados
    │   └── colors.lua              # Paleta Catppuccin Mocha
    │
    └── plugins/
        ├── colorscheme.lua         # Catppuccin Mocha con transparencia
        ├── lsp.lua                 # Mason + nvim-lspconfig + Trouble
        ├── ui/                     # Interfaz: statusline, bufferline, tree, etc.
        ├── editor/                 # Edición: autopairs, comments, treesitter, formateo
        ├── coding/                 # Autocompletado: nvim-cmp, Supermaven AI
        ├── lsp/                    # LSP extras: diagnósticos, neodev
        ├── git/                    # Git: lazygit, diffview, gitsigns
        ├── debug/                  # DAP: nvim-dap, dap-ui, virtual text
        ├── test/                   # Testing: neotest (Jest + Vitest)
        └── tools/                  # Herramientas: Telescope, Aerial, refactoring, sesiones
```

**Orden de carga**: `init.lua` establece `<Space>` como leader, luego `lazy.lua` carga `config/` completo y descubre plugins en `plugins/` automáticamente.

---

## Instalación

```bash
# Aplicar la configuración con Stow (desde ~/dotfiles)
stow nvim

# La primera vez que abras Neovim:
# 1. lazy.nvim se descarga e instala automáticamente
# 2. Todos los plugins se instalan
# 3. Mason instala los LSP servers definidos en lsp_servers.lua
nvim
```

---

## LSP Servers

Los servidores se declaran en `lua/config/lsp_servers.lua`. Mason los instala automáticamente al abrir Neovim.

| Server | Lenguaje / Tecnología |
|---|---|
| `html` | HTML |
| `cssls` | CSS |
| `tailwindcss` | Tailwind CSS |
| `ts_ls` | TypeScript / JavaScript (incluye Vue via hybrid mode) |
| `emmet_ls` | Emmet (HTML/CSS) |
| `lua_ls` | Lua |
| `pyright` | Python |
| `vue_ls` | Vue.js (hybrid mode con ts_ls) |
| `bashls` | Bash |
| `yamlls` | YAML |
| `jsonls` | JSON |

Para agregar un servidor, añadir su nombre a `lsp_servers.lua` y reiniciar Neovim.

---

## Plugins

### UI

| Plugin | Descripcion |
|---|---|
| `catppuccin/nvim` | Tema Mocha con 60+ highlight groups transparentes |
| `nvim-lualine/lualine.nvim` | Statusline minimalista con información contextual |
| `akinsho/bufferline.nvim` | Tabs para buffers con numeracion |
| `nvim-tree/nvim-tree.lua` | Explorador de archivos lateral |
| `folke/which-key.nvim` | Guia flotante de keybindings |
| `folke/noice.nvim` | UI mejorada para mensajes, cmdline y popups |
| `rcarriga/nvim-notify` | Notificaciones toast |
| `lukas-reineke/indent-blankline.nvim` | Guias de indentacion |
| `stevearc/dressing.nvim` | Mejoras de `vim.ui.input` y `vim.ui.select` |
| `goolord/alpha-nvim` | Dashboard de inicio |
| `b0o/incline.nvim` | Nombres de archivo flotantes por ventana |
| `norcalli/nvim-colorizer.lua` | Preview de colores hex/rgb inline |
| `amrbashir/nvim-docs-view` | Panel de documentacion LSP persistente |
| `folke/zen-mode.nvim` | Modo Zen para enfoque total |
| `folke/todo-comments.nvim` | Resaltado y busqueda de `TODO`, `FIXME`, etc. |

### LSP y Diagnosticos

| Plugin | Descripcion |
|---|---|
| `williamboman/mason.nvim` | Gestor de LSP servers, linters y formatters |
| `williamboman/mason-lspconfig.nvim` | Puente entre Mason y nvim-lspconfig |
| `neovim/nvim-lspconfig` | Configuracion de servidores LSP |
| `folke/trouble.nvim` | UI mejorada para diagnosticos, referencias y quickfix |
| `kosayoda/nvim-lightbulb` | Indicador de code actions disponibles |
| `rachartier/tiny-inline-diagnostic.nvim` | Diagnosticos inline minimalistas |
| `https://git.sr.ht/~whynothugo/lsp_lines.nvim` | Diagnosticos como lineas virtuales (toggle) |
| `folke/neodev.nvim` | Tipos Lua para la API de Neovim |

### Edicion

| Plugin | Descripcion |
|---|---|
| `windwp/nvim-autopairs` | Cierre automatico de pares (`()`, `{}`, `[]`) |
| `numToStr/Comment.nvim` | Comentar/descomentar con `gcc` y `gc` |
| `nvim-treesitter/nvim-treesitter` | Parsing, resaltado sintactico y textobjects |
| `stevearc/conform.nvim` | Formateo automatico al guardar |
| `mfussenegger/nvim-lint` | Linting asincrono |
| `rmagatti/goto-preview` | Preview de definicion en ventana flotante |

### Autocompletado y Snippets

| Plugin | Descripcion |
|---|---|
| `hrsh7th/nvim-cmp` | Motor de autocompletado con multiples fuentes |
| `L3MON4D3/LuaSnip` | Motor de snippets |
| `saadparwaiz1/cmp_luasnip` | Fuente LuaSnip para nvim-cmp |
| `hrsh7th/cmp-nvim-lsp` | Fuente LSP para nvim-cmp |
| `hrsh7th/cmp-buffer` | Fuente de texto del buffer |
| `hrsh7th/cmp-path` | Fuente de rutas del sistema de archivos |
| `supermaven-inc/supermaven-nvim` | Autocompletado con IA (1M context, gratuito) |

### Git

| Plugin | Descripcion |
|---|---|
| `kdheepak/lazygit.nvim` | LazyGit integrado en Neovim |
| `sindrets/diffview.nvim` | Diff viewer avanzado y resolucion de conflictos de merge |
| `lewis6991/gitsigns.nvim` | Indicadores de cambios en gutter y hunks |

### Debug (DAP)

| Plugin | Descripcion |
|---|---|
| `mfussenegger/nvim-dap` | Debug Adapter Protocol core |
| `rcarriga/nvim-dap-ui` | Interfaz visual para debugging |
| `theHamsta/nvim-dap-virtual-text` | Valores de variables inline durante debug |
| `jay-babu/mason-nvim-dap.nvim` | Instalacion automatica de adapters via Mason |

Adapters instalados: `debugpy` (Python), `js-debug-adapter` (Node.js/TypeScript/React), `codelldb` (Rust/C/C++).

### Testing

| Plugin | Descripcion |
|---|---|
| `nvim-neotest/neotest` | Framework de testing con UI interactiva |
| `nvim-neotest/neotest-jest` | Adaptador para Jest |
| `marilari88/neotest-vitest` | Adaptador para Vitest (auto-deteccion) |

### Herramientas

| Plugin | Descripcion |
|---|---|
| `nvim-telescope/telescope.nvim` | Busqueda fuzzy de archivos, texto, buffers y simbolos |
| `stevearc/aerial.nvim` | Panel de simbolos (funciones, clases) con soporte LSP |
| `ThePrimeagen/refactoring.nvim` | Extract function/variable/block, inline, debug prints |
| `folke/persistence.nvim` | Sesiones automaticas por directorio |
| `danymat/neogen` | Generacion de docstrings |
| `christoomey/vim-tmux-navigator` | Navegacion seamless entre panes Tmux y splits Neovim |

---

## Keybindings

**Leader**: `<Space>`

Los prefijos siguen la convencion LazyVim/comunidad para consistencia:

| Prefijo | Categoria |
|---|---|
| `<leader>b` | Buffers |
| `<leader>c` | Codigo / LSP actions |
| `<leader>d` | Debug (DAP) |
| `<leader>e` | Explorer (arbol de archivos) |
| `<leader>f` | Find / Telescope |
| `<leader>g` | Git |
| `<leader>o` | Outline (Aerial) |
| `<leader>p` | Packages (Lazy, Mason) |
| `<leader>q` | Quit / Session |
| `<leader>r` | Refactoring |
| `<leader>s` | Search / Replace |
| `<leader>t` | Tests |
| `<leader>u` | UI Toggles |
| `<leader>w` | Windows / Splits |
| `<leader>x` | Diagnosticos (Trouble + Quickfix) |
| `<leader>z` | Zen / Focus |

### Editor

| Keymap | Accion |
|---|---|
| `<leader>w` | Guardar archivo |
| `<leader>W` | Guardar todos los buffers |
| `<leader>q` | Cerrar ventana |
| `<leader>Q` | Salir sin guardar |
| `<leader>qq` | Salir de Neovim |
| `<C-d>` / `<C-u>` | Scroll centrado |
| `<C-h/j/k/l>` | Navegar entre ventanas |
| `J` / `K` (visual) | Mover linea abajo / arriba |
| `<` / `>` (visual) | Indentar (mantiene seleccion) |
| `<leader>y` | Copiar al portapapeles del sistema |
| `<leader>p` | Pegar desde portapapeles |

### Buffers (`<leader>b`)

| Keymap | Accion |
|---|---|
| `<S-h>` / `<S-l>` | Buffer anterior / siguiente |
| `<leader>bd` | Cerrar buffer |
| `<leader>bD` | Forzar cierre de buffer |
| `<leader>bo` | Cerrar todos excepto el actual |
| `<leader>1`-`9` | Ir al buffer por numero |

### Ventanas (`<leader>w`)

| Keymap | Accion |
|---|---|
| `<leader>wv` | Split vertical |
| `<leader>wh` | Split horizontal |
| `<leader>we` | Igualar tamano de splits |
| `<leader>wx` | Cerrar split actual |
| `<leader>wm` | Maximizar ventana actual |
| `<C-Arriba/Abajo>` | Redimensionar alto |
| `<C-Izquierda/Derecha>` | Redimensionar ancho |

### Busqueda y Reemplazo (`<leader>s`)

| Keymap | Accion |
|---|---|
| `<Esc>` | Limpiar resaltado de busqueda |
| `<leader>sr` | Reemplazar palabra bajo cursor |
| `<leader>sa` | Seleccionar todo el archivo |

### Telescope (`<leader>f`)

| Keymap | Accion |
|---|---|
| `<leader>ff` | Buscar archivos |
| `<leader>fg` | Buscar texto (live grep) |
| `<leader>fb` | Listar buffers abiertos |
| `<leader>fr` | Archivos recientes |
| `<leader>fw` | Buscar palabra bajo cursor |
| `<leader>fh` | Ayuda de Neovim |
| `<leader>fk` | Keymaps |
| `<leader>fc` | Comandos |
| `<leader>fm` | Marks |
| `<leader>fd` | Diagnosticos |
| `<leader>fo` | Simbolos del documento |
| `<leader>fO` | Simbolos del workspace |

### LSP (`<leader>c` y navegacion nativa)

| Keymap | Accion |
|---|---|
| `K` | Documentacion hover |
| `gK` | Firma de funcion |
| `gd` | Ir a definicion |
| `gD` | Ir a declaracion |
| `gi` | Ir a implementacion |
| `gt` | Ir a definicion de tipo |
| `gr` | Ver referencias |
| `gR` | Referencias en Trouble |
| `gl` | Diagnostico flotante inline |
| `]d` / `[d` | Siguiente / anterior diagnostico |
| `]e` / `[e` | Siguiente / anterior error |
| `<leader>ca` | Code actions |
| `<leader>cr` | Renombrar simbolo |
| `<leader>cf` | Formatear archivo |
| `<leader>cd` | Diagnostico flotante |
| `<leader>cD` | Diagnosticos del documento (Trouble) |
| `<leader>cs` | Simbolos LSP (Trouble) |

### Trouble / Diagnosticos (`<leader>x`)

| Keymap | Accion |
|---|---|
| `<leader>xx` | Diagnosticos del workspace |
| `<leader>xd` | Diagnosticos del documento |
| `<leader>xr` | Referencias LSP |
| `<leader>xs` | Simbolos LSP |
| `<leader>xq` | Quickfix list |
| `<leader>xl` | Location list |
| `<leader>xo` | Abrir quickfix nativo |
| `<leader>xc` | Cerrar quickfix nativo |
| `]q` / `[q` | Siguiente / anterior quickfix |

### Git (`<leader>g`)

| Keymap | Accion |
|---|---|
| `<leader>gg` | Abrir LazyGit |
| `<leader>gf` | Archivos Git (Telescope) |
| `<leader>gl` | Log de commits (Telescope) |
| `<leader>gs` | Git status (Telescope) |
| `<leader>gd` | Abrir Diffview |
| `<leader>gD` | Cerrar Diffview |
| `<leader>gfh` | Historial de todo el repositorio |
| `<leader>gff` | Historial del archivo actual |
| `<leader>gm` | Conflictos de merge (HEAD) |
| `<leader>gc` | Diff del ultimo commit (HEAD~1) |
| `]c` / `[c` | Siguiente / anterior hunk (gitsigns) |

### Debug - DAP (`<leader>d`)

| Keymap | Accion |
|---|---|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Breakpoint condicional |
| `<leader>dc` | Continuar / iniciar debug |
| `<leader>da` | Continuar con argumentos |
| `<leader>dC` | Ejecutar hasta el cursor |
| `<leader>dl` | Re-ejecutar ultimo debug |
| `<leader>dp` | Pausar ejecucion |
| `<leader>dt` | Terminar sesion de debug |
| `<leader>di` | Step into |
| `<leader>dO` | Step over |
| `<leader>do` | Step out |
| `<leader>dg` | Ir a linea (sin ejecutar) |
| `<leader>dk` / `<leader>dj` | Stack arriba / abajo |
| `<leader>du` | Toggle DAP UI |
| `<leader>dr` | Toggle REPL |
| `<leader>de` | Evaluar expresion (normal/visual) |
| `<leader>dw` | Hover widgets |
| `<leader>ds` | Info de sesion |

Lenguajes soportados: JavaScript, TypeScript, React (TSX/JSX), Python.

### Testing - Neotest (`<leader>t`)

| Keymap | Accion |
|---|---|
| `<leader>tt` | Ejecutar test mas cercano |
| `<leader>tf` | Ejecutar tests del archivo actual |
| `<leader>ta` | Ejecutar todos los tests |
| `<leader>tl` | Re-ejecutar ultimo test |
| `<leader>ts` | Toggle resumen de tests |
| `<leader>to` | Abrir output del test |
| `<leader>tO` | Toggle panel de output |
| `<leader>tw` | Toggle watch mode |
| `<leader>twf` | Watch del archivo actual |
| `<leader>td` | Debug del test mas cercano (integracion DAP) |
| `<leader>tS` | Detener todos los tests |
| `<leader>tp` / `<leader>tn` | Test fallido anterior / siguiente |

Frameworks soportados: Jest y Vitest con auto-deteccion.

### Refactoring (`<leader>r`)

| Keymap | Modo | Accion |
|---|---|---|
| `<leader>re` | Visual | Extract function |
| `<leader>rf` | Visual | Extract function to file |
| `<leader>rv` | Visual | Extract variable |
| `<leader>ri` | Normal/Visual | Inline variable |
| `<leader>rI` | Normal | Inline function |
| `<leader>rb` | Normal | Extract block |
| `<leader>rbf` | Normal | Extract block to file |
| `<leader>rs` | Visual | Seleccionar refactoring (Telescope) |
| `<leader>rd` | Normal/Visual | Debug: imprimir variable |
| `<leader>rc` | Normal | Debug: limpiar prints |

### Supermaven AI

| Keymap | Accion |
|---|---|
| `<C-y>` (Insert) | Aceptar sugerencia completa |
| `<C-e>` (Insert) | Rechazar sugerencia |
| `<M-l>` (Insert) | Aceptar proxima palabra |
| `<leader>ai` | Toggle Supermaven |
| `<leader>as` | Estado de Supermaven |
| `<leader>al` | Ver logs de Supermaven |

### Outline - Aerial (`<leader>o`)

| Keymap | Accion |
|---|---|
| `<leader>o` | Toggle panel de outline |
| `<leader>ot` | Toggle outline (Treesitter) |
| `<leader>on` / `<leader>op` | Siguiente / anterior simbolo |

### LSP Lines (`<leader>u`)

| Keymap | Accion |
|---|---|
| `<leader>ul` | Toggle LSP Lines (diagnosticos como lineas virtuales) |
| `<leader>uw` | Toggle word wrap |
| `<leader>us` | Toggle spell check |
| `<leader>un` | Toggle numeros de linea |
| `<leader>ur` | Toggle numeros relativos |
| `<leader>uc` | Toggle cursorline |

### Packages (`<leader>p`)

| Keymap | Accion |
|---|---|
| `<leader>pl` | Abrir Lazy |
| `<leader>ps` | Sync plugins |
| `<leader>pu` | Actualizar plugins |
| `<leader>pc` | Limpiar plugins no usados |
| `<leader>pp` | Perfil de tiempo de inicio |
| `<leader>pm` | Abrir Mason |
| `<leader>pM` | Actualizar Mason |

### Sesiones (`<leader>q`)

| Keymap | Accion |
|---|---|
| `<leader>qs` | Restaurar sesion del directorio actual |
| `<leader>ql` | Restaurar ultima sesion |
| `<leader>qd` | No guardar sesion al salir |

---

## Comandos Utiles

| Comando | Descripcion |
|---|---|
| `:Lazy` | Abrir gestor de plugins |
| `:Lazy sync` | Instalar, actualizar y limpiar plugins |
| `:Lazy update` | Actualizar plugins |
| `:Lazy clean` | Eliminar plugins no usados |
| `:Lazy profile` | Ver tiempos de carga |
| `:Mason` | Abrir gestor de LSP servers |
| `:MasonUpdate` | Actualizar todos los servers |
| `:LspInfo` | Estado de los servidores LSP activos |
| `:LspRestart` | Reiniciar servidor LSP del buffer actual |
| `:checkhealth` | Diagnostico completo de la instalacion |
| `:Telescope` | Ver todos los pickers disponibles |
| `:AerialToggle` | Toggle panel de simbolos |
| `:SupermavenToggle` | Toggle autocompletado AI |
| `:SupermavenStatus` | Estado de Supermaven |
| `:DiffviewOpen` | Abrir vista de diff de Git |
| `:DiffviewFileHistory` | Historial del repositorio |

---

## Personalizacion

### Agregar un plugin

Crear un archivo en `lua/plugins/<categoria>/nombre.lua`:

```lua
return {
  "autor/nombre-plugin",
  event = "VeryLazy",
  keys = {
    { "<leader>x", "<cmd>MiComando<cr>", desc = "Descripcion" },
  },
  opts = {
    -- configuracion
  },
}
```

Reiniciar Neovim. lazy.nvim detecta el archivo automaticamente y ofrece instalar el plugin.

### Agregar un LSP server

Editar `lua/config/lsp_servers.lua` y agregar el nombre exacto del servidor:

```lua
return {
  -- servidores existentes...
  "nuevo_servidor",
}
```

Mason lo instala en el proximo inicio de Neovim.

### Usar los colores de Catppuccin

Los colores estan centralizados en `lua/utils/colors.lua`:

```lua
local colors = require("utils.colors")

-- Ejemplos
fg = colors.primary        -- Azul (#89b4fa)
bg = colors.bg             -- Fondo (#1e1e2e)
colors.diagnostic.error    -- Rojo para errores
colors.catppuccin.surface0 -- Superficie 0
```

---

## Sistema de Transparencia

La configuracion define 60+ highlight groups transparentes para integrarse con el fondo del terminal:

- Fondo del editor (Normal, NormalNC)
- Sidebar de nvim-tree
- Floating windows y popups
- Telescope
- Statusline semi-transparente

La transparencia depende del soporte del terminal. Se requiere 24-bit color (`termguicolors = true`).

---

## Integracion con Otras Herramientas

| Herramienta | Integracion |
|---|---|
| **Tmux** | Navegacion seamless con `<C-h/j/k/l>` via vim-tmux-navigator |
| **LazyGit** | `<leader>gg` abre LazyGit en un float dentro de Neovim |
| **Supermaven** | Autocompletado AI activo en modo Insert |
| **ripgrep** | Usado por Telescope para busqueda de texto |

---

## Solucion de Problemas

### Plugins no se cargan

```bash
# Eliminar datos locales y cache para reinstalacion limpia
rm -rf ~/.local/share/nvim ~/.cache/nvim
nvim  # lazy.nvim y los plugins se reinstalan automaticamente
```

### LSP no funciona

```vim
:LspInfo          " Ver si el servidor esta corriendo en el buffer actual
:Mason            " Reinstalar el servidor si esta marcado como error
:LspRestart       " Reiniciar el servidor sin cerrar Neovim
```

### Colores incorrectos o sin transparencia

- Verificar soporte de 24-bit color: `echo $COLORTERM` debe retornar `truecolor`
- Si no esta configurado, agregar `export COLORTERM=truecolor` al shell
- Terminales recomendados: WezTerm, iTerm2, Kitty, Alacritty

### Supermaven no se activa

```vim
:SupermavenStatus   " Ver el estado actual
:SupermavenStart    " Iniciar manualmente
:SupermavenShowLog  " Ver logs para diagnosticar errores
```

La primera vez se debe ejecutar `:SupermavenUseFree` para configurar el tier gratuito.

### DAP no encuentra el adapter

```vim
:Mason              " Verificar que debugpy / js-debug-adapter estan instalados
:DapInstall         " Instalar adapter manualmente si es necesario
```

---

## Recursos Adicionales

- [Guia de Personalizacion](../guides/customization.md)
- [Plugins Avanzados](../advanced/neovim-plugins.md)
- [Keybindings Completos](../guides/keybindings.md)
- [Workflows](../guides/workflows.md)

## Referencias

- [Neovim](https://neovim.io/)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [Catppuccin para Neovim](https://github.com/catppuccin/nvim)
- [Mason.nvim](https://github.com/williamboman/mason.nvim)
- [nvim-dap](https://github.com/mfussenegger/nvim-dap)
- [neotest](https://github.com/nvim-neotest/neotest)

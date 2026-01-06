# Integración de Herramientas

Guía completa de integración entre Neovim, Tmux, Zsh, Git, Yazi y otras herramientas del ecosistema.

## Índice

- [Neovim + Tmux](#neovim--tmux)
- [Zsh + Tmux](#zsh--tmux)
- [Git + Delta + Neovim](#git--delta--neovim)
- [Yazi + Neovim + Tmux](#yazi--neovim--tmux)
- [LazyGit + Neovim](#lazygit--neovim)
- [Starship + Zsh + Git](#starship--zsh--git)
- [Telescope + Ripgrep + FD](#telescope--ripgrep--fd)
- [WezTerm + Tmux + Neovim](#wezterm--tmux--neovim)

## Neovim + Tmux

### Vim-Tmux-Navigator

**Navegación seamless entre splits de Neovim y panes de Tmux.**

**Cómo funciona:**

```
Neovim          Tmux
┌─────────┐    ┌─────────┐
│ Split 1 │───>│ Pane 1  │
│         │    │         │
├─────────┤    ├─────────┤
│ Split 2 │<───│ Pane 2  │
└─────────┘    └─────────┘

Ctrl + h/j/k/l funciona en ambos
```

**Configuración:**

**Neovim** (`lua/plugins/tools/vim-tmux-navigator.lua`):
```lua
{
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
  },
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>" },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>" },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>" },
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>" },
  },
}
```

**Tmux** (`.tmux.conf`):
```bash
# Smart pane switching with awareness of Vim splits.
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
```

**Workflow ejemplo:**

```bash
# 1. Layout típico
┌──────────────┬──────────────┐
│              │              │
│   Neovim     │   Terminal   │
│   (código)   │   (npm run)  │
│              │              │
└──────────────┴──────────────┘

# 2. Splits dentro de Neovim
# Neovim: <leader>vsp para split vertical

┌──────────────┬──────────────┐
│  Nvim │ Nvim │              │
│  Buf1 │ Buf2 │   Terminal   │
│       │      │              │
└───────┴──────┴──────────────┘

# 3. Navegación fluida
Ctrl + l  # Desde Nvim Buf2 → Terminal
Ctrl + h  # De vuelta a Nvim Buf2
Ctrl + h  # Dentro de Neovim: Buf2 → Buf1
```

### Auto-Hide Status Bar

**Tmux status bar se oculta al entrar a Neovim.**

**Configuración Tmux:**

```bash
# En .tmux.conf
set-hook -g client-attached 'run-shell "tmux set status on"'
set-hook -g client-detached 'run-shell "tmux set status on"'
```

**Configuración Neovim** (`lua/config/autocmds.lua`):

```lua
-- Ocultar status bar de Tmux al entrar a Neovim
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.env.TMUX then
      vim.fn.system("tmux set status off")
    end
  end,
})

-- Restaurar al salir
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    if vim.env.TMUX then
      vim.fn.system("tmux set status on")
    end
  end,
})
```

**Ventajas:**
- Más espacio vertical en Neovim (60 líneas → 62 líneas)
- Status bar de Neovim (lualine) ya muestra info necesaria
- Al salir de Neovim, status bar vuelve para navegación en terminal

### Clipboard Compartido

**Copiar en Neovim → pegar en Tmux (y viceversa).**

**Configuración Neovim** (`lua/config/options.lua`):

```lua
vim.opt.clipboard = "unnamedplus"  -- Usa clipboard del sistema
```

**Configuración Tmux** (`.tmux.conf`):

```bash
# Habilitar clipboard del sistema
set -g set-clipboard on

# Tmux yank plugin
set -g @plugin 'tmux-plugins/tmux-yank'
```

**Workflow:**

```bash
# 1. Copiar en Neovim
# Visual mode (v) → seleccionar → y

# 2. Cambiar a pane de Tmux
Ctrl + l

# 3. Pegar
Ctrl + Shift + V  # (o Cmd+V en macOS)

# 4. O al revés: Copy mode en Tmux
Prefix + [
# Seleccionar con Space → y
# Pegar en Neovim con p
```

### True Color Support

**Neovim y Tmux comparten colores 24-bit.**

**Tmux** (`.tmux.conf`):

```bash
set-option -sa terminal-overrides ",xterm*:Tc"
set -g default-terminal "tmux-256color"
```

**Neovim** (`lua/config/options.lua`):

```lua
vim.opt.termguicolors = true
```

**Resultado:**
- Catppuccin Mocha se ve idéntico en Neovim dentro y fuera de Tmux
- Transparencia funciona correctamente
- Undercurl y otros efectos especiales visibles

## Zsh + Tmux

### Auto-Start Tmux

**Zsh inicia Tmux automáticamente al abrir terminal.**

**Configuración** (`~/.zshrc`):

```bash
# Auto-start Tmux si no está corriendo
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
  tmux attach -t default || tmux new -s default
fi
```

**Comportamiento:**
1. Abre terminal → Tmux inicia automáticamente
2. Si sesión "default" existe → adjunta a ella
3. Si no existe → crea sesión "default"

**Desactivar temporalmente:**

```bash
# Variable de entorno para saltar auto-start
NO_TMUX=1 zsh
```

### Aliases de Tmux en Zsh

**Definidos en `~/.zshrc`:**

```bash
# Session management
alias tn='tmux new -s'           # Nueva sesión con nombre
alias ta='tmux attach -t'        # Adjuntar a sesión
alias tls='tmux ls'              # Listar sesiones
alias tk='tmux kill-session -t'  # Matar sesión

# Quick actions
alias tka='tmux kill-server'     # Matar todas las sesiones
alias trs='tmux source-file ~/.tmux.conf'  # Recargar config
```

**Uso:**

```bash
tn backend          # tmux new -s backend
ta frontend         # tmux attach -t frontend
tls                 # Ver todas las sesiones
tk testing          # tmux kill-session -t testing
```

### SessionX + Zoxide Integration

**Zsh indexa directorios automáticamente para SessionX.**

**Cómo funciona:**

```bash
# 1. Navegas en Zsh
cd ~/proyectos/dotfiles      # Zoxide registra
cd ~/proyectos/web-app       # Zoxide registra
cd ~/clientes/ecommerce      # Zoxide registra

# 2. En Tmux, abrir SessionX
Prefix + s

# 3. SessionX muestra:
# - Sesiones de Tmux existentes
# - Directorios frecuentes de Zoxide
# - Búsqueda fuzzy con FZF

# 4. Escribir "dot"
# Encuentra: ~/proyectos/dotfiles
# Enter → Crea/cambia a sesión en ese directorio
```

**Ver base de datos de Zoxide:**

```bash
zoxide query -ls

# Output ejemplo:
# 1000  /home/usuario/proyectos/dotfiles
#  800  /home/usuario/proyectos/web-app
#  600  /home/usuario/proyectos/backend
```

### Prompt de Starship en Tmux

**Starship funciona tanto en Zsh fuera de Tmux como dentro.**

**Configuración** (`~/.zshrc`):

```bash
# Starship debe ser la última línea
eval "$(starship init zsh)"
```

**Comportamiento:**
- Fuera de Tmux: Prompt normal de Starship
- Dentro de Tmux: Prompt idéntico
- Git status, duración de comando, etc. funcionan igual

## Git + Delta + Neovim

### Git Delta en Terminal

**Delta mejora los diffs de Git con syntax highlighting.**

**Configuración** (`~/.gitconfig`):

```toml
[core]
pager = delta

[delta]
features = catppuccin-mocha
navigate = true
side-by-side = true
line-numbers = true
```

**Uso:**

```bash
git diff                    # Delta muestra diff mejorado
git log -p                  # Logs con diffs
git show <commit>           # Commit con delta

# Navegación en Delta
n                           # Siguiente cambio
N                           # Cambio anterior
q                           # Salir
```

**Output ejemplo:**

```diff
┊ 45│const name = 'old'     ┊ 45│const name = 'new'
     ^^^^^ removed              ^^^^^ added
```

### LazyGit desde Neovim

**Abrir LazyGit sin salir de Neovim.**

**Configuración Neovim** (`lua/plugins/git/lazygit.lua`):

```lua
{
  "kdheepak/lazygit.nvim",
  keys = {
    { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
  },
}
```

**Workflow:**

```bash
# 1. Editando en Neovim
# Modificaste varios archivos

# 2. Presionar <leader>gg
# LazyGit abre en floating window

# 3. Gestionar Git:
# - Ver cambios (tab para navegar)
# - Stage files (space)
# - Commit (c)
# - Push (P)
# - Crear branches (n)

# 4. Presionar q
# Vuelves a Neovim, cambios commiteados
```

**Ventajas:**
- No sales de Neovim
- Contexto visual completo
- Más rápido que comandos Git manuales
- Atajos similares a Vim

### Gitsigns en Neovim

**Indicadores de cambios Git en el gutter de Neovim.**

**Features:**

```vim
# Símbolos en gutter
│ ✓  " Línea sin cambios
│ ~  " Línea modificada
│ +  " Línea agregada
│ _  " Línea eliminada

# Keybindings
]c           " Siguiente cambio (hunk)
[c           " Cambio anterior
<leader>hs   " Stage hunk
<leader>hr   " Reset hunk
<leader>hp   " Preview hunk
<leader>hb   " Blame línea
```

**Workflow ejemplo:**

```bash
# 1. Editando auth.js
# 2. Modificas función de login
# 3. Gutter muestra ~ en líneas modificadas
# 4. Presionar ]c para ir al cambio
# 5. Presionar <leader>hp para ver diff
# 6. Presionar <leader>hs para stage solo ese cambio
# 7. Presionar <leader>gg para commit con LazyGit
```

### Git Blame en Neovim

**Ver quién modificó cada línea.**

```vim
# Toggle git blame
<leader>tb

# Blame aparece como virtual text:
# 47  const user = await auth()  • John Doe • 2 days ago • feat: add auth
```

## Yazi + Neovim + Tmux

### Yazi como File Explorer

**Yazi es el file manager de terminal con Vim keybindings.**

**Integración:**

```bash
# 1. En Tmux, crear pane para Yazi
Prefix + v

# 2. Abrir Yazi
yazi

# 3. Navegar (Vim-style)
h    # Directorio padre
j/k  # Arriba/abajo
l    # Abrir carpeta/archivo

# 4. Presionar Enter en archivo .lua
# → Abre en Neovim (en otro pane)
```

### Yazi + Zsh Integration

**Función `yz` cambia directorio al salir de Yazi.**

**Configuración** (`~/.zshrc`):

```bash
function yz() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
```

**Workflow:**

```bash
# 1. Abrir Yazi con función
yz

# 2. Navegar a ~/proyectos/web-app
# hjkl para moverse

# 3. Presionar q (salir)

# 4. Zsh cambia a ~/proyectos/web-app
pwd  # /home/usuario/proyectos/web-app
```

### Layout: Yazi + Neovim + Terminal

```
┌─────────────┬─────────────┬─────────────┐
│             │             │             │
│    Yazi     │   Neovim    │  Terminal   │
│   (tree)    │  (editor)   │  (commands) │
│             │             │             │
└─────────────┴─────────────┴─────────────┘
```

**Crear este layout:**

```bash
# 1. Iniciar Tmux
tmux

# 2. Split vertical (Yazi)
Prefix + v
yazi

# 3. Split vertical (Neovim)
Ctrl + l
Prefix + v
nvim

# 4. Pane derecho queda para comandos
Ctrl + l

# Workflow:
# - Yazi: buscar archivos
# - Neovim: editar archivos
# - Terminal: git, npm, etc.
# - Ctrl+h/j/k/l para navegar
```

## LazyGit + Neovim

### Floating Window en Tmux

**LazyGit se abre como ventana flotante.**

**Configuración Neovim:**

```lua
-- LazyGit floating terminal
vim.api.nvim_create_user_command("LazyGit", function()
  vim.cmd("terminal lazygit")
  vim.cmd("startinsert")
end, {})
```

**O usar plugin:**

```lua
{
  "kdheepak/lazygit.nvim",
  keys = {
    { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
  },
}
```

### Workflow Git Completo

**Escenario: Feature completo con Git**

```bash
# 1. Crear feature branch
# En Neovim: <leader>gg
# LazyGit → presionar 'n' → nueva branch "feature/auth"

# 2. Editar archivos en Neovim
# Modificar auth.js, login.vue, etc.

# 3. Ver cambios
# <leader>gg
# LazyGit muestra:
# - Archivos modificados
# - Diff por archivo

# 4. Stage selectivo
# Tab para navegar a archivos
# Space para stage
# O presionar 'a' para stage all

# 5. Commit
# Presionar 'c'
# Escribir mensaje
# Enter para commit

# 6. Push a remote
# Presionar 'P' (shift+p)
# Confirmar push

# 7. Volver a Neovim
# Presionar 'q'
# Continuar editando

# Todo sin salir de Neovim
```

### Git Blame Integration

**Blame en LazyGit vs Gitsigns:**

**Gitsigns** (inline en Neovim):
```vim
<leader>tb    # Toggle blame virtual text
# Muestra en cada línea quién y cuándo
```

**LazyGit** (vista completa):
```bash
<leader>gg
# Presionar 'b' en un archivo
# Muestra blame completo con navegación
```

## Starship + Zsh + Git

### Prompt con Git Status

**Starship muestra estado de Git automáticamente.**

**Configuración** (`~/.config/starship.toml`):

```toml
[git_branch]
symbol = " "
format = "[$symbol$branch]($style) "

[git_status]
format = '([\[$all_status$ahead_behind\]]($style) )'
conflicted = ""
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
untracked = "?${count}"
stashed = "$${count}"
modified = "!${count}"
staged = "+${count}"
renamed = "»${count}"
deleted = "✘${count}"
```

**Output ejemplo:**

```bash
# En directorio Git limpio
~/proyectos/dotfiles  main

# Con cambios
~/proyectos/web-app  feature/auth !2 ?1 +3

# Explicación:
# !2  → 2 archivos modificados
# ?1  → 1 archivo sin track
# +3  → 3 archivos staged

# Con ahead/behind
~/proyectos/api  main ⇡2 ⇣1
# ⇡2  → 2 commits ahead de remote
# ⇣1  → 1 commit behind de remote
```

### Duración de Comandos

**Starship muestra tiempo de ejecución de comandos largos.**

```toml
[cmd_duration]
min_time = 500
format = "took [$duration]($style) "
```

**Ejemplo:**

```bash
$ npm run build
# ... building ...

~/proyectos/web-app  main took 3.2s
```

### Node/Python Version en Proyecto

**Starship detecta versión automáticamente.**

```toml
[nodejs]
symbol = " "
format = "[$symbol($version )]($style)"

[python]
symbol = " "
format = '[${symbol}${pyenv_prefix}(${version} )(\($virtualenv\) )]($style)'
```

**Ejemplo:**

```bash
# En proyecto Node
~/proyectos/web-app  main  v18.17.0

# En proyecto Python con venv
~/proyectos/api  main  v3.11.4 (venv)
```

## Telescope + Ripgrep + FD

### Búsqueda Rápida de Archivos

**Telescope usa FD para buscar archivos.**

**Configuración Neovim:**

```lua
{
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
  },
  opts = {
    defaults = {
      -- Usar FD para find_files
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
      },
    },
  },
}
```

**Instalar herramientas:**

```bash
# Ripgrep (búsqueda de texto)
brew install ripgrep         # macOS
sudo apt install ripgrep     # Linux

# FD (búsqueda de archivos)
brew install fd              # macOS
sudo apt install fd-find     # Linux
```

### Workflows con Telescope

**Buscar archivos:**

```vim
<leader>ff
# Escribe: "auth"
# Encuentra:
# - auth.js
# - auth.vue
# - auth-service.ts
# - components/AuthModal.vue

# Enter para abrir
```

**Buscar texto en proyecto:**

```vim
<leader>fg
# Escribe: "getUserData"
# Encuentra todas las ocurrencias en archivos

# Ctrl+n/p para navegar resultados
# Enter para ir a la ubicación
```

**Buscar en archivos abiertos:**

```vim
<leader>fb
# Muestra todos los buffers abiertos
# Fuzzy search para encontrar buffer
```

### Integración con Git

**Telescope + Git:**

```vim
<leader>gc    # Git commits
<leader>gs    # Git status
<leader>gb    # Git branches

# En Telescope git_commits:
# - Ver mensaje de commit
# - <C-v> para ver diff
# - Enter para checkout
```

## WezTerm + Tmux + Neovim

### True Color en Toda la Cadena

**WezTerm → Tmux → Neovim con colores 24-bit.**

**WezTerm** (`~/.wezterm.lua`):

```lua
config.term = "wezterm"
config.color_scheme = "Catppuccin Mocha"
config.enable_tab_bar = false
```

**Tmux** (`.tmux.conf`):

```bash
set-option -sa terminal-overrides ",wezterm*:Tc"
set -g default-terminal "tmux-256color"
```

**Neovim** (`lua/config/options.lua`):

```lua
vim.opt.termguicolors = true
```

**Resultado:**
- Catppuccin Mocha consistente en los 3 niveles
- Transparencia funciona perfectamente
- Sin degradación de color

### Font Ligatures

**WezTerm soporta ligatures, Tmux las pasa a Neovim.**

**WezTerm:**

```lua
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.harfbuzz_features = { "calt", "liga", "dlig", "ss01", "ss02" }
```

**Resultado en Neovim:**

```
# Código con ligatures
!= → ≠
== → ═
>= → ≥
-> → →
=> → ⇒
```

### Opacity y Blur

**WezTerm maneja transparencia, Tmux y Neovim heredan.**

**WezTerm:**

```lua
config.window_background_opacity = 0.85
config.macos_window_background_blur = 20  -- macOS only
```

**Tmux y Neovim:**
- Ambos configurados como transparentes
- WezTerm maneja el efecto de blur
- Background transparente se ve a través de toda la stack

### Resultado Visual

```
┌────────────────────────────────────────┐
│ WezTerm (85% opacity, blur 20)         │
│  ┌──────────────────────────────────┐  │
│  │ Tmux (transparent background)    │  │
│  │  ┌────────────────────────────┐  │  │
│  │  │ Neovim (transparent bg)    │  │  │
│  │  │  - Catppuccin Mocha        │  │  │
│  │  │  - Colores 24-bit          │  │  │
│  │  │  - Ligatures activas       │  │  │
│  │  └────────────────────────────┘  │  │
│  └──────────────────────────────────┘  │
└────────────────────────────────────────┘
```

## Ecosystem Completo

### Stack de Herramientas

**Terminal Emulator:**
- WezTerm (GPU-accelerated, true color, ligatures)

**Shell:**
- Zsh (plugins via submodules)
- Starship (prompt moderno)

**Multiplexer:**
- Tmux (sessions, layouts, persistencia)
- TPM (plugin manager)

**Editor:**
- Neovim (LSP, Treesitter, lazy.nvim)
- Mason (LSP servers)

**Git:**
- Git Delta (diffs mejorados)
- LazyGit (TUI)
- Gitsigns (integración Neovim)

**File Manager:**
- Yazi (Rust, Vim-style, preview)

**CLI Tools:**
- Ripgrep (búsqueda de texto)
- FD (búsqueda de archivos)
- Bat (cat mejorado)
- Eza (ls mejorado)
- Zoxide (cd inteligente)

### Flow de Trabajo Típico

**Inicio del día:**

```bash
# 1. Abrir WezTerm
# 2. Zsh auto-inicia Tmux
# 3. Resurrect restaura sesiones:
#    - backend (proyecto API)
#    - frontend (proyecto web)
#    - dotfiles (configuración)

# 4. Cambiar a proyecto del día
Prefix + s
# Buscar "backend"
# Enter

# 5. Layout restaurado:
┌─────────────┬─────────────┐
│   Neovim    │  Dev Server │
│   (código)  │  (npm run)  │
├─────────────┴─────────────┤
│      Git / Terminal        │
└────────────────────────────┘

# 6. Desarrollar
# - Editar en Neovim
# - Ver en browser
# - Commit con LazyGit
# - Tests en terminal
```

**Durante desarrollo:**

```bash
# Buscar archivo
<leader>ff → auth.js

# Buscar texto
<leader>fg → getUserData

# Ver cambios Git
<leader>gg → LazyGit

# Navegar código
gd → Ir a definición
gr → Ver referencias
K → Hover docs

# File explorer
Prefix + v
yazi

# Copiar error del log
Prefix + Space → [a] → path copiado
```

**Fin del día:**

```bash
# 1. Commit final
<leader>gg
# Stage all → commit → push

# 2. Cerrar terminal
# Continuum auto-guardó sesiones

# 3. Siguiente día
# Abrir WezTerm → Todo restaurado
```

## Troubleshooting

### Navegación Vim-Tmux No Funciona

**Verificar:**

```bash
# 1. Plugin en Neovim instalado
:Lazy
# Buscar "vim-tmux-navigator"

# 2. Configuración en Tmux
cat ~/.tmux.conf | grep "is_vim"

# 3. Recargar ambos
:source $MYVIMRC       # Neovim
Prefix + r             # Tmux
```

### Colores Incorrectos

**Verificar toda la cadena:**

```bash
# 1. WezTerm
echo $TERM  # Debe ser "wezterm" o "xterm-256color"

# 2. Tmux
tmux info | grep Tc  # Debe mostrar soporte Tc

# 3. Neovim
:echo &termguicolors  # Debe ser 1
```

### Clipboard No Funciona

**Verificar:**

```bash
# 1. Tmux yank instalado
ls ~/.tmux/plugins/ | grep yank

# 2. Neovim clipboard
:checkhealth clipboard

# 3. Sistema
# Linux: xclip instalado
# macOS: pbcopy disponible
```

## Recursos Adicionales

- [Neovim Configuration](../services/nvim.md)
- [Tmux Configuration](../services/tmux.md)
- [Neovim Plugins Advanced](../advanced/neovim-plugins.md)
- [Tmux Workflows](../advanced/tmux-workflows.md)
- [Keybindings Reference](../guides/keybindings.md)

## Referencias

- [Vim-Tmux-Navigator](https://github.com/christoomey/vim-tmux-navigator)
- [LazyGit.nvim](https://github.com/kdheepak/lazygit.nvim)
- [Telescope](https://github.com/nvim-telescope/telescope.nvim)
- [Gitsigns](https://github.com/lewis6991/gitsigns.nvim)
- [Yazi](https://github.com/sxyazi/yazi)
- [Starship](https://starship.rs)

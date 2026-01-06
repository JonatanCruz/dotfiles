# Customization - Guía de Personalización

Cómo personalizar y adaptar este entorno a tu estilo y necesidades.

## Índice

- [Cambiar Tema de Colores](#cambiar-tema-de-colores)
- [Personalizar Keybindings](#personalizar-keybindings)
- [Agregar Aliases Personalizados](#agregar-aliases-personalizados)
- [Configurar Starship Modules](#configurar-starship-modules)
- [Agregar Plugins a Neovim](#agregar-plugins-a-neovim)
- [Modificar Tmux Layout](#modificar-tmux-layout)
- [Personalizar Yazi](#personalizar-yazi)
- [WezTerm Customization](#wezterm-customization)
- [Advanced Customizations](#advanced-customizations)

---

## Cambiar Tema de Colores

**Tema Actual**: Catppuccin Mocha (purple/cyan) en todas las herramientas

### Cambiar a Otro Tema Catppuccin

Catppuccin tiene 4 variantes: Latte (light), Frappé, Macchiato, Mocha (actual)

#### 1. Neovim

Editar `~/.config/nvim/lua/plugins/colorscheme.lua`:

```lua
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- Cambiar a: "latte", "frappe", "macchiato", "mocha"
        transparent_background = true,
        -- ... resto de config ...
      })
    end,
  },
}
```

Reiniciar Neovim → `:Lazy sync`

#### 2. Tmux

Editar `~/.tmux.conf`:

```bash
# Buscar línea:
set -g @catppuccin_flavour 'mocha'

# Cambiar a:
set -g @catppuccin_flavour 'frappe'  # o latte, macchiato
```

Recargar: `Ctrl+s + r`

#### 3. Starship

Editar `~/.config/starship.toml`:

```toml
# Buscar paleta actual (líneas 136-148)
[palettes.catppuccin_mocha]
# ... colores ...

# Cambiar a (ejemplo Frappé):
[palettes.catppuccin_frappe]
rosewater = "#f2d5cf"
flamingo = "#eebebe"
pink = "#f4b8e4"
mauve = "#ca9ee6"
red = "#e78284"
maroon = "#ea999c"
peach = "#ef9f76"
yellow = "#e5c890"
green = "#a6d189"
teal = "#81c8be"
sky = "#99d1db"
sapphire = "#85c1dc"
blue = "#8caaee"
lavender = "#babbf1"

# Y cambiar la referencia (línea 151):
palette = "catppuccin_frappe"
```

#### 4. Yazi

Editar `~/.config/yazi/theme.toml`:

```toml
# Reemplazar todo el [flavor] section con colores del tema deseado
# Obtener colores de: https://github.com/catppuccin/yazi
```

#### 5. WezTerm

Editar `~/.config/wezterm/wezterm.lua`:

```lua
-- Buscar línea:
color_scheme = "Catppuccin Mocha"

-- Cambiar a:
color_scheme = "Catppuccin Frappe"  -- o Latte, Macchiato
```

Recargar: `Cmd+,` o cerrar y reabrir WezTerm

### Cambiar a Tema Completamente Diferente

#### Neovim: Instalar Otro Tema

```lua
-- En ~/.config/nvim/lua/plugins/colorscheme.lua
return {
  {
    "folke/tokyonight.nvim",  -- Ejemplo: TokyoNight
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",  -- storm, moon, night, day
        transparent = true,
      })
      vim.cmd([[colorscheme tokyonight]])
    end,
  },
}
```

**Temas populares**:
- `folke/tokyonight.nvim` - TokyoNight
- `rose-pine/neovim` - Rosé Pine
- `navarasu/onedark.nvim` - One Dark
- `rebelot/kanagawa.nvim` - Kanagawa
- `EdenEast/nightfox.nvim` - Nightfox

#### Starship: Usar Preset

```bash
# Ver presets disponibles
starship preset --help

# Aplicar preset
starship preset nerd-font-symbols > ~/.config/starship.toml

# O editar manualmente colores en [palettes] section
```

---

## Personalizar Keybindings

### Neovim

Editar `~/.config/nvim/lua/config/keymaps.lua`:

```lua
-- Agregar keybindings personalizados
local keymap = vim.keymap

-- Ejemplo: Cambiar <leader> de Space a ","
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Ejemplo: Mapear jj para salir de INSERT
keymap.set("i", "jj", "<ESC>", { desc = "Exit insert mode" })

-- Ejemplo: Cambiar navegación de buffers
keymap.set("n", "<Tab>", ":bnext<CR>", { desc = "Next buffer" })
keymap.set("n", "<S-Tab>", ":bprevious<CR>", { desc = "Previous buffer" })

-- Ejemplo: Quick save con Ctrl+s
keymap.set("n", "<C-s>", ":w<CR>", { desc = "Save file" })
keymap.set("i", "<C-s>", "<ESC>:w<CR>a", { desc = "Save file in insert" })

-- Ejemplo: Agregar keybinding para plugin
keymap.set("n", "<leader>u", ":UndotreeToggle<CR>", { desc = "Toggle Undotree" })
```

Reiniciar Neovim o `:source ~/.config/nvim/lua/config/keymaps.lua`

### Tmux

Editar `~/.tmux.conf`:

```bash
# Cambiar prefix key de Ctrl+s a Ctrl+a
unbind C-s
set -g prefix C-a
bind C-a send-prefix

# Cambiar split keybindings
unbind |
unbind -
bind v split-window -h  # Prefix + v para split vertical
bind s split-window -v  # Prefix + s para split horizontal

# Cambiar resize keybindings
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# Agregar keybinding para matar sesión
bind X confirm-before -p "kill-session #S? (y/n)" kill-session

# Agregar keybinding para crear ventana con nombre
bind C command-prompt -p "window name:" "new-window; rename-window '%%'"
```

Recargar: `Ctrl+s + r` (o tu nuevo prefix + r)

### Yazi

Editar `~/.config/yazi/keymap.toml`:

```toml
# Cambiar keybinding de navegación
[[manager.prepend_keymap]]
on = ["<C-n>"]
exec = "arrow 1"

[[manager.prepend_keymap]]
on = ["<C-p>"]
exec = "arrow -1"

# Agregar keybinding personalizado
[[manager.prepend_keymap]]
on = ["c", "d"]
exec = 'shell "mkdir -p $0" --block --confirm'

# Cambiar open behavior
[[manager.prepend_keymap]]
on = ["<Enter>"]
exec = "open --interactive"
```

### Zsh Vi Mode

Editar `~/.config/zsh/.zshrc`:

```bash
# Cambiar keybinding para salir de INSERT mode
# Por defecto: jk
# Cambiar a: jj
bindkey -M viins 'jj' vi-cmd-mode

# Agregar keybinding para edit-command-line
bindkey -M vicmd 'V' edit-command-line

# Cambiar keybinding de búsqueda
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward
```

Recargar: `source ~/.config/zsh/.zshrc`

---

## Agregar Aliases Personalizados

### Zsh Aliases

Editar `~/.config/zsh/aliases/personal.zsh` (o cualquier archivo en `aliases/`):

```bash
# Aliases de navegación
alias ..='cd ..'
alias ...='cd ../..'
alias dev='cd ~/proyectos/desarrollo'
alias dots='cd ~/dotfiles'

# Aliases de comandos comunes
alias c='clear'
alias h='history'
alias j='jobs'
alias ports='netstat -tulanp'

# Aliases de Git personalizados
alias gaa='git add --all'
alias gcam='git commit -am'
alias gfp='git fetch --all --prune'
alias glog='git log --oneline --graph --all --decorate'

# Aliases de Docker personalizados
alias dcu='docker-compose up'
alias dcd='docker-compose down'
alias dcr='docker-compose restart'

# Aliases de npm/yarn
alias ni='npm install'
alias nrs='npm run start'
alias nrd='npm run dev'
alias nrt='npm run test'
alias nrb='npm run build'

# Aliases de utilidades
alias weather='curl wttr.in'
alias myip='curl ifconfig.me'
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -'

# Funciones alias (más complejas)
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

function extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "'$1' no se puede extraer" ;;
        esac
    else
        echo "'$1' no es un archivo válido"
    fi
}

# Alias para Yazi con cd integration
function yz() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}
```

Recargar: `source ~/.config/zsh/.zshrc`

### Git Aliases

Editar `~/.gitconfig`:

```toml
[alias]
    # Aliases personalizados (agregar a sección [alias])

    # Shortcuts
    co = checkout
    br = branch
    ci = commit
    st = status

    # Commits
    amend = commit --amend
    undo = reset HEAD~1 --soft
    redo = commit -c ORIG_HEAD

    # Logs
    ls = log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate
    ll = log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --numstat

    # Branches
    recent = branch --sort=-committerdate
    gone = "!f() { git fetch --all --prune; git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -D; }; f"

    # Diffs
    dlast = diff HEAD~1..HEAD
    preview = diff --cached

    # Utilities
    aliases = !git config --get-regexp alias | sed 's/alias.\\([^ ]*\\)/\\1:/' | column -t -s ':'
    whoami = !git config user.name && git config user.email
```

---

## Configurar Starship Modules

Editar `~/.config/starship.toml`

### Habilitar/Deshabilitar Módulos

```toml
# Deshabilitar módulo
[nodejs]
disabled = true

# Habilitar módulo deshabilitado
[golang]
disabled = false
format = "[$symbol($version )]($style)"
```

### Personalizar Formato de Módulo

```toml
# Personalizar módulo Git
[git_branch]
symbol = " "
format = "[$symbol$branch(:$remote_branch)]($style) "
style = "bold mauve"

[git_status]
format = '([\[$all_status$ahead_behind\]]($style) )'
conflicted = "🏳"
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
up_to_date = "✓"
untracked = "?${count}"
stashed = "📦${count}"
modified = "!${count}"
staged = "+${count}"
renamed = "»${count}"
deleted = "✘${count}"
style = "bold red"

# Personalizar módulo de directorio
[directory]
truncation_length = 3
truncate_to_repo = true
format = "[$path]($style)[$read_only]($read_only_style) "
style = "bold cyan"
read_only = " 󰌾"
read_only_style = "red"

# Personalizar módulo de comando duration
[cmd_duration]
min_time = 500
format = "[$duration]($style) "
style = "bold yellow"

# Agregar módulo de memoria (deshabilitado por defecto)
[memory_usage]
disabled = false
threshold = 75
symbol = "󰍛 "
format = "$symbol[${ram_pct}]($style) "
style = "bold dimmed white"
```

### Agregar Módulos Personalizados

```toml
# Agregar módulo de batería (laptop)
[battery]
full_symbol = "🔋"
charging_symbol = "⚡"
discharging_symbol = "💀"
format = "[$symbol$percentage]($style) "

[[battery.display]]
threshold = 10
style = "bold red"

[[battery.display]]
threshold = 30
style = "bold yellow"

# Agregar módulo de hora
[time]
disabled = false
format = "[$time]($style) "
time_format = "%T"
style = "bold blue"

# Agregar módulo de username
[username]
style_user = "bold green"
style_root = "bold red"
format = "[$user]($style) "
disabled = false
show_always = true
```

### Cambiar Orden de Módulos

```toml
# Definir orden de módulos en el prompt
format = """
[┌─](bold green)\
$username\
$hostname\
$directory\
$git_branch\
$git_status\
$nodejs\
$python\
$docker_context\
$cmd_duration\
$line_break\
[└─](bold green)\
$character\
"""
```

---

## Agregar Plugins a Neovim

### Método 1: Agregar Plugin a Archivo Existente

Editar archivo correspondiente en `~/.config/nvim/lua/plugins/`:

```lua
-- Ejemplo: Agregar Undotree a editing.lua
return {
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    config = function()
      vim.g.undotree_WindowLayout = 2
      vim.g.undotree_SetFocusWhenToggle = 1
    end,
  },
  -- ... resto de plugins ...
}
```

### Método 2: Crear Nuevo Archivo de Plugin

Crear `~/.config/nvim/lua/plugins/undotree.lua`:

```lua
return {
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = {
      { "<leader>u", ":UndotreeToggle<CR>", desc = "Toggle Undotree" },
    },
    config = function()
      vim.g.undotree_WindowLayout = 2
      vim.g.undotree_SetFocusWhenToggle = 1
    end,
  },
}
```

### Plugins Recomendados

#### 1. nvim-surround (Manipulación de "surroundings")

```lua
return {
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },
}
```

**Uso**:
- `ysiw"` - Agregar comillas alrededor de palabra
- `ds"` - Eliminar comillas
- `cs"'` - Cambiar comillas dobles por simples

#### 2. vim-visual-multi (Múltiples cursores)

```lua
return {
  {
    "mg979/vim-visual-multi",
    branch = "master",
    event = "VeryLazy",
  },
}
```

**Uso**:
- `Ctrl+n` - Seleccionar palabra bajo cursor (repetir para múltiples)
- `Ctrl+Down/Up` - Crear cursores arriba/abajo

#### 3. mini.ai (Text objects avanzados)

```lua
return {
  {
    "echasnovski/mini.ai",
    version = false,
    config = function()
      require("mini.ai").setup({})
    end,
  },
}
```

**Uso**:
- `dif` - Delete in function
- `dac` - Delete around class
- `vip` - Visual select in parameter

#### 4. trouble.nvim (Lista de diagnósticos)

```lua
return {
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xq", "<cmd>Trouble quickfix toggle<cr>", desc = "Quickfix List (Trouble)" },
    },
    config = function()
      require("trouble").setup({})
    end,
  },
}
```

#### 5. harpoon (Navegación rápida de archivos)

```lua
return {
  {
    "ThePrimeagen/harpoon",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ha", function() require("harpoon.mark").add_file() end, desc = "Harpoon add file" },
      { "<leader>hh", function() require("harpoon.ui").toggle_quick_menu() end, desc = "Harpoon menu" },
      { "<leader>h1", function() require("harpoon.ui").nav_file(1) end, desc = "Harpoon file 1" },
      { "<leader>h2", function() require("harpoon.ui").nav_file(2) end, desc = "Harpoon file 2" },
      { "<leader>h3", function() require("harpoon.ui").nav_file(3) end, desc = "Harpoon file 3" },
      { "<leader>h4", function() require("harpoon.ui").nav_file(4) end, desc = "Harpoon file 4" },
    },
    config = function()
      require("harpoon").setup({})
    end,
  },
}
```

**Uso**:
- `<leader>ha` - Marcar archivo actual
- `<leader>hh` - Ver menu de archivos marcados
- `<leader>h1-4` - Saltar a archivo marcado N

### Instalar Plugins

```vim
# Abrir Neovim
nvim

# Lazy.nvim detecta cambios automáticamente
:Lazy sync

# O manualmente:
:Lazy install  # Instalar plugins nuevos
:Lazy update   # Actualizar plugins existentes
:Lazy clean    # Eliminar plugins no usados
```

---

## Modificar Tmux Layout

### Guardar Layout Personalizado

```bash
# 1. Crear tu layout ideal manualmente con splits
Ctrl+s + |   # Splits...
Ctrl+s + -   # ...

# 2. Ver layout actual
Ctrl+s + :
list-windows

# 3. Output muestra algo como:
# layout: bb62,239x60,0,0[239x30,0,0{119x30,0,0,1,119x30,120,0,2},239x29,0,31,3]

# 4. Copiar el string del layout
```

### Aplicar Layout Automáticamente

Editar `~/.tmux.conf`:

```bash
# Agregar función para crear layout predefinido
bind-key L run-shell "\
  tmux split-window -h -p 50; \
  tmux split-window -v -p 50; \
  tmux select-pane -t 0; \
  tmux split-window -v -p 33; \
"

# O definir múltiples layouts:

# Layout 1: Coding (editor + terminal + server)
bind-key C run-shell "\
  tmux split-window -h -p 30; \
  tmux select-pane -t 0; \
  tmux split-window -v -p 70; \
"

# Layout 2: Debugging (editor + logs + terminal + server)
bind-key D run-shell "\
  tmux split-window -h -p 50; \
  tmux split-window -v -p 50; \
  tmux select-pane -t 0; \
  tmux split-window -v -p 50; \
"

# Layout 3: Monitoring (4 paneles iguales)
bind-key M run-shell "\
  tmux split-window -h; \
  tmux split-window -v; \
  tmux select-pane -t 0; \
  tmux split-window -v; \
  tmux select-layout tiled; \
"
```

**Uso**:
- `Ctrl+s + C` → Layout de Coding
- `Ctrl+s + D` → Layout de Debugging
- `Ctrl+s + M` → Layout de Monitoring

### Layouts Predefinidos de Tmux

```bash
# Cambiar entre layouts predefinidos
Ctrl+s + Space

# Layouts disponibles:
# - even-horizontal: paneles horizontales iguales
# - even-vertical: paneles verticales iguales
# - main-horizontal: panel principal arriba
# - main-vertical: panel principal izquierda
# - tiled: grid de paneles iguales
```

---

## Personalizar Yazi

### Cambiar Previewer

Editar `~/.config/yazi/yazi.toml`:

```toml
[opener]
# Cambiar aplicación para abrir archivos
text = [
    { exec = 'nvim "$@"', block = true },  # Cambiar a tu editor preferido
]

image = [
    { exec = 'feh "$@"', display = false },  # Cambiar visor de imágenes
]

video = [
    { exec = 'mpv "$@"', orphan = true },  # Cambiar reproductor de video
]

# Agregar opener personalizado
pdf = [
    { exec = 'zathura "$@"', display = false },
]

# Configurar preview
[preview]
tab_size = 4
max_width = 600
max_height = 900
```

### Agregar Plugins a Yazi

```bash
# Directorio de plugins
mkdir -p ~/.config/yazi/plugins

# Clonar plugin (ejemplo: git.yazi)
git clone https://github.com/yazi-rs/plugins.git ~/.config/yazi/plugins/git

# Habilitar en init.lua
```

Crear `~/.config/yazi/init.lua`:

```lua
-- Cargar plugin de Git
require("git"):setup()

-- Configurar plugin
require("git").setup({
    enable_changed_sign = true,
    enable_untracked_sign = true,
})
```

### Personalizar Icons

Editar `~/.config/yazi/theme.toml`:

```toml
[icon]
# Cambiar icons para tipos de archivo
"*.txt" = ""
"*.md" = ""
"*.pdf" = ""
"*.zip" = ""
"*.tar" = ""

# Agregar icons personalizados
"*.jsx" = ""
"*.tsx" = ""
"*.vue" = "󰡄"
```

---

## WezTerm Customization

Editar `~/.config/wezterm/wezterm.lua`

### Cambiar Font

```lua
config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Medium" })
config.font_size = 13.0  -- Cambiar tamaño

-- O usar font family personalizado
config.font = wezterm.font_with_fallback({
    "Fira Code",
    "JetBrainsMono Nerd Font",
    "Symbols Nerd Font Mono",
})
```

### Modificar Opacity

```lua
-- Cambiar transparencia (0.0 = transparente, 1.0 = opaco)
config.window_background_opacity = 0.95  -- Menos transparente

-- Deshabilitar transparencia
config.window_background_opacity = 1.0
```

### Agregar Keybindings Personalizados

```lua
config.keys = {
    -- Cambiar navegación de tabs
    { key = "1", mods = "ALT", action = act.ActivateTab(0) },
    { key = "2", mods = "ALT", action = act.ActivateTab(1) },
    { key = "3", mods = "ALT", action = act.ActivateTab(2) },

    -- Agregar split panes (como Tmux)
    { key = "|", mods = "CMD|SHIFT", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
    { key = "_", mods = "CMD|SHIFT", action = act.SplitVertical { domain = "CurrentPaneDomain" } },

    -- Agregar Quick Select personalizado
    { key = "f", mods = "CMD", action = act.Search { CaseInSensitiveString = "" } },

    -- Copiar/pegar personalizado
    { key = "c", mods = "CMD", action = act.CopyTo "Clipboard" },
    { key = "v", mods = "CMD", action = act.PasteFrom "Clipboard" },
}
```

### Configurar Tab Bar

```lua
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false  -- Usar tab bar simple

-- Personalizar apariencia de tabs
config.tab_bar_at_bottom = false  -- Poner tabs arriba
config.colors = {
    tab_bar = {
        background = "#1e1e2e",  -- Background de tab bar
        active_tab = {
            bg_color = "#cba6f7",  -- Catppuccin Mauve
            fg_color = "#1e1e2e",
        },
        inactive_tab = {
            bg_color = "#313244",
            fg_color = "#cdd6f4",
        },
    },
}
```

---

## Advanced Customizations

### Crear Scripts Personalizados

Crear `~/dotfiles/scripts/mi-script.sh`:

```bash
#!/bin/bash

# Script personalizado para workflow específico

# Ejemplo: Setup rápido de proyecto
setup_project() {
    local project_name=$1
    mkdir -p ~/proyectos/$project_name
    cd ~/proyectos/$project_name

    # Inicializar Git
    git init
    echo "# $project_name" > README.md

    # Crear estructura
    mkdir -p src tests docs

    # Iniciar sesión Tmux
    tmux new -s $project_name
}

# Ejemplo: Backup de dotfiles
backup_dotfiles() {
    local backup_dir=~/dotfiles-backup-$(date +%Y%m%d)
    mkdir -p $backup_dir

    # Copiar configs importantes
    cp -r ~/.config/nvim $backup_dir/
    cp -r ~/.config/tmux $backup_dir/
    cp ~/.zshrc $backup_dir/

    echo "Backup guardado en: $backup_dir"
}

# Ejecutar función según argumento
case "$1" in
    setup)
        setup_project "$2"
        ;;
    backup)
        backup_dotfiles
        ;;
    *)
        echo "Uso: $0 {setup|backup} [argumentos]"
        exit 1
        ;;
esac
```

Hacerlo ejecutable y agregar a PATH:

```bash
chmod +x ~/dotfiles/scripts/mi-script.sh
ln -s ~/dotfiles/scripts/mi-script.sh ~/.local/bin/mi-script
```

### Agregar Módulos a Zsh

Crear `~/.config/zsh/modules/custom.zsh`:

```bash
# Módulo personalizado con funciones útiles

# Función: Crear y entrar a directorio
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Función: Backup de archivo
function backup() {
    cp "$1" "$1.backup-$(date +%Y%m%d-%H%M%S)"
}

# Función: Extract cualquier tipo de archivo
function extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "No sé cómo extraer '$1'..." ;;
        esac
    else
        echo "'$1' no es un archivo válido"
    fi
}

# Función: Servidor HTTP simple
function serve() {
    local port="${1:-8000}"
    python3 -m http.server "$port"
}

# Función: Quick commit de Git
function qc() {
    git add -A
    git commit -m "$1"
    git push
}

# Exportar funciones
export -f mkcd backup extract serve qc
```

Cargar en `~/.config/zsh/.zshrc`:

```bash
source ~/.config/zsh/modules/custom.zsh
```

### Personalizar Prompt de Git en Starship

```toml
# Personalización avanzada de Git status
[git_status]
format = '([\[$all_status$ahead_behind\]]($style) )'
conflicted = "⚔️ "
ahead = "⬆️ ×${count}"
behind = "⬇️ ×${count}"
diverged = "⬌ ⬆️ ×${ahead_count}⬇️ ×${behind_count}"
up_to_date = ""
untracked = "🤷×${count}"
stashed = "📦×${count}"
modified = "📝×${count}"
staged = "🗃️ ×${count}"
renamed = "🏷️ ×${count}"
deleted = "🗑️ ×${count}"
style = "bright-red bold"
```

---

## Tips de Personalización

### 1. Experimentar Sin Romper Config

```bash
# Antes de editar, hacer backup
cp ~/.tmux.conf ~/.tmux.conf.backup
cp -r ~/.config/nvim ~/.config/nvim.backup

# O usar Git branches
cd ~/dotfiles
git checkout -b experimental-config
# ... hacer cambios ...
git add -A
git commit -m "feat: experimental config"

# Si funciona:
git checkout main
git merge experimental-config

# Si no funciona:
git checkout main
git branch -D experimental-config
```

### 2. Sincronizar Customizations con Git

```bash
# Hacer commits de tus personalizaciones
cd ~/dotfiles
git add .
git commit -m "custom: agregar mis preferencias"
git push origin main
```

### 3. Compartir Config entre Máquinas

```bash
# En máquina nueva:
git clone https://github.com/tu-usuario/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow */

# Tus personalizaciones se aplican automáticamente
```

---

## Recursos Adicionales

- [Catppuccin Palettes](https://github.com/catppuccin/catppuccin) - Colores completos
- [Neovim Plugin Gallery](https://dotfyle.com/plugins) - Descubrir plugins
- [Awesome Tmux](https://github.com/rothgar/awesome-tmux) - Recursos de Tmux
- [Starship Config Examples](https://starship.rs/presets/) - Presets de Starship
- [Nerd Fonts](https://www.nerdfonts.com/) - Fonts con icons

---

**Recuerda**: La personalización es un proceso iterativo. Empieza con cambios pequeños y ajusta según tu workflow.

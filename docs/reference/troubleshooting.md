# Troubleshooting Guide

Guía completa de solución de problemas comunes para el entorno de desarrollo dotfiles.

## Tabla de Contenidos

1. [GNU Stow - Conflictos de Symlinks](#gnu-stow---conflictos-de-symlinks)
2. [Neovim - Plugins y LSP](#neovim---plugins-y-lsp)
3. [Zsh - Shell y Plugins](#zsh---shell-y-plugins)
4. [Tmux - Plugins y Sesiones](#tmux---plugins-y-sesiones)
5. [Starship - Prompt](#starship---prompt)
6. [Yazi - File Manager](#yazi---file-manager)
7. [WezTerm - Terminal](#wezterm---terminal)
8. [Git Delta - Diffs](#git-delta---diffs)
9. [Docker - Completion](#docker---completion)
10. [Integración - Vim-Tmux-Navigator](#integración---vim-tmux-navigator)
11. [Problemas Generales](#problemas-generales)

---

## GNU Stow - Conflictos de Symlinks

### Problema: "Existing target is not a symlink"

**Causa**: Ya existe un archivo o directorio en la ubicación de destino.

**Solución**:
```bash
# Verificar qué archivo causa conflicto
stow -n nvim  # Simular instalación

# Opción 1: Hacer backup del archivo existente
mv ~/.config/nvim ~/.config/nvim.backup

# Opción 2: Adoptar archivo existente (si es apropiado)
stow --adopt nvim

# Aplicar configuración
stow nvim
```

### Problema: "Directory is not empty"

**Causa**: El directorio de destino contiene archivos que no son parte de dotfiles.

**Solución**:
```bash
# Ver contenido del directorio
ls -la ~/.config/nvim

# Hacer backup de archivos no gestionados
cd ~/.config/nvim
mkdir ~/backup-nvim
cp -r ./* ~/backup-nvim/

# Limpiar directorio
rm -rf ~/.config/nvim

# Aplicar stow nuevamente
cd ~/dotfiles
stow nvim
```

### Problema: Symlinks rotos después de mover dotfiles

**Causa**: Los symlinks apuntan a la ubicación antigua del repositorio.

**Solución**:
```bash
# Eliminar symlinks viejos
stow -D nvim tmux zsh  # Desde ubicación antigua

# Mover repositorio
mv ~/old-location/dotfiles ~/dotfiles

# Recrear symlinks desde nueva ubicación
cd ~/dotfiles
stow nvim tmux zsh starship yazi wezterm
```

### Problema: Conflictos al actualizar

**Causa**: Archivos modificados localmente entran en conflicto con actualizaciones.

**Solución**:
```bash
# Verificar estado de git
git status

# Opción 1: Guardar cambios locales
git stash
git pull
git stash pop

# Opción 2: Reiniciar configuración
stow -R nvim  # Reinstalar paquete

# Opción 3: Snapshot antes de actualizar
./scripts/snapshot.sh create pre-update
git pull
stow -R nvim tmux zsh
```

---

## Neovim - Plugins y LSP

### Problema: Plugins no cargan al iniciar

**Causa**: lazy.nvim no está instalado o hay error en configuración.

**Solución**:
```bash
# Verificar instalación de lazy.nvim
ls -la ~/.local/share/nvim/lazy/lazy.nvim

# Si no existe, reinstalar Neovim completamente
rm -rf ~/.local/share/nvim ~/.cache/nvim
nvim  # Lazy.nvim se instalará automáticamente

# Verificar errores de sintaxis
nvim --headless "+Lazy! sync" +qa
```

### Problema: "E5108: Error executing lua"

**Causa**: Error de sintaxis en configuración Lua.

**Solución**:
```bash
# Ver logs de errores
nvim --headless "+messages" +qa

# Verificar archivo específico
luacheck ~/.config/nvim/init.lua

# Restaurar desde backup si es necesario
cd ~/dotfiles
git diff nvim/.config/nvim/init.lua
git checkout nvim/.config/nvim/init.lua
```

### Problema: LSP no funciona para lenguaje específico

**Causa**: Servidor LSP no instalado o mal configurado.

**Síntomas**:
```
No diagnostic information available
LSP not attached to buffer
```

**Solución**:
```vim
" Dentro de Neovim
:Mason  " Abrir gestor de LSP

" Verificar estado del servidor
:LspInfo

" Instalar servidor manualmente
:MasonInstall lua-language-server

" Reiniciar LSP
:LspRestart

" Verificar logs
:LspLog
```

### Problema: Treesitter highlighting no funciona

**Causa**: Parser no instalado para el lenguaje.

**Solución**:
```vim
" Ver parsers instalados
:TSInstallInfo

" Instalar parser específico
:TSInstall lua

" Reinstalar todos los parsers
:TSUpdate

" Verificar estado
:checkhealth nvim-treesitter
```

### Problema: Telescope no encuentra archivos

**Causa**: ripgrep o fd no instalados.

**Solución**:
```bash
# Verificar dependencias
which rg fd

# Instalar ripgrep y fd
# Arch Linux
sudo pacman -S ripgrep fd

# Ubuntu/Debian
sudo apt install ripgrep fd-find

# Verificar desde Neovim
nvim
:Telescope find_files
```

### Problema: LazyGit no abre en Neovim

**Causa**: LazyGit no instalado o no en PATH.

**Solución**:
```bash
# Verificar instalación
which lazygit

# Instalar LazyGit
# Arch Linux
sudo pacman -S lazygit

# Ubuntu/Debian
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin

# Verificar keybinding en Neovim
nvim ~/.config/nvim/lua/config/keymaps.lua
```

### Problema: Transparencia de fondo no funciona

**Causa**: Terminal no soporta transparencia o configuración incorrecta.

**Solución**:
```bash
# Verificar configuración de Neovim
nvim ~/.config/nvim/lua/plugins/colorscheme.lua

# Debería contener:
# vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
# vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

# Verificar terminal (WezTerm)
nvim ~/.config/wezterm/wezterm.lua

# Debería tener:
# config.window_background_opacity = 0.85

# Reiniciar terminal y Neovim
```

---

## Zsh - Shell y Plugins

### Problema: Zsh no es el shell por defecto

**Causa**: Shell por defecto no cambiado después de instalación.

**Síntomas**:
```bash
echo $SHELL  # Muestra /bin/bash
```

**Solución**:
```bash
# Verificar que zsh está instalado
which zsh

# Cambiar shell por defecto
chsh -s $(which zsh)

# Salir y volver a iniciar sesión
# O cerrar terminal y abrir nueva

# Verificar cambio
echo $SHELL  # Debería mostrar /usr/bin/zsh
```

### Problema: "command not found: autosuggestions"

**Causa**: Plugins de Zsh no inicializados como submódulos git.

**Solución**:
```bash
cd ~/dotfiles

# Inicializar submódulos
git submodule update --init --recursive

# Verificar que los plugins existen
ls -la zsh-plugins/.zsh/

# Debería mostrar:
# zsh-autosuggestions/
# zsh-syntax-highlighting/
# zsh-history-substring-search/

# Recargar Zsh
source ~/.config/zsh/.zshrc
```

### Problema: Syntax highlighting no funciona

**Causa**: Plugin cargado en orden incorrecto (debe ser último).

**Solución**:
```bash
# Editar .zshrc
nvim ~/.config/zsh/.zshrc

# Verificar orden de carga (al final del archivo):
# 1. zsh-autosuggestions
# 2. zsh-history-substring-search
# 3. zsh-syntax-highlighting (DEBE SER ÚLTIMO)
# 4. eval "$(starship init zsh)" (DEBE SER MUY ÚLTIMO)

# Recargar configuración
source ~/.config/zsh/.zshrc
```

### Problema: Zoxide no funciona ("command not found: z")

**Causa**: Zoxide no instalado o no inicializado.

**Solución**:
```bash
# Verificar instalación
which zoxide

# Instalar zoxide
# Arch Linux
sudo pacman -S zoxide

# Ubuntu/Debian
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# Verificar que está en .zshrc
grep "zoxide init" ~/.config/zsh/.zshrc

# Debería contener:
# eval "$(zoxide init zsh)"

# Recargar
source ~/.config/zsh/.zshrc
```

### Problema: Aliases no funcionan

**Causa**: Archivos de aliases no cargados o ruta incorrecta.

**Solución**:
```bash
# Verificar que archivos existen
ls -la ~/.config/zsh/aliases/

# Verificar carga en .zshrc
nvim ~/.config/zsh/.zshrc

# Debería contener:
# source "${ZDOTDIR}/aliases/tools.zsh"
# source "${ZDOTDIR}/aliases/tmux.zsh"
# source "${ZDOTDIR}/aliases/git.zsh"
# source "${ZDOTDIR}/aliases/gh.zsh"
# source "${ZDOTDIR}/aliases/docker.zsh"

# Probar carga manual
source ~/.config/zsh/aliases/git.zsh
alias | grep git  # Verificar que aparecen aliases

# Recargar completo
source ~/.config/zsh/.zshrc
```

### Problema: Historial de comandos no funciona

**Causa**: Archivo de historial no creado o permisos incorrectos.

**Solución**:
```bash
# Crear archivo de historial si no existe
touch ~/.config/zsh/.zsh_history

# Verificar permisos
chmod 600 ~/.config/zsh/.zsh_history

# Verificar configuración
nvim ~/.config/zsh/config/history.zsh

# Debería contener:
# HISTFILE="${ZDOTDIR}/.zsh_history"
# HISTSIZE=50000
# SAVEHIST=50000

# Recargar
source ~/.config/zsh/.zshrc
```

---

## Tmux - Plugins y Sesiones

### Problema: TPM (Tmux Plugin Manager) no funciona

**Causa**: TPM no instalado o plugins no inicializados.

**Síntomas**:
```
Plugins no cargan
Prefix + I no hace nada
```

**Solución**:
```bash
# Instalar TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Verificar que está en .tmux.conf
grep "tpm" ~/.tmux.conf

# Debería tener al final:
# run '~/.tmux/plugins/tpm/tpm'

# Recargar configuración
tmux source-file ~/.tmux.conf

# Instalar plugins
# Dentro de tmux, presionar: Ctrl+s (prefix) + Shift+I
```

### Problema: "Invalid option: default-terminal"

**Causa**: Versión de Tmux muy antigua.

**Solución**:
```bash
# Verificar versión
tmux -V  # Debería ser >= 3.0

# Actualizar Tmux
# Arch Linux
sudo pacman -S tmux

# Ubuntu/Debian (puede requerir PPA)
sudo apt update
sudo apt install tmux

# Si versión sigue antigua, compilar desde fuente
# Ver: https://github.com/tmux/tmux/wiki/Installing
```

### Problema: Vim-tmux-navigator no funciona

**Causa**: Plugin no instalado en Neovim o Tmux.

**Solución**:
```bash
# Verificar en Neovim
nvim
:Lazy  # Buscar vim-tmux-navigator

# Si no está, agregarlo a plugins
nvim ~/.config/nvim/lua/plugins/ui.lua

# Verificar en Tmux
grep "vim-tmux-navigator" ~/.tmux.conf

# Debería contener:
# set -g @plugin 'christoomey/vim-tmux-navigator'

# Reinstalar plugins de Tmux
# Dentro de tmux: Prefix + Shift+I

# Probar navegación con Ctrl+h/j/k/l
```

### Problema: Sesiones no persisten después de reinicio

**Causa**: Tmux Resurrect/Continuum no configurados correctamente.

**Solución**:
```bash
# Verificar plugins en .tmux.conf
grep "resurrect\|continuum" ~/.tmux.conf

# Debería contener:
# set -g @plugin 'tmux-plugins/tmux-resurrect'
# set -g @plugin 'tmux-plugins/tmux-continuum'
# set -g @continuum-restore 'on'

# Guardar sesión manualmente
# Prefix + Ctrl+s

# Restaurar sesión manualmente
# Prefix + Ctrl+r

# Verificar auto-guardado
tmux show-options -g | grep continuum
```

### Problema: Prefix no funciona (Ctrl+s no responde)

**Causa**: Keybinding de terminal captura Ctrl+s antes de Tmux.

**Solución**:
```bash
# Deshabilitar XON/XOFF (flow control)
stty -ixon

# Agregar a .zshrc para persistencia
echo "stty -ixon" >> ~/.config/zsh/.zshrc

# Recargar shell
source ~/.config/zsh/.zshrc

# Probar Prefix nuevamente
# Ctrl+s + | (split horizontal)
```

### Problema: Colores incorrectos en Tmux

**Causa**: Terminal no soporta 256 colores o configuración incorrecta.

**Solución**:
```bash
# Verificar soporte de colores del terminal
echo $TERM  # Debería ser xterm-256color o tmux-256color

# Verificar configuración de Tmux
grep "default-terminal" ~/.tmux.conf

# Debería contener:
# set-option -sa terminal-overrides ",xterm*:Tc"
# set -g default-terminal "screen-256color"

# Probar colores
curl -s https://gist.githubusercontent.com/lifepillar/09a44b8cf0f9397465614e622979107f/raw/24-bit-color.sh | bash

# Reiniciar Tmux completamente
tmux kill-server
tmux
```

---

## Starship - Prompt

### Problema: Prompt no aparece o muestra símbolos raros

**Causa**: Starship no instalado o Nerd Font no configurada.

**Síntomas**:
```
Cuadrados o signos de interrogación en prompt
Prompt de Zsh por defecto (simple)
```

**Solución**:
```bash
# Verificar instalación de Starship
which starship

# Instalar Starship
curl -sS https://starship.rs/install.sh | sh

# Verificar que está en .zshrc
grep "starship init" ~/.config/zsh/.zshrc

# Debería estar AL FINAL:
# eval "$(starship init zsh)"

# Instalar Nerd Font (MesloLGS NF recomendada)
# Descargar desde: https://www.nerdfonts.com/
# O usar script:
cd ~/Downloads
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Meslo.zip
unzip Meslo.zip -d ~/.local/share/fonts
fc-cache -fv

# Configurar Nerd Font en WezTerm
nvim ~/.config/wezterm/wezterm.lua

# Debería tener:
# config.font = wezterm.font('MesloLGS Nerd Font Mono')

# Reiniciar terminal y shell
```

### Problema: Módulos de Starship no aparecen

**Causa**: Configuración de Starship no cargada o deshabilitada.

**Solución**:
```bash
# Verificar archivo de configuración
ls -la ~/.config/starship.toml

# Si no existe, copiar desde dotfiles
cd ~/dotfiles
stow starship

# Ver configuración actual
starship config

# Probar módulos específicos
starship module git_branch
starship module nodejs

# Verificar formato en starship.toml
nvim ~/.config/starship.toml

# Debería tener sección [format]:
# format = """
# [┌───────────────────>](bold green)
# [│](bold green)$directory$rust$package
# ...
# """
```

### Problema: Git status muy lento en repositorios grandes

**Causa**: Starship escanea todo el repositorio para mostrar estado.

**Solución**:
```bash
# Editar starship.toml
nvim ~/.config/starship.toml

# Agregar o modificar sección [git_status]:
[git_status]
disabled = false
ahead = "⇡${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
behind = "⇣${count}"
# Deshabilitar escaneo de archivos no rastreados
untracked_count.enabled = false
stashed = ""

# O deshabilitar git status completamente en repos grandes
[git_status]
disabled = true

# Recargar shell
source ~/.config/zsh/.zshrc
```

### Problema: Tema Catppuccin no se aplica correctamente

**Causa**: Colores del tema no configurados correctamente.

**Solución**:
```bash
# Verificar paleta en starship.toml
nvim ~/.config/starship.toml

# Debería tener sección [palettes.catppuccin_mocha]:
[palettes.catppuccin_mocha]
rosewater = "#f5e0dc"
flamingo = "#f2cdcd"
pink = "#f5c2e7"
# ... resto de colores

# Verificar que está activada:
palette = "catppuccin_mocha"

# Recargar
source ~/.config/zsh/.zshrc
```

---

## Yazi - File Manager

### Problema: Yazi no abre o "command not found"

**Causa**: Yazi no instalado correctamente.

**Solución**:
```bash
# Verificar instalación
which yazi

# Instalar Yazi
# Arch Linux
sudo pacman -S yazi

# Ubuntu/Debian (compilar desde fuente)
cargo install --locked yazi-fm

# Verificar versión
yazi --version
```

### Problema: Keybindings de Vim no funcionan

**Causa**: Configuración de keymap no cargada.

**Solución**:
```bash
# Verificar archivos de configuración
ls -la ~/.config/yazi/

# Debería tener:
# keymap.toml
# yazi.toml
# theme.toml

# Aplicar configuración con Stow
cd ~/dotfiles
stow yazi

# Verificar keymap.toml
nvim ~/.config/yazi/keymap.toml

# Debería tener [manager] con:
# { on = [ "h" ], exec = "leave", desc = "Go back" }
# { on = [ "j" ], exec = "arrow 1", desc = "Move down" }
# { on = [ "k" ], exec = "arrow -1", desc = "Move up" }
# { on = [ "l" ], exec = "enter", desc = "Enter directory" }
```

### Problema: Vista previa de archivos no funciona

**Causa**: Dependencias para preview no instaladas.

**Solución**:
```bash
# Instalar dependencias de preview
# Arch Linux
sudo pacman -S bat ffmpegthumbnailer fd ripgrep fzf poppler imagemagick

# Ubuntu/Debian
sudo apt install bat fd-find ripgrep fzf poppler-utils imagemagick

# Verificar plugins en yazi.toml
nvim ~/.config/yazi/yazi.toml

# Probar preview abriendo archivo en Yazi
yazi
# Navegar a un archivo de texto/imagen
```

### Problema: Tema Catppuccin no se aplica

**Causa**: theme.toml no configurado o mal ubicado.

**Solución**:
```bash
# Verificar theme.toml
nvim ~/.config/yazi/theme.toml

# Debería tener colores Catppuccin Mocha:
# [flavor]
# use = "mocha"

# Si no existe, copiar desde dotfiles
cd ~/dotfiles
stow -R yazi

# Reiniciar Yazi
```

---

## WezTerm - Terminal

### Problema: WezTerm no encuentra configuración

**Causa**: Archivo wezterm.lua no en ubicación esperada.

**Síntomas**:
```
WezTerm usa configuración por defecto
No aparece fondo transparente
```

**Solución**:
```bash
# Verificar ubicación del archivo
ls -la ~/.config/wezterm/wezterm.lua

# Aplicar con Stow
cd ~/dotfiles
stow wezterm

# Verificar que WezTerm lo encuentra
wezterm show-config

# Si hay errores de sintaxis Lua:
lua -c ~/.config/wezterm/wezterm.lua
```

### Problema: Transparencia no funciona

**Causa**: Compositor de ventanas no activo (Linux).

**Solución**:
```bash
# Verificar configuración de transparencia
nvim ~/.config/wezterm/wezterm.lua

# Debería tener:
# config.window_background_opacity = 0.85

# En Linux, instalar compositor
# Para X11:
sudo pacman -S picom  # Arch
sudo apt install picom  # Ubuntu

# Iniciar compositor
picom --config ~/.config/picom/picom.conf &

# Agregar a autostart (i3, bspwm, etc.)
echo "exec --no-startup-id picom" >> ~/.config/i3/config

# Reiniciar WezTerm
```

### Problema: Nerd Font no se muestra correctamente

**Causa**: Font no instalada o no configurada en WezTerm.

**Solución**:
```bash
# Instalar Nerd Font (ver sección Starship arriba)

# Verificar configuración de font
nvim ~/.config/wezterm/wezterm.lua

# Debería tener:
# config.font = wezterm.font('MesloLGS Nerd Font Mono')
# config.font_size = 11.0

# Listar fonts disponibles
fc-list | grep -i "Nerd Font"

# Probar font diferente si no funciona:
# config.font = wezterm.font('JetBrainsMono Nerd Font')

# Reiniciar WezTerm
```

### Problema: Quick Select no funciona

**Causa**: Keybinding no configurado o conflicto.

**Solución**:
```bash
# Verificar configuración de Quick Select
nvim ~/.config/wezterm/wezterm.lua

# Debería tener:
# config.keys = {
#   {
#     key = 'Space',
#     mods = 'CTRL|SHIFT',
#     action = wezterm.action.QuickSelect,
#   },
# }

# Probar keybinding: Ctrl+Shift+Space
# Debería mostrar hints para seleccionar URLs/paths

# Verificar patrones de Quick Select
# config.quick_select_patterns = {
#   'https?://\\S+',
#   '\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}\\b',
# }
```

---

## Git Delta - Diffs

### Problema: Delta no se activa en git diff

**Causa**: Git no configurado para usar Delta como pager.

**Solución**:
```bash
# Verificar instalación de Delta
which delta

# Instalar Delta
# Arch Linux
sudo pacman -S git-delta

# Ubuntu/Debian
wget https://github.com/dandavison/delta/releases/download/0.16.5/git-delta_0.16.5_amd64.deb
sudo dpkg -i git-delta_0.16.5_amd64.deb

# Verificar configuración en .gitconfig
nvim ~/.gitconfig

# Debería tener:
# [core]
#     pager = delta
# [interactive]
#     diffFilter = delta --color-only
# [delta]
#     navigate = true
#     line-numbers = true
#     side-by-side = true

# Probar Delta
git diff HEAD~1
```

### Problema: Tema Catppuccin no se aplica en Delta

**Causa**: Feature catppuccin-mocha no configurado.

**Solución**:
```bash
# Editar .gitconfig
nvim ~/.gitconfig

# Agregar o verificar secciones:
[delta]
    features = catppuccin-mocha
    navigate = true
    side-by-side = true
    line-numbers = true

[delta "catppuccin-mocha"]
    minus-style = syntax "#442d30"
    plus-style = syntax "#2e3d32"
    minus-emph-style = syntax "#5e2e34"
    plus-emph-style = syntax "#37503a"
    map-styles = "bold purple => syntax #3e2e49, bold cyan => syntax "#2a3e4a"

# Probar colores
git diff HEAD~1
```

### Problema: Side-by-side no funciona correctamente

**Causa**: Terminal muy estrecho o configuración incorrecta.

**Solución**:
```bash
# Verificar ancho de terminal
tput cols  # Debería ser >= 160 para side-by-side cómodo

# Ajustar configuración de Delta
nvim ~/.gitconfig

# Modificar:
[delta]
    side-by-side = true
    width = 180  # Ajustar según tu terminal
    max-line-length = 512

# O deshabilitar side-by-side para terminales pequeñas
[delta]
    side-by-side = false
    line-numbers = true
```

---

## Docker - Completion

### Problema: Autocompletado de Docker no funciona

**Causa**: Scripts de completion no cargados en Zsh.

**Solución**:
```bash
# Verificar archivos de completion
ls -la ~/.config/docker/

# Si no existen, aplicar con Stow
cd ~/dotfiles
stow docker

# Verificar carga en .zshrc
nvim ~/.config/zsh/.zshrc

# Debería tener:
# fpath=(~/.config/docker $fpath)
# autoload -Uz compinit && compinit

# Si no está, agregarlo antes de cargar plugins

# Recargar Zsh
source ~/.config/zsh/.zshrc

# Probar completion
docker <TAB>
docker-compose <TAB>
```

### Problema: Aliases de Docker no funcionan

**Causa**: Archivo docker.zsh no cargado.

**Solución**:
```bash
# Verificar archivo
ls -la ~/.config/zsh/aliases/docker.zsh

# Verificar carga en .zshrc
grep "docker.zsh" ~/.config/zsh/.zshrc

# Debería tener:
# source "${ZDOTDIR}/aliases/docker.zsh"

# Cargar manualmente para probar
source ~/.config/zsh/aliases/docker.zsh

# Verificar aliases
alias | grep docker

# Recargar Zsh completo
source ~/.config/zsh/.zshrc
```

---

## Integración - Vim-Tmux-Navigator

### Problema: Ctrl+h/j/k/l no funciona entre Neovim y Tmux

**Causa**: Plugin no instalado en uno de los dos (Neovim o Tmux).

**Solución**:

**Paso 1: Verificar en Neovim**
```vim
" Dentro de Neovim
:Lazy

" Buscar: vim-tmux-navigator
" Debería estar instalado

" Si no está:
" Editar archivo de plugins
:e ~/.config/nvim/lua/plugins/ui.lua

" Agregar:
{
  'christoomey/vim-tmux-navigator',
  lazy = false,
}

" Sincronizar plugins
:Lazy sync
```

**Paso 2: Verificar en Tmux**
```bash
# Verificar en .tmux.conf
grep "vim-tmux-navigator" ~/.tmux.conf

# Debería contener:
# set -g @plugin 'christoomey/vim-tmux-navigator'

# Si no está, agregarlo:
echo "set -g @plugin 'christoomey/vim-tmux-navigator'" >> ~/.tmux.conf

# Recargar Tmux
tmux source-file ~/.tmux.conf

# Instalar plugin
# Dentro de tmux: Prefix + Shift+I
```

**Paso 3: Probar navegación**
```bash
# Abrir Neovim en Tmux
tmux
nvim

# Split vertical en Neovim
:vsplit

# Split horizontal en Tmux
# Prefix + -

# Probar navegación con Ctrl+h/j/k/l
# Debería moverse entre splits de Neovim y panes de Tmux sin problema
```

### Problema: LazyGit en Neovim floating window no responde

**Causa**: Conflicto de keybindings o terminal no soporta bien floating.

**Solución**:
```bash
# Verificar keybinding en Neovim
nvim ~/.config/nvim/lua/config/keymaps.lua

# Buscar configuración de LazyGit:
# vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "LazyGit" })

# Probar LazyGit en nueva ventana de terminal
# Editar configuración de LazyGit plugin
nvim ~/.config/nvim/lua/plugins/tools.lua

# Modificar opciones:
{
  'kdheepak/lazygit.nvim',
  cmd = 'LazyGit',
  config = function()
    vim.g.lazygit_floating_window_winblend = 0
    vim.g.lazygit_floating_window_scaling_factor = 0.9
  end,
}

# Reiniciar Neovim y probar
```

---

## Problemas Generales

### Problema: Comandos modernos no funcionan (eza, bat, fd, rg)

**Causa**: Herramientas modernas no instaladas.

**Solución**:
```bash
# Verificar qué falta
which eza bat fd rg zoxide fzf

# Instalar todas las herramientas modernas
# Arch Linux
sudo pacman -S eza bat fd ripgrep zoxide fzf

# Ubuntu/Debian
sudo apt install bat fd-find ripgrep fzf

# eza (no en repos oficiales Ubuntu)
cargo install eza

# zoxide
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# Verificar aliases en .zshrc
grep "eza\|bat" ~/.config/zsh/aliases/tools.zsh

# Recargar shell
source ~/.config/zsh/.zshrc
```

### Problema: "Permission denied" al ejecutar scripts

**Causa**: Scripts no tienen permisos de ejecución.

**Solución**:
```bash
# Dar permisos de ejecución a scripts
chmod +x ~/dotfiles/scripts/bootstrap.sh
chmod +x ~/dotfiles/scripts/health-check.sh
chmod +x ~/dotfiles/scripts/snapshot.sh

# O dar permisos a todos los scripts
chmod +x ~/dotfiles/scripts/*.sh

# Verificar permisos
ls -la ~/dotfiles/scripts/
```

### Problema: Cambios en dotfiles no se reflejan

**Causa**: Symlinks no actualizados después de cambios en repositorio.

**Solución**:
```bash
# Verificar estado de symlinks
ls -la ~/.config/nvim  # Debería mostrar symlink a ~/dotfiles/nvim/.config/nvim

# Reinstalar configuración con Stow
cd ~/dotfiles
stow -R nvim tmux zsh

# Verificar cambios de git
git status
git diff

# Recargar configuraciones
source ~/.config/zsh/.zshrc  # Zsh
tmux source-file ~/.tmux.conf  # Tmux
# Reiniciar Neovim
```

### Problema: Configuración funciona en un sistema pero no en otro

**Causa**: Diferencias en versiones de software o dependencias faltantes.

**Solución**:
```bash
# Ejecutar health check
cd ~/dotfiles
./scripts/health-check.sh

# Revisar secciones con ❌ o ⚠️
# Instalar dependencias faltantes según el reporte

# Verificar versiones de software crítico
nvim --version   # >= 0.9.0 recomendado
tmux -V          # >= 3.0 recomendado
zsh --version    # >= 5.8 recomendado

# Actualizar software si es necesario
# Arch Linux
sudo pacman -Syu

# Ubuntu/Debian
sudo apt update && sudo apt upgrade
```

### Problema: Colores se ven mal en todos los servicios

**Causa**: Terminal no soporta 256 colores o TrueColor.

**Solución**:
```bash
# Verificar soporte de colores
echo $TERM

# Probar TrueColor
curl -s https://gist.githubusercontent.com/lifepillar/09a44b8cf0f9397465614e622979107f/raw/24-bit-color.sh | bash

# Configurar TERM correctamente
# En .zshrc
export TERM=xterm-256color

# En .tmux.conf
set-option -sa terminal-overrides ",xterm*:Tc"
set -g default-terminal "screen-256color"

# En WezTerm config
config.term = "xterm-256color"

# Reiniciar terminal y aplicaciones
```

### Problema: Quiero volver a configuración anterior

**Causa**: Cambios recientes causaron problemas.

**Solución**:
```bash
# Opción 1: Restaurar desde snapshot
cd ~/dotfiles
./scripts/snapshot.sh list
./scripts/snapshot.sh rollback dotfiles_manual_YYYY-MM-DD_HH-MM-SS.tar.gz

# Opción 2: Revertir commits de git
git log --oneline -10  # Ver últimos commits
git revert <commit-hash>  # Revertir commit específico

# Opción 3: Restaurar desde stash
git stash list
git stash apply stash@{0}

# Opción 4: Hard reset (CUIDADO: pierde cambios)
git reset --hard HEAD~1  # Volver 1 commit atrás
```

---

## Recursos Adicionales

### Documentación de Referencia

- **GNU Stow**: [docs/ARCHITECTURE.md](../ARCHITECTURE.md)
- **Scripts**: [docs/reference/scripts.md](./scripts.md)
- **Aliases**: [docs/reference/aliases.md](./aliases.md)
- **Servicios**: [docs/services/](../services/)

### Comandos de Diagnóstico

```bash
# Health check completo
~/dotfiles/scripts/health-check.sh

# Verificar configuraciones específicas
nvim --headless "+checkhealth" +qa
tmux show-options -g
starship config

# Logs de errores
journalctl --user -xe  # Systemd logs
dmesg | tail           # Kernel logs
```

### Pedir Ayuda

Si ninguna solución funciona:

1. **Crear snapshot antes de cambios**: `./scripts/snapshot.sh create before-fix`
2. **Documentar el problema**: Copiar mensajes de error exactos
3. **Verificar versiones**: `neovim --version`, `tmux -V`, etc.
4. **Revisar logs**: Revisar logs de la aplicación problemática
5. **Consultar documentación**: Ver `docs/services/<servicio>.md`
6. **Abrir issue**: En el repositorio con información completa

---

## Quick Reference - Comandos de Emergencia

```bash
# Reinicio completo de configuraciones
cd ~/dotfiles
stow -D nvim tmux zsh starship yazi wezterm docker git claude
rm -rf ~/.local/share/nvim ~/.cache/nvim ~/.tmux/plugins
stow nvim tmux zsh starship yazi wezterm docker git claude
nvim  # Plugins se reinstalarán automáticamente

# Backup de emergencia
./scripts/snapshot.sh create emergency-backup

# Restaurar desde backup
./scripts/snapshot.sh rollback <archivo.tar.gz>

# Health check rápido
./scripts/health-check.sh

# Actualizar submódulos de git
git submodule update --init --recursive
git submodule update --remote

# Verificar symlinks
find ~ -maxdepth 3 -type l -ls | grep dotfiles
```

---

**Última actualización**: 2026-01-06

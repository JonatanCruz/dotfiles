# Getting Started - Primeros Pasos con Dotfiles

Guía de inicio rápido para configurar y usar este entorno de desarrollo.

## Instalación Rápida

### Prerrequisitos

```bash
# Verificar que tienes Git instalado
git --version

# Verificar que tienes GNU Stow instalado
stow --version

# Si no tienes Stow, instalarlo:
# Ubuntu/Debian:
sudo apt install stow

# Arch Linux:
sudo pacman -S stow

# macOS:
brew install stow
```

### Clonar el Repositorio

```bash
# Clonar dotfiles en tu home
cd ~
git clone https://github.com/tu-usuario/dotfiles.git

# Inicializar submodulos (plugins de Zsh)
cd dotfiles
git submodule update --init --recursive
```

### Aplicar Configuraciones con Stow

```bash
# Desde el directorio ~/dotfiles

# Aplicar TODO (opción recomendada)
stow */

# O aplicar solo servicios específicos:
stow nvim      # Neovim
stow tmux      # Tmux
stow zsh       # Zsh shell
stow starship  # Starship prompt
stow yazi      # Yazi file manager
stow wezterm   # WezTerm terminal
stow git       # Git configuration
stow docker    # Docker completion
stow claude    # Claude Code framework
```

**¿Qué hace Stow?**
- Crea enlaces simbólicos desde `~/dotfiles/servicio/.config/` → `~/.config/`
- Ejemplo: `~/dotfiles/nvim/.config/nvim/` → `~/.config/nvim/`
- Los cambios en el repo se reflejan automáticamente en tu sistema

## Primer Uso por Herramienta

### 1. Zsh - Shell Interactivo

```bash
# Cambiar Zsh como shell por defecto
chsh -s $(which zsh)

# Cerrar sesión y volver a entrar

# Verificar que Zsh es tu shell
echo $SHELL  # Debe mostrar: /usr/bin/zsh o /bin/zsh

# Verificar módulos cargados
ls ~/.config/zsh/modules/

# Probar aliases
gst        # git status (alias de Git)
ll         # eza --long --icons (alias mejorado de ls)
z docs     # Saltar a directorio docs con zoxide
```

**Primeros Comandos:**
- `Ctrl+r` - Buscar en historial de comandos (fuzzy search con fzf)
- `jk` en modo INSERT - Salir a modo NORMAL (Vi mode)
- `v` en modo NORMAL - Abrir comando en Neovim para edición compleja

### 2. Starship - Prompt Inteligente

```bash
# Verificar que Starship está activo
starship --version

# El prompt debe mostrar:
# [directorio] [git branch] [duración comando] [hora]
# Con colores Catppuccin Mocha (purple/cyan)
```

**Símbolos Comunes:**
- `✓` - Git branch actualizada
- `!2` - 2 archivos modificados
- `?3` - 3 archivos sin track
- `⇡1` - 1 commit adelante del remote
- ` 16.0.0` - Node.js versión detectada

### 3. Tmux - Multiplexor de Terminal

```bash
# Iniciar Tmux
tmux

# Prefijo: Ctrl+s (NO Ctrl+b)

# Comandos esenciales:
Ctrl+s + |    # Split vertical
Ctrl+s + -    # Split horizontal
Ctrl+s + h/j/k/l    # Navegar entre paneles (Vim-style)
Ctrl+s + r    # Recargar configuración
Ctrl+s + d    # Detach de sesión

# Instalar plugins (primera vez)
# Presiona: Ctrl+s + I (Shift+i)

# Crear sesión con nombre
tmux new -s desarrollo

# Listar sesiones
tmux ls

# Adjuntar a sesión
tmux attach -t desarrollo
```

**Gestión de Sesiones con SessionX:**
- `Ctrl+s + s` - Abrir SessionX (fuzzy finder de sesiones)
- `Ctrl+s + Ctrl+x` - Matar sesión actual

### 4. Neovim - Editor Modal

```bash
# Iniciar Neovim
nvim

# Primera apertura:
# - lazy.nvim se auto-instala
# - Todos los plugins se auto-instalan
# - Puede tomar 1-2 minutos

# Verificar instalación:
:Lazy             # Ver estado de plugins
:checkhealth      # Diagnóstico completo
:Mason            # Gestionar LSP servers
```

**Primeros Pasos en Neovim:**

1. **Navegación Básica** (modo NORMAL):
   - `h/j/k/l` - Izquierda/Abajo/Arriba/Derecha
   - `Space + e` - Abrir árbol de archivos (nvim-tree)
   - `Space + ff` - Buscar archivos (Telescope)
   - `Space + fg` - Buscar texto en proyecto

2. **Abrir Archivo**:
   - `:e archivo.js` - Abrir/crear archivo
   - `Space + w` - Guardar
   - `Space + q` - Cerrar

3. **Edición**:
   - `i` - Entrar a modo INSERT
   - `ESC` o `jk` - Volver a modo NORMAL
   - `dd` - Borrar línea
   - `yy` - Copiar línea
   - `p` - Pegar

4. **LSP (Autocompletado y Diagnósticos)**:
   - `K` - Hover documentation
   - `gd` - Go to definition
   - `Space + rn` - Rename symbol
   - `]d` / `[d` - Siguiente/Anterior diagnóstico

5. **LazyGit Integration**:
   - `Space + gg` - Abrir LazyGit en Neovim

### 5. Yazi - File Manager

```bash
# Abrir Yazi
yazi

# Navegación Vim-style:
h    # Directorio padre
j/k  # Mover cursor arriba/abajo
l    # Entrar a directorio / Abrir archivo
Enter    # Abrir archivo con app por defecto

# Operaciones de archivo:
y    # Copiar
d    # Cortar
p    # Pegar
r    # Renombrar
Space    # Seleccionar múltiples
v    # Modo visual

# Shell integration:
cd $(yazi --cwd-file=/tmp/yazi-cwd)
# O crear alias en .zshrc:
alias yz='cd $(yazi --cwd-file=/tmp/yazi-cwd)'
```

### 6. WezTerm - Terminal Emulator

```bash
# Abrir WezTerm
wezterm

# Keybindings esenciales:
Cmd+T         # Nueva tab
Cmd+W         # Cerrar tab
Cmd+[número]  # Cambiar a tab N
Cmd+Shift+Space    # Quick Select (seleccionar paths, IPs, UUIDs)

# Características automáticas:
# - GPU acceleration (120 FPS con WebGPU)
# - Hyperlinks clickeables (Cmd+click en URLs)
# - Opacity 0.85 (transparencia configurada)
```

## Workflow Básico: Neovim + Tmux

Este es el workflow recomendado para desarrollo:

```bash
# 1. Iniciar Tmux con sesión de proyecto
tmux new -s mi-proyecto

# 2. Navegar a tu proyecto
cd ~/proyectos/mi-proyecto

# 3. Split en 3 paneles:
# Panel 1 (arriba izquierda): Neovim
# Panel 2 (arriba derecha): Terminal para comandos
# Panel 3 (abajo completo): Servidor de desarrollo

# Crear layout:
Ctrl+s + |    # Split vertical (crea panel derecho)
Ctrl+s + -    # Split horizontal en panel derecho (crea panel abajo)

# 4. En panel 1 (arriba izquierda):
nvim .

# 5. En panel 2 (arriba derecha):
# Ejecutar comandos Git, npm, docker, etc.

# 6. En panel 3 (abajo):
npm run dev    # O tu comando de servidor

# 7. Navegar entre paneles:
Ctrl+h/j/k/l    # Navegación seamless entre Neovim splits y Tmux panes
```

**Ventaja de este Workflow:**
- **Vim-tmux-navigator**: Usa `Ctrl+h/j/k/l` para navegar entre splits de Neovim y panes de Tmux sin pensar
- **Persistencia**: Detach de Tmux (`Ctrl+s + d`) y tu sesión queda guardada
- **LazyGit en Neovim**: `Space + gg` abre LazyGit integrado

## Configuración Inicial

### Git Configuration

```bash
# Configurar tu identidad (IMPORTANTE: requerido para commits)
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"

# Verificar configuración de Delta
git config --get core.pager    # Debe mostrar: delta

# Probar Delta
git diff    # Verás side-by-side con colores Catppuccin
```

### Neovim LSP Servers

Los LSP servers se instalan automáticamente con Mason, pero puedes agregar más:

```vim
# En Neovim:
:Mason

# Instalar servers adicionales (ejemplos):
# - typescript-language-server (JavaScript/TypeScript)
# - rust-analyzer (Rust)
# - gopls (Go)
# - pyright (Python)
# - lua-language-server (Lua)

# Lista completa en: lua/config/lsp_servers.lua
```

### Agregar Aliases Personalizados

```bash
# Editar archivo de aliases de Zsh
nvim ~/.config/zsh/aliases/personal.zsh

# Agregar tus aliases:
alias micomando='comando largo que uso mucho'
alias dev='cd ~/proyectos && npm run dev'

# Recargar Zsh
source ~/.config/zsh/.zshrc
```

## Solución de Problemas Comunes

### Zsh no es mi shell por defecto

```bash
# Cambiar shell por defecto
chsh -s $(which zsh)

# Si falla, verificar que Zsh está en /etc/shells
cat /etc/shells | grep zsh

# Si no está, agregarlo:
which zsh | sudo tee -a /etc/shells
```

### Starship no aparece

```bash
# Verificar instalación
which starship

# Reinstalar si es necesario:
curl -sS https://starship.rs/install.sh | sh

# Verificar que está en .zshrc (debe ser ÚLTIMA línea)
tail -1 ~/.config/zsh/.zshrc
# Debe mostrar: eval "$(starship init zsh)"
```

### Tmux plugins no se instalan

```bash
# Verificar TPM (Tmux Plugin Manager)
ls ~/.tmux/plugins/tpm

# Si no existe, instalar:
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Recargar Tmux config
tmux source ~/.tmux.conf

# Instalar plugins: Ctrl+s + I (Shift+i)
```

### Neovim plugins no cargan

```bash
# Reinstalación completa de Neovim
rm -rf ~/.local/share/nvim ~/.cache/nvim

# Abrir Neovim (plugins se auto-instalan)
nvim

# Verificar salud
:checkhealth
```

### Conflictos de Stow

```bash
# Si Stow reporta conflictos (archivos ya existen)

# Opción 1: Hacer backup y eliminar
mv ~/.config/nvim ~/.config/nvim.backup

# Opción 2: Forzar (NO recomendado, puede sobrescribir)
stow --adopt nvim    # Adopta archivos existentes

# Re-aplicar Stow
stow nvim
```

## Próximos Pasos

Ahora que tienes todo configurado:

1. **Aprende Keybindings**: Lee [keybindings.md](keybindings.md) para dominar atajos
2. **Explora Workflows**: Ve [workflows.md](workflows.md) para flujos avanzados
3. **Personaliza**: Lee [customization.md](customization.md) para adaptar a tu gusto
4. **Documentación de Servicios**: Explora [../services/](../services/) para detalles de cada herramienta

## Comandos de Referencia Rápida

| Acción | Comando |
|--------|---------|
| Aplicar config con Stow | `stow nvim` |
| Reinstalar config | `stow -R nvim` |
| Remover config | `stow -D nvim` |
| Abrir Neovim | `nvim` |
| Iniciar Tmux | `tmux` |
| Abrir Yazi | `yazi` |
| Ver aliases de Git | `git config --get-regexp alias` |
| Ver plugins de Neovim | `:Lazy` |
| Ver LSP servers | `:Mason` |
| Recargar Zsh | `source ~/.zshrc` |

## Recursos Adicionales

- [Documentación de Servicios](../services/) - Guías completas por herramienta
- [Quick References](../reference/) - Aliases, scripts, troubleshooting
- [Advanced Topics](../advanced/) - Temas avanzados e integración
- [INSTALL.md](../INSTALL.md) - Guía de instalación detallada

---

¿Listo para empezar? Abre una terminal y ejecuta:

```bash
cd ~/dotfiles && stow */ && tmux new -s inicio && nvim
```

¡Bienvenido a tu nuevo entorno de desarrollo! 🚀

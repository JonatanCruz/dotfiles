# 🚀 Guía de Instalación Completa

Esta guía cubre la instalación completa del entorno de desarrollo dotfiles en Linux y macOS.

## 📋 Índice

- [Requisitos Previos](#requisitos-previos)
- [Instalación Automática (Recomendada)](#instalación-automática-recomendada)
- [Instalación Manual](#instalación-manual)
- [Post-Instalación](#post-instalación)
- [Verificación](#verificación)
- [Solución de Problemas](#solución-de-problemas)

## Requisitos Previos

### Dependencias Básicas

**Linux (Ubuntu/Debian)**:
```bash
sudo apt update
sudo apt install -y git stow curl wget zsh
```

**macOS**:
```bash
# Instalar Homebrew primero si no lo tienes
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Instalar dependencias
brew install git stow zsh
```

### Neovim (>= 0.9.0)

**Linux**:
```bash
# Opción 1: AppImage (recomendado para última versión)
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
sudo mv nvim.appimage /usr/local/bin/nvim

# Opción 2: Desde repositorio (puede ser versión antigua)
sudo apt install neovim
```

**macOS**:
```bash
brew install neovim
```

### Herramientas Modernas CLI (Recomendadas)

```bash
# Linux
sudo apt install -y ripgrep fd-find bat fzf

# macOS
brew install ripgrep fd bat fzf eza zoxide
```

## Instalación Automática (Recomendada)

El script `install.sh` automatiza todo el proceso con detección de conflictos y backups automáticos.

### 1. Clonar Repositorio

```bash
git clone --recurse-submodules https://github.com/tu-usuario/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Ejecutar Installer

```bash
./install.sh
```

### 3. Interacción del Installer

El installer te guiará paso a paso:

**Paso 1: Detección de OS**
```
Detected OS: Linux (Ubuntu 22.04)
```

**Paso 2: Verificación de Dependencias**
```
✓ git found
✓ stow found
✗ zsh not found - please install: sudo apt install zsh
```

**Paso 3: Selección de Paquetes**
```
Select packages to install:
[x] nvim    - Neovim configuration
[x] tmux    - Terminal multiplexer
[x] zsh     - Shell configuration
[ ] wezterm - WezTerm (macOS only)
[x] starship - Prompt configuration
```

**Paso 4: Detección de Conflictos**
```
⚠ Conflicts detected:
- ~/.config/nvim already exists
- ~/.zshrc already exists

Create backups? (y/N): y
```

**Paso 5: Instalación**
```
Creating backups in ~/.dotfiles-backup...
✓ Backed up .config/nvim
✓ Backed up .zshrc

Installing packages...
✓ nvim installed
✓ tmux installed
✓ zsh installed
✓ starship installed

Installation complete!
```

## Instalación Manual

Si prefieres control total sobre el proceso:

### 1. Clonar Repositorio

```bash
git clone --recurse-submodules https://github.com/tu-usuario/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Hacer Backup de Configuraciones Existentes

```bash
# Crear directorio de backups
mkdir -p ~/.dotfiles-backup

# Backup de configuraciones existentes
mv ~/.config/nvim ~/.dotfiles-backup/nvim.backup
mv ~/.config/tmux ~/.dotfiles-backup/tmux.backup
mv ~/.zshrc ~/.dotfiles-backup/.zshrc.backup
```

### 3. Aplicar Paquetes con Stow

```bash
# Instalar paquetes individuales
stow nvim
stow tmux
stow zsh
stow starship
stow git
stow docker

# O instalar todos a la vez
stow */
```

### 4. Actualizar Submodulos de Zsh

```bash
git submodule update --init --recursive
```

## Post-Instalación

### 1. Configurar Zsh como Shell por Defecto

```bash
# Verificar ruta de zsh
which zsh

# Cambiar shell por defecto
chsh -s $(which zsh)

# Reiniciar sesión para aplicar cambios
# Logout y login nuevamente
```

### 2. Instalar Tmux Plugin Manager (TPM)

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

**Instalar plugins de Tmux**:
1. Iniciar tmux: `tmux`
2. Presionar `Ctrl+s` + `I` (mayúscula I) para instalar plugins
3. Esperar a que termine

### 3. Configurar Neovim

Al abrir Neovim por primera vez:
1. `lazy.nvim` se instalará automáticamente
2. Los plugins comenzarán a instalarse automáticamente
3. Espera a que termine el proceso (puede tardar 1-2 minutos)

**Comandos útiles**:
```vim
:Lazy sync      " Sincronizar todos los plugins
:Mason          " Abrir gestor de LSP servers
:checkhealth    " Verificar configuración
```

### 4. Instalar Fuente Nerd Font (Requerida)

```bash
# macOS
brew tap homebrew/cask-fonts
brew install font-jetbrains-mono-nerd-font

# Linux (manual)
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
unzip JetBrainsMono.zip
rm JetBrainsMono.zip
fc-cache -fv
```

**Configurar fuente en tu terminal**:
- Fuente recomendada: JetBrainsMono Nerd Font
- Tamaño: 12-14pt

### 5. Instalar Herramientas CLI Modernas (Opcional)

**eza** (reemplazo de `ls`):
```bash
# Ubuntu/Debian
sudo apt install -y eza

# macOS
brew install eza
```

**bat** (reemplazo de `cat`):
```bash
# Linux
sudo apt install -y bat

# macOS
brew install bat
```

**zoxide** (navegación inteligente):
```bash
# Linux
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# macOS
brew install zoxide
```

**fd** (reemplazo de `find`):
```bash
# Linux
sudo apt install -y fd-find

# macOS
brew install fd
```

## Verificación

### 1. Verificar Enlaces Simbólicos

```bash
# Ver enlaces creados
ls -la ~/.config/nvim
ls -la ~/.config/tmux
ls -la ~/.zshrc

# Verificar que apuntan a ~/dotfiles
```

### 2. Verificar Zsh

```bash
echo $SHELL
# Debe mostrar: /usr/bin/zsh o /bin/zsh

zsh --version
# Debe mostrar: zsh 5.8 o superior
```

### 3. Verificar Neovim

```bash
nvim --version
# Debe mostrar: NVIM v0.9.0 o superior

# Abrir Neovim y ejecutar
nvim
:checkhealth
```

### 4. Verificar Tmux

```bash
tmux -V
# Debe mostrar: tmux 3.0 o superior

# Iniciar tmux y verificar plugins
tmux
# Presionar: Ctrl+s + ?  (ver keybindings)
```

### 5. Verificar Starship

```bash
starship --version

# Reiniciar shell
exec zsh

# El prompt debe mostrar el estilo Catppuccin
```

### 6. Ejecutar Health Check

```bash
cd ~/dotfiles
./scripts/health-check.sh
```

## Solución de Problemas

### Error: "Conflicts during stow"

**Síntoma**: Stow se queja de archivos existentes

**Solución**:
```bash
# Hacer backup manual
mv ~/.config/nvim ~/.config/nvim.backup

# Intentar stow nuevamente
stow nvim
```

### Error: "Plugins de Neovim no se cargan"

**Síntoma**: Al abrir Neovim no se ven los plugins

**Solución**:
```bash
# Limpiar cache y reinstalar
rm -rf ~/.local/share/nvim
rm -rf ~/.cache/nvim

# Abrir Neovim - se reinstalará todo
nvim
:Lazy sync
```

### Error: "Fuente con símbolos rotos"

**Síntoma**: Se ven cuadrados � o símbolos extraños

**Solución**:
1. Instalar una Nerd Font (ver sección de Post-Instalación)
2. Configurar la fuente en tu terminal
3. Reiniciar terminal

### Error: "Zsh no es el shell por defecto"

**Síntoma**: Al abrir terminal sigue usando bash

**Solución**:
```bash
# Verificar si zsh está en /etc/shells
cat /etc/shells

# Si no está, agregarlo
sudo sh -c "echo $(which zsh) >> /etc/shells"

# Cambiar shell
chsh -s $(which zsh)

# Reiniciar sesión (logout y login)
```

### Error: "Plugins de Tmux no se instalan"

**Síntoma**: Al presionar `Ctrl+s + I` no pasa nada

**Solución**:
```bash
# Verificar que TPM está instalado
ls ~/.tmux/plugins/tpm

# Si no existe, instalarlo
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Reiniciar tmux
tmux kill-server
tmux

# Intentar instalar plugins nuevamente
# Ctrl+s + I
```

### Error: "Starship no aparece"

**Síntoma**: El prompt no cambia después de instalar

**Solución**:
```bash
# Verificar que starship está instalado
which starship

# Verificar que .zshrc tiene la inicialización
grep "starship init" ~/.zshrc

# Reiniciar shell
exec zsh
```

### Error: "LSP servers no funcionan en Neovim"

**Síntoma**: No hay autocompletado o diagnósticos

**Solución**:
```bash
# Abrir Neovim
nvim

# Instalar LSP servers manualmente
:Mason

# Verificar LSP está corriendo
:LspInfo

# Si no está corriendo, reiniciar
:LspRestart
```

## Actualización del Sistema

Para actualizar las configuraciones:

```bash
cd ~/dotfiles

# Obtener últimos cambios
git pull --recurse-submodules

# Actualizar enlaces (si es necesario)
stow -R */

# Actualizar plugins de Neovim
nvim
:Lazy sync

# Actualizar plugins de Tmux
# Dentro de tmux: Ctrl+s + U
```

## Desinstalación

Para remover las configuraciones:

```bash
cd ~/dotfiles

# Eliminar enlaces simbólicos
stow -D */

# Restaurar backups (si existen)
mv ~/.dotfiles-backup/nvim.backup ~/.config/nvim
mv ~/.dotfiles-backup/.zshrc.backup ~/.zshrc

# Cambiar shell de vuelta a bash (opcional)
chsh -s /bin/bash
```

## Siguientes Pasos

Una vez instalado todo:

1. **Leer documentación**: Consulta [README.md](../README.md) para overview general
2. **Aprender keybindings**: Ver [Keybindings](guides/keybindings.md)
3. **Configurar Git**: Edita `~/.config/git/config` con tu nombre y email
4. **Explorar workflows**: Ver [Workflows](guides/workflows.md)
5. **Personalizar**: Ver [Customization](guides/customization.md)

## Recursos Adicionales

- [Arquitectura del Proyecto](ARCHITECTURE.md)
- [Documentación de Servicios](services/)
- [Troubleshooting](reference/troubleshooting.md)
- [Scripts Utilitarios](../scripts/README.md)

---

Si encuentras problemas no cubiertos en esta guía, abre un issue en el repositorio.

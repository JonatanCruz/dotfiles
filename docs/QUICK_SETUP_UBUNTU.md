# 🚀 Configuración Rápida - Ubuntu 24.04 LTS

Guía paso a paso para configurar completamente tu entorno de desarrollo en Ubuntu 24.04.

## ⚡ Opción 1: Instalación Automática (Recomendada)

### Una sola línea - Bootstrap completo

```bash
cd ~/dotfiles && ./scripts/bootstrap.sh -y
```

Esto instalará:
- ✅ Todas las dependencias del sistema
- ✅ Herramientas CLI modernas
- ✅ Configuraciones con Stow
- ✅ Submodules de Git
- ✅ Zsh como shell por defecto

**Tiempo estimado:** 5-10 minutos

---

## 🍺 Opción 2: Instalación con Homebrew (Simple y Actualizada)

Homebrew (Linuxbrew) permite instalar todas las herramientas con versiones recientes sin necesidad de PPAs ni compilaciones manuales.

### Paso 1: Instalar dependencias base y Homebrew

```bash
# Dependencias para Homebrew
sudo apt update && sudo apt install -y build-essential curl file git procps

# Instalar Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Agregar Homebrew al PATH (ejecutar lo que indica el instalador)
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
```

### Paso 2: Instalar TODAS las herramientas de una vez

```bash
# Una sola línea instala todo el stack
brew install \
    neovim \
    tmux \
    starship \
    eza \
    bat \
    fd \
    ripgrep \
    fzf \
    zoxide \
    yazi \
    lazygit \
    stow \
    node \
    python@3

# Verificar instalación
brew doctor
```

### Paso 3: Aplicar dotfiles

```bash
cd ~/dotfiles
git submodule update --init --recursive
stow nvim zsh zsh-plugins tmux starship yazi docker claude git
chsh -s $(which zsh)
```

**Ventajas de Homebrew:**
- ✅ Versiones siempre actualizadas (no dependes de repos de Ubuntu)
- ✅ No necesita `sudo` para instalar paquetes
- ✅ Un solo comando para todo el stack
- ✅ Consistente entre macOS y Linux
- ✅ Fácil rollback con `brew uninstall`

**Desventajas:**
- ⚠️ Usa más espacio en disco (~2-4 GB por las dependencias propias)
- ⚠️ Las rutas son diferentes a las del sistema (`/home/linuxbrew/...`)

---

## 🔀 Alternativas por Herramienta

Cada herramienta tiene alternativas según tus preferencias:

| Categoría | Recomendada | Alternativas | Notas |
|-----------|-------------|--------------|-------|
| **Listado de archivos** | `eza` | `lsd`, `exa` (deprecated), `natls` | `lsd` tiene iconos sin Nerd Font |
| **Visor de archivos** | `bat` | `glow` (markdown), `highlight`, `pygmentize` | `glow` ideal para README.md |
| **Búsqueda de texto** | `ripgrep` (rg) | `ag` (silver-searcher), `ack`, `ugrep` | `ugrep` es más compatible con grep POSIX |
| **Búsqueda de archivos** | `fd` | `bfs`, `find` (GNU) | `bfs` prioriza breadth-first |
| **Fuzzy finder** | `fzf` | `skim` (sk), `peco`, `zf` | `skim` es un clon de fzf en Rust |
| **Navegación dirs** | `zoxide` | `autojump`, `z.lua`, `fasd` | `zoxide` es el más rápido |
| **File manager** | `yazi` | `ranger`, `nnn`, `lf`, `joshuto` | `nnn` es el más ligero |
| **Prompt** | `starship` | `powerlevel10k`, `oh-my-posh`, `pure` | `p10k` solo para Zsh |
| **Editor** | `neovim` | `helix`, `kakoune`, `vim`, `micro` | `helix` no necesita plugins |
| **Multiplexor** | `tmux` | `zellij`, `screen`, `byobu` | `zellij` es más moderno/intuitivo |
| **Git TUI** | `lazygit` | `tig`, `gitui`, `fugitive` (nvim) | `gitui` es más ligero |
| **Diffs** | `delta` | `difftastic`, `diff-so-fancy` | `difftastic` entiende AST |

### Instalación de alternativas con Homebrew

```bash
# Si prefieres zellij en lugar de tmux
brew install zellij

# Si prefieres helix en lugar de neovim
brew install helix

# Si prefieres lsd en lugar de eza
brew install lsd

# Si prefieres ranger en lugar de yazi
brew install ranger

# Herramientas complementarias recomendadas
brew install delta dust btop tokei hyperfine
```

### Instalación de alternativas con apt

```bash
# Alternativas disponibles directamente en apt
sudo apt install -y \
    silversearcher-ag \
    ranger \
    tig \
    byobu \
    screen
```

---

## 🎯 Opción 3: Instalación Paso a Paso (Control Total)

### Paso 1: Instalar Dependencias del Sistema

```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependencias básicas
sudo apt install -y \
    git \
    stow \
    curl \
    wget \
    build-essential \
    software-properties-common
```

### Paso 2: Instalar Zsh y Starship

```bash
# Instalar Zsh
sudo apt install -y zsh

# Instalar Starship (prompt)
curl -sS https://starship.rs/install.sh | sh

# Verificar instalación
zsh --version
starship --version
```

### Paso 3: Instalar Neovim (Última Versión)

```bash
# Opción A: AppImage (recomendado - última versión)
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
sudo mv nvim.appimage /usr/local/bin/nvim

# Opción B: Desde repositorio (puede ser versión antigua)
sudo apt install -y neovim

# Verificar versión (debe ser >= 0.9.0)
nvim --version
```

### Paso 4: Instalar Tmux

```bash
sudo apt install -y tmux

# Verificar instalación
tmux -V
```

### Paso 5: Instalar Herramientas CLI Modernas

```bash
# ripgrep (búsqueda rápida)
sudo apt install -y ripgrep

# fd (find alternativo)
sudo apt install -y fd-find

# bat (cat con syntax highlighting)
sudo apt install -y bat

# fzf (fuzzy finder)
sudo apt install -y fzf

# eza (ls moderno)
# Nota: eza requiere añadir repositorio
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update
sudo apt install -y eza

# zoxide (navegación inteligente de directorios)
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
```

### Paso 6: Instalar Yazi (File Manager)

```bash
# Descargar última versión
curl -LO https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.tar.gz
tar -xzf yazi-x86_64-unknown-linux-gnu.tar.gz
sudo mv yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin/
rm -rf yazi-x86_64-unknown-linux-gnu*

# Verificar instalación
yazi --version
```

### Paso 7: Instalar Node.js y Python (para LSP servers)

```bash
# Node.js (vía NodeSource)
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# Python 3 y pip (generalmente ya viene instalado)
sudo apt install -y python3 python3-pip python3-venv

# Verificar instalaciones
node --version
npm --version
python3 --version
```

### Paso 8: Instalar Fuente Nerd Font (IMPORTANTE)

```bash
# Crear directorio de fuentes
mkdir -p ~/.local/share/fonts

# Descargar JetBrainsMono Nerd Font
cd ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
unzip JetBrainsMono.zip
rm JetBrainsMono.zip

# Actualizar cache de fuentes
fc-cache -fv

# Volver al directorio de dotfiles
cd ~/dotfiles
```

**⚠️ IMPORTANTE:** Configura tu terminal para usar "JetBrainsMono Nerd Font" o tendrás símbolos rotos.

### Paso 9: Inicializar Submodules de Git

```bash
cd ~/dotfiles

# Inicializar plugins de Zsh
git submodule update --init --recursive
```

### Paso 10: Aplicar Configuraciones con Stow

```bash
cd ~/dotfiles

# Opción A: Usar el instalador interactivo
./install.sh

# Opción B: Instalar todo manualmente
stow nvim
stow zsh
stow zsh-plugins
stow tmux
stow starship
stow yazi
stow docker
stow claude
stow git
```

### Paso 11: Configurar Zsh como Shell por Defecto

```bash
# Añadir zsh a shells permitidas (si no está)
if ! grep -q "$(which zsh)" /etc/shells; then
    echo "$(which zsh)" | sudo tee -a /etc/shells
fi

# Cambiar shell por defecto
chsh -s $(which zsh)

# Cerrar sesión y volver a iniciar
# O ejecutar: exec zsh
```

### Paso 12: Instalar TPM (Tmux Plugin Manager)

```bash
# Clonar TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Iniciar tmux
tmux

# Dentro de tmux, presionar: Ctrl+s (prefix) + Shift+I
# Esto instalará todos los plugins definidos en .tmux.conf
```

### Paso 13: Configurar Neovim

```bash
# Abrir Neovim (primera vez)
nvim

# lazy.nvim se instalará automáticamente
# Los plugins comenzarán a instalarse
# Espera a que termine (1-2 minutos)

# Comandos útiles en Neovim:
# :Lazy sync      - Sincronizar plugins
# :Mason          - Instalar LSP servers
# :checkhealth    - Verificar salud de la configuración
```

### Paso 14: Instalar LazyGit (opcional pero recomendado)

```bash
# Añadir repositorio
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit lazygit.tar.gz

# Verificar
lazygit --version
```

### Paso 15: Verificar Instalación

```bash
# Ejecutar health check
cd ~/dotfiles
./scripts/health-check.sh
```

---

## 🔧 Post-Instalación

### Configurar Git

Edita tu configuración de Git:

```bash
nvim ~/.config/git/config
```

Añade tu información:

```ini
[user]
    name = Tu Nombre
    email = tu@email.com

[github]
    user = tu-usuario
```

### Recargar Configuración

```bash
# Reiniciar shell
exec zsh

# O cerrar sesión y volver a iniciar sesión
```

### Configurar Terminal

**Si usas GNOME Terminal o Tilix:**

1. Abrir Preferencias → Perfiles → Editar perfil actual
2. Fuente: "JetBrainsMono Nerd Font" (tamaño 11-12)
3. Colores: Personalizado con tema Catppuccin Mocha (opcional)

---

## 🎨 Temas y Colores

Tu configuración usa **Catppuccin Mocha** (no Dracula):

- Neovim: Tema aplicado automáticamente
- Tmux: Colores Catppuccin via status bar custom (sin plugin externo)
- Starship: Configuración en `~/.config/starship.toml`

---

## ⌨️ Atajos de Teclado Esenciales

### Tmux (Prefix: Ctrl+s)

| Atajo | Acción |
|-------|--------|
| `Ctrl+s` + `v` | Split horizontal (arriba/abajo) |
| `Ctrl+s` + `h` | Split vertical (izquierda/derecha) |
| `Ctrl+h/j/k/l` | Navegar entre paneles (sin prefix) |
| `Alt+h/j/k/l` | Redimensionar paneles (vim-aware) |
| `Ctrl+s` + `m` | Zoom pane (toggle) |
| `Ctrl+s` + `s` | Gestor de sesiones (SessionX) |
| `Ctrl+s` + `r` | Recargar configuración |

### Neovim (Leader: Espacio)

| Atajo | Acción |
|-------|--------|
| `<Space>w` | Guardar archivo |
| `<Space>q` | Salir |
| `<Space>e` | Explorador de archivos |
| `<Space>ff` | Buscar archivos |
| `<Space>fg` | Buscar texto en proyecto |
| `<Space>gg` | Abrir LazyGit |
| `gd` | Ir a definición |
| `K` | Mostrar documentación |

---

## 🐛 Solución de Problemas Comunes

### Símbolos rotos en terminal

**Problema:** Ves cuadrados � o símbolos extraños

**Solución:**
```bash
# Instalar Nerd Font (ver Paso 8)
# Configurar terminal para usar JetBrainsMono Nerd Font
```

### Neovim no carga plugins

**Problema:** Neovim se abre sin colores ni plugins

**Solución:**
```bash
# Limpiar cache
rm -rf ~/.local/share/nvim ~/.cache/nvim

# Abrir Neovim y dejar que reinstale
nvim
:Lazy sync
```

### Tmux plugins no se instalan

**Problema:** `Ctrl+s + I` no hace nada

**Solución:**
```bash
# Verificar que TPM está instalado
ls ~/.tmux/plugins/tpm

# Si no existe, instalarlo
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Reiniciar tmux
tmux kill-server
tmux
```

### Zsh no es el shell por defecto

**Problema:** Al abrir terminal sigue usando bash

**Solución:**
```bash
# Verificar shell actual
echo $SHELL

# Cambiar a zsh
chsh -s $(which zsh)

# Cerrar sesión completamente y volver a iniciar
```

### Comandos como `bat` o `fd` no funcionan

**Problema:** Ubuntu instala como `batcat` y `fdfind`

**Solución:**
```bash
# Crear alias en .zshrc (ya debería estar configurado)
# Si no, añade manualmente:
echo 'alias bat="batcat"' >> ~/.zshrc
echo 'alias fd="fdfind"' >> ~/.zshrc
source ~/.zshrc
```

---

## 📊 Verificación Final

Ejecuta estos comandos para verificar que todo está instalado:

```bash
# Verificar versiones
zsh --version          # >= 5.8
nvim --version         # >= 0.9.0
tmux -V                # >= 3.0
starship --version     # >= 1.0
git --version          # >= 2.0
node --version         # >= 18.0
python3 --version      # >= 3.10

# Verificar herramientas CLI
which eza ripgrep bat fd fzf zoxide yazi lazygit

# Verificar symlinks
ls -la ~/.config/nvim     # Debe apuntar a ~/dotfiles/nvim/.config/nvim
ls -la ~/.config/tmux     # Debe apuntar a ~/dotfiles/tmux/.config/tmux

# Ejecutar health check completo
cd ~/dotfiles
./scripts/health-check.sh
```

---

## 🚀 Siguiente Paso

Una vez todo instalado y verificado:

```bash
# Reiniciar sesión completa
# Logout → Login

# Abrir nueva terminal y disfrutar tu entorno configurado!
```

Tu terminal ahora tendrá:
- ✅ Prompt Starship con tema Catppuccin
- ✅ Autosuggestions y syntax highlighting en Zsh
- ✅ Neovim con LSP, autocompletado, y más
- ✅ Tmux con plugins y tema
- ✅ Herramientas CLI modernas

---

## 📚 Recursos Adicionales

- [Documentación completa](../README.md)
- [Arquitectura del proyecto](ARCHITECTURE.md)
- [Guías de usuario](guides/)
- [Referencia de atajos](reference/)

**¿Problemas?** → Consulta [Troubleshooting](reference/troubleshooting.md)

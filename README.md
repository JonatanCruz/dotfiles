# 💻 Mi Entorno de Desarrollo (`dotfiles`)

![Catppuccin Theme Banner](https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png)

Este repositorio contiene mi configuración personal para un entorno de desarrollo en **Linux y macOS**, gestionado con **GNU Stow** y **Git**. La filosofía detrás de esta configuración es crear un ambiente **rápido, coherente, minimalista y estéticamente agradable**, centrado en la navegación con el teclado al estilo Vim.

Toda la configuración sigue una paleta de colores unificada **Catppuccin Mocha** y está diseñada para tener un fondo **transparente**.

---

## 🛠️ Componentes Principales

| Herramienta              | Propósito                               |
| ------------------------ | --------------------------------------- |
| **Gestor de Dotfiles** | [GNU Stow](https://www.gnu.org/software/stow/)      |
| **Terminal Emulator** | [WezTerm](https://wezfurlong.org/wezterm/) (macOS)  |
| **Terminal Multiplexer** | [Tmux](https://github.com/tmux/tmux)                |
| **Shell** | [Zsh](https://www.zsh.org/)                         |
| **Prompt** | [Starship](https://starship.rs/)                    |
| **Editor de Código** | [Neovim](https://neovim.io/)                        |
| **Explorador de Archivos** | [Yazi](https://github.com/sxyazi/yazi) & NvimTree |
| **Navegación Rápida** | [Zoxide](https://github.com/ajeetdsouza/zoxide)     |

### Herramientas CLI Modernas
- **`ls` Alternativa:** [Eza](https://github.com/eza-community/eza)
- **`cat` Alternativa:** [Bat](https://github.com/sharkdp/bat)
- **`find` Alternativa:** [fd](https://github.com/sharkdp/fd)
- **`grep` Alternativa:** [ripgrep (rg)](https://github.com/BurntSushi/ripgrep)
- **Git UI:** [LazyGit](https://github.com/jesseduffield/lazygit)
- **Git Diff:** [Delta](https://github.com/dandavison/delta)
- **GitHub CLI:** [gh](https://cli.github.com/)

### Herramientas de Desarrollo
- **Monitor de Sistema:** [btop](https://github.com/aristocratos/btop)
- **Ayuda Rápida:** [tldr](https://github.com/tldr-pages/tldr)
- **Variables de Entorno:** [direnv](https://direnv.net/)
- **Python Version Manager:** [pyenv](https://github.com/pyenv/pyenv)
- **Node Version Manager:** [nvm](https://github.com/nvm-sh/nvm)

---

## 🚀 Instalación Rápida

Para replicar este entorno en una nueva máquina:

**1. Clona este repositorio:**
```bash
git clone https://github.com/JonatanCruz/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

**2. Instala GNU Stow:**

<details>
<summary><b>Linux</b></summary>

```bash
# Ubuntu/Debian
sudo apt install stow

# Arch Linux
sudo pacman -S stow

# Fedora
sudo dnf install stow
```
</details>

<details>
<summary><b>macOS</b></summary>

```bash
# Instala Homebrew si no lo tienes
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Instala Stow
brew install stow
```
</details>

**3. Instala las dependencias principales:**

<details>
<summary><b>Linux (Ubuntu/Debian)</b></summary>

```bash
# Tmux
sudo apt install tmux

# Zsh
sudo apt install zsh

# Neovim (última versión)
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update
sudo apt install neovim

# Starship
curl -sS https://starship.rs/install.sh | sh

# Yazi
cargo install --locked yazi-fm yazi-cli

# Zoxide
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# Herramientas CLI modernas
sudo apt install eza bat fd-find ripgrep

# LazyGit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
```
</details>

<details>
<summary><b>macOS</b></summary>

```bash
# Dependencias principales
brew install tmux zsh neovim starship yazi zoxide eza bat fd ripgrep lazygit

# Herramientas de Git
brew install git-delta gh

# Herramientas de desarrollo
brew install btop tlrc direnv pyenv

# Instala WezTerm (terminal recomendado para macOS)
brew install --cask wezterm

# Instala las Nerd Fonts (recomendado para iconos)
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font
```
</details>

**4. Aplica las configuraciones con Stow:**

⚠️ **Importante:** Respalda tus configuraciones existentes antes de continuar.

```bash
# Aplicar todas las configuraciones
stow */

# O aplicar configuraciones específicas:
stow git
stow nvim
stow tmux
stow zsh
stow zsh-plugins
stow starship
stow yazi

# Solo en macOS:
stow wezterm
```

**5. Cambia el shell a Zsh (opcional):**
```bash
chsh -s $(which zsh)
```

Cierra sesión y vuelve a entrar para aplicar los cambios.

---

## 📂 Estructura del Repositorio

```
dotfiles/
├── git/
│   └── .gitconfig             # Configuración de Git con delta
├── nvim/
│   └── .config/nvim/          # Configuración de Neovim
├── tmux/
│   └── .tmux.conf             # Configuración de tmux
├── zsh/
│   └── .zshrc                 # Configuración de ZSH
├── zsh-plugins/
│   └── .zsh/                  # Plugins adicionales de ZSH
├── starship/
│   └── .config/starship.toml  # Configuración del prompt Starship
├── yazi/
│   └── .config/yazi/          # Configuración de Yazi
└── wezterm/
    └── .config/wezterm/       # Configuración de WezTerm (macOS)
```

### Notas sobre la estructura

- **Branch `main`:** Configuración optimizada para Linux
- **Branch `mac`:** Incluye adaptaciones y herramientas específicas para macOS (como WezTerm)

---

## 🔧 Cómo Funciona GNU Stow

GNU Stow es un gestor de enlaces simbólicos que permite mantener los dotfiles organizados en un repositorio mientras las aplicaciones los leen desde sus ubicaciones esperadas.

### Concepto Básico

Cuando ejecutas `stow nvim` desde `~/dotfiles`, Stow crea enlaces simbólicos:

```
~/.config/nvim → ~/dotfiles/nvim/.config/nvim
```

### Comandos Útiles

```bash
# Instalar configuración
stow nvim

# Reinstalar configuración (útil después de actualizaciones)
stow -R nvim

# Desinstalar configuración
stow -D nvim

# Simular instalación (ver qué haría sin aplicar cambios)
stow -n nvim

# Instalar todo
stow */

# Desinstalar todo
stow -D */
```

### Resolución de Conflictos

Si encuentras errores como:
```
WARNING! stowing nvim would cause conflicts:
  * existing target is neither a link nor a directory: .config/nvim
```

**Solución:**
```bash
# Respalda la configuración existente
mv ~/.config/nvim ~/.config/nvim.backup

# Aplica la nueva configuración
stow nvim
```

---

## 🎨 Personalización

### Tema Unificado: Catppuccin Mocha

Todas las herramientas están configuradas con el tema **[Catppuccin Mocha](https://github.com/catppuccin/catppuccin)** para una armonía visual completa:

**Terminal y Shell:**
- **WezTerm:** `Catppuccin Mocha` - Transparencia al 60%
- **Tmux:** Plugin `catppuccin/tmux` con mocha flavor
- **Starship:** Colores Catppuccin Mocha personalizados

**Editor y Herramientas:**
- **Neovim:** Plugin `catppuccin/nvim` (mocha flavor)
- **Git Delta:** Syntax theme Catppuccin Mocha con colores oficiales
- **Yazi:** Compatible con tema Catppuccin

**Paleta de Colores Catppuccin Mocha:**
- Base: `#1e1e2e`
- Mantle: `#181825`
- Crust: `#11111b`
- Text: `#cdd6f4`
- Subtext0: `#a6adc8`
- Overlay0: `#6c7086`
- Surface0: `#313244`
- Mauve (Purple): `#cba6f7`
- Pink: `#f5c2e7`
- Sky (Cyan): `#89dceb`
- Green: `#a6e3a1`
- Peach (Orange): `#fab387`
- Red: `#f38ba8`
- Yellow: `#f9e2af`

**¿Por qué Catppuccin Mocha?**
- Menos fatiga visual durante largas sesiones de programación
- Paleta de colores suaves y bien balanceados
- Excelente contraste sin ser agresivo
- Más de 200 integraciones con herramientas de desarrollo
- Comunidad activa y bien documentado

### Transparencia

El fondo transparente está configurado en:
- Neovim (`nvim/.config/nvim/lua/plugins/colorscheme.lua`)
- Tmux (`.tmux.conf`)
- WezTerm (`wezterm/.config/wezterm/wezterm.lua`) - 60% opacidad con blur

Asegúrate de que tu emulador de terminal soporte transparencia.

---

## 🔄 Actualización

Para actualizar las configuraciones después de hacer cambios:

```bash
cd ~/dotfiles
git pull
stow -R */  # Re-aplicar todos los paquetes
```

---

## ➕ Agregar Nuevas Configuraciones

1. Crea un directorio para la nueva herramienta:
   ```bash
   mkdir -p nueva-app/.config/nueva-app
   ```

2. Agrega tus archivos de configuración dentro

3. Aplica con Stow:
   ```bash
   stow nueva-app
   ```

4. Haz commit de los cambios:
   ```bash
   git add nueva-app/
   git commit -m "Add nueva-app configuration"
   git push
   ```

---

## 🛠️ Nuevas Herramientas y Aliases

### Git Delta
Visualizador de diffs mejorado con syntax highlighting. Se activa automáticamente con:
```bash
git diff
git log -p
git show <commit>
```

### GitHub CLI (gh)
| Alias | Comando | Descripción |
|-------|---------|-------------|
| `ghpr` | `gh pr create` | Crear Pull Request |
| `ghprl` | `gh pr list` | Listar PRs |
| `ghprv` | `gh pr view` | Ver PR |
| `ghis` | `gh issue list` | Listar issues |
| `ghrc` | `gh repo clone` | Clonar repositorio |
| `ghrv` | `gh repo view --web` | Ver repo en navegador |

### Monitor de Sistema
| Alias | Comando | Descripción |
|-------|---------|-------------|
| `top` | `btop` | Monitor visual de sistema |
| `monitor` | `btop` | Monitor visual de sistema |

### Ayuda Rápida
| Alias | Comando | Descripción |
|-------|---------|-------------|
| `help` | `tldr` | Ayuda rápida con ejemplos |

**Ejemplo:**
```bash
help tar     # Ver ejemplos de uso de tar
help docker  # Ver ejemplos de uso de docker
help git-rebase  # Ver ejemplos de git rebase
```

### Direnv
Carga automáticamente variables de entorno al entrar a un directorio:
```bash
# En tu proyecto, crea un archivo .envrc
echo 'export DATABASE_URL="postgres://localhost/mydb"' > .envrc
direnv allow .

# Al entrar al directorio, las variables se cargan automáticamente
# Al salir, se descargan
```

### Pyenv
Gestiona múltiples versiones de Python:
```bash
pyenv install 3.11.0    # Instalar Python 3.11
pyenv global 3.11.0     # Usar 3.11 globalmente
pyenv local 3.9.0       # Usar 3.9 en el proyecto actual
pyenv versions          # Ver versiones instaladas
```

---

## 📝 Atajos de Teclado Principales

### WezTerm (macOS)
- Pantalla completa: `Ctrl+F`
- Abrir enlaces: `Ctrl+Click`
- Nueva pestaña: `Cmd+T`
- Cerrar pestaña: `Cmd+W`

### Tmux
- **Prefix:** `Ctrl+a`
- Split horizontal: `Prefix + |`
- Split vertical: `Prefix + -`
- Navegar entre paneles: `Prefix + h/j/k/l`

### Neovim
- **Leader:** `<space>`
- Explorador de archivos: `Leader + e`
- Búsqueda de archivos: `Leader + f`
- Abrir LazyGit: `Leader + gg`
- Navegación estilo Vim: `h/j/k/l`

### Yazi
- Navegar: `h/j/k/l` o flechas
- Abrir archivo: `Enter`
- Volver: `Esc` o `q`

---

## 🐛 Solución de Problemas

### Stow falla con "conflicts"
**Causa:** Archivos existentes en la ubicación destino

**Solución:** Respalda y elimina los archivos existentes antes de ejecutar Stow.

### Plugins de Neovim no se instalan
**Causa:** Gestor de plugins no inicializado

**Solución:** Abre Neovim y ejecuta `:Lazy sync`

### Zsh no carga configuración
**Causa:** Shell por defecto no es Zsh

**Solución:**
```bash
chsh -s $(which zsh)
```
Cierra sesión y vuelve a entrar.

### Starship no aparece
**Causa:** No está en el PATH

**Solución:** Agrega a `.zshrc`:
```bash
eval "$(starship init zsh)"
```

---

## 📜 Licencia

Configuración personal - Úsala libremente y modifícala según tus necesidades.

---

## 🤝 Contribuir

Si encuentras algún problema o tienes sugerencias de mejora, no dudes en abrir un issue o pull request.

---

## 📚 Referencias

- [GNU Stow Documentation](https://www.gnu.org/software/stow/manual/stow.html)
- [Dracula Theme](https://draculatheme.com/)
- [Dotfiles Guide](https://dotfiles.github.io/)
- [Managing Dotfiles with GNU Stow](https://systemcrafters.net/managing-your-dotfiles/using-gnu-stow/)

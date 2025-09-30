# 🐧 Mi Entorno de Desarrollo (`dotfiles`)

![Dracula Theme Banner](https://raw.githubusercontent.com/dracula/dracula-theme/master/screenshot.png)

Este repositorio contiene mi configuración personal para un entorno de desarrollo en Linux, gestionado con **GNU Stow** y **Git**. La filosofía detrás de esta configuración es crear un ambiente **rápido, coherente, minimalista y estéticamente agradable**, centrado en la navegación con el teclado al estilo Vim.

Toda la configuración sigue una paleta de colores unificada **Dracula** y está diseñada para tener un fondo **transparente**.

---

## 🛠️ Componentes Principales

| Herramienta              | Propósito                               |
| ------------------------ | --------------------------------------- |
| **Gestor de Dotfiles** | [GNU Stow](https://www.gnu.org/software/stow/)      |
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
- **Interfaz para Git:** [LazyGit](https://github.com/jesseduffield/lazygit)

---

## 🚀 Instalación Rápida

Para replicar este entorno en una nueva máquina Linux:

**1. Clona este repositorio:**
```bash
git clone https://github.com/JonatanCruz/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

**2. Instala GNU Stow:**
```bash
# Ubuntu/Debian
sudo apt install stow

# Arch Linux
sudo pacman -S stow

# Fedora
sudo dnf install stow
```

**3. Instala las dependencias principales:**
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

**4. Aplica las configuraciones con Stow:**

⚠️ **Importante:** Respalda tus configuraciones existentes antes de continuar.

```bash
# Aplicar todas las configuraciones
stow */

# O aplicar configuraciones específicas:
stow nvim
stow tmux
stow zsh
stow zsh-plugins
stow starship
stow yazi
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
└── yazi/
    └── .config/yazi/          # Configuración de Yazi
```

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

### Tema Dracula

Todas las herramientas están configuradas con el tema [Dracula](https://draculatheme.com/) para una apariencia coherente:
- Neovim: Plugin `Mofiqul/dracula.nvim`
- Tmux: Colores personalizados Dracula
- Terminal: Configura tu emulador de terminal con Dracula

### Transparencia

El fondo transparente está configurado en:
- Neovim (`nvim/.config/nvim/`)
- Tmux (`.tmux.conf`)

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

## 📝 Atajos de Teclado Principales

### Tmux
- **Prefix:** `Ctrl+a`
- Split horizontal: `Prefix + |`
- Split vertical: `Prefix + -`
- Navegar entre paneles: `Prefix + h/j/k/l`

### Neovim
- **Leader:** `<space>`
- Explorador de archivos: `Leader + e`
- Búsqueda de archivos: `Leader + f`
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

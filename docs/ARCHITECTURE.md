# 🏗️ Arquitectura del Proyecto Dotfiles

Este documento explica la arquitectura general del proyecto, cómo funciona GNU Stow y la organización de los archivos de configuración.

## 📋 Índice

- [Concepto General](#concepto-general)
- [GNU Stow](#gnu-stow)
- [Estructura de Paquetes](#estructura-de-paquetes)
- [Flujo de Instalación](#flujo-de-instalación)
- [Ventajas de esta Arquitectura](#ventajas-de-esta-arquitectura)
- [Gestión de Configuraciones](#gestión-de-configuraciones)

## Concepto General

Este proyecto utiliza **GNU Stow** como gestor de enlaces simbólicos para mantener archivos de configuración (dotfiles) organizados y versionados con Git.

### Problema que Resuelve

Tradicionalmente, los dotfiles se encuentran dispersos en el sistema:
- `~/.config/nvim/` - Configuración de Neovim
- `~/.tmux.conf` - Configuración de Tmux
- `~/.zshrc` - Configuración de Zsh

**Problemas**:
- Difícil de versionar con Git
- Complicado sincronizar entre máquinas
- No modular (todo o nada)

### Solución: GNU Stow + Git

Este proyecto centraliza todas las configuraciones en un repositorio Git y usa Stow para crear enlaces simbólicos automáticamente.

```
~/dotfiles/              # Repositorio Git
├── nvim/                # Paquete de Neovim
│   └── .config/nvim/    # → Enlace a ~/.config/nvim/
├── tmux/                # Paquete de Tmux
│   └── .tmux.conf       # → Enlace a ~/.tmux.conf
└── zsh/                 # Paquete de Zsh
    └── .zshrc           # → Enlace a ~/.zshrc
```

## GNU Stow

### ¿Qué es GNU Stow?

GNU Stow es un gestor de enlaces simbólicos que crea links automáticamente desde un directorio fuente (paquete) hacia un directorio destino (típicamente `$HOME`).

### Funcionamiento

Cuando ejecutas `stow nvim` desde `~/dotfiles`:

1. **Stow analiza** el contenido de `nvim/`
2. **Replica la estructura** de directorios en `$HOME`
3. **Crea enlaces simbólicos** de cada archivo

**Ejemplo**:
```bash
# Antes de stow
~/dotfiles/nvim/.config/nvim/init.lua

# Después de stow
~/.config/nvim/init.lua -> ~/dotfiles/nvim/.config/nvim/init.lua
```

### Comandos Básicos

```bash
# Instalar configuración (crear enlaces)
stow nvim

# Reinstalar (actualizar enlaces)
stow -R nvim

# Desinstalar (eliminar enlaces)
stow -D nvim

# Simulación (ver qué haría sin ejecutar)
stow -n nvim

# Instalar todos los paquetes
stow */
```

## Estructura de Paquetes

Cada paquete sigue esta estructura:

```
package-name/
├── README.md           # Referencia rápida (10-20 líneas)
├── .config/           # Configuraciones en ~/.config/
│   └── app/
│       └── config.toml
└── .app-file          # Configuraciones en ~/
```

### Paquetes Disponibles

| Paquete | Contenido | Destino |
|---------|-----------|---------|
| `nvim` | Configuración de Neovim | `~/.config/nvim/` |
| `tmux` | Configuración de Tmux | `~/.config/tmux/`, `~/.tmux.conf` |
| `zsh` | Configuración de Zsh | `~/.config/zsh/`, `~/.zshrc` |
| `starship` | Configuración de Starship | `~/.config/starship.toml` |
| `yazi` | Configuración de Yazi | `~/.config/yazi/` |
| `wezterm` | Configuración de WezTerm | `~/.config/wezterm/` |
| `git` | Configuración de Git | `~/.config/git/` |
| `docker` | Completions de Docker | `~/.docker/` |
| `claude` | SuperClaude framework | `~/.claude/` |

## Flujo de Instalación

### Instalación Automática

El script `install.sh` automatiza todo el proceso:

1. **Detección de OS** (Linux/macOS)
2. **Verificación de dependencias** (stow, git)
3. **Selección de paquetes** (menú interactivo)
4. **Detección de conflictos** (archivos existentes)
5. **Creación de backups** automáticos
6. **Aplicación con Stow** de paquetes seleccionados

### Instalación Manual

```bash
# 1. Clonar repositorio
git clone --recurse-submodules https://github.com/JonatanCruz/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Instalar dependencias
# Linux (Ubuntu/Debian)
sudo apt install stow git

# macOS
brew install stow git

# 3. Aplicar configuraciones
stow nvim tmux zsh starship

# 4. Configurar shell (si usas Zsh)
chsh -s $(which zsh)
```

## Ventajas de esta Arquitectura

### ✅ Modularidad

Cada herramienta es un paquete independiente:
- Instala solo lo que necesitas
- Desinstala sin afectar otros paquetes
- Fácil agregar nuevas herramientas

### ✅ Versionado

Todo el repositorio está en Git:
- Historial completo de cambios
- Rollback a versiones anteriores
- Sincronización entre máquinas

### ✅ Portabilidad

Compatible con Linux y macOS:
- Mismo repositorio para múltiples sistemas
- Detección automática de OS
- Ajustes específicos por plataforma

### ✅ No Destructivo

Los enlaces simbólicos son reversibles:
- `stow -D` elimina enlaces sin borrar configuraciones
- Backups automáticos antes de instalar
- Simulación con `-n` para verificar cambios

### ✅ Mantenimiento

Fácil actualizar y sincronizar:
- `git pull` para obtener cambios
- `stow -R` para actualizar enlaces
- CI/CD valida configuraciones automáticamente

## Gestión de Configuraciones

### Actualizar Configuración

```bash
# 1. Editar archivos en ~/dotfiles/paquete/
vim ~/dotfiles/nvim/.config/nvim/lua/config/options.lua

# 2. Los cambios son inmediatos (enlaces simbólicos)
# No es necesario re-ejecutar stow

# 3. Commitear cambios
cd ~/dotfiles
git add nvim/
git commit -m "Update Neovim options"
```

### Sincronizar entre Máquinas

**Máquina A (hacer cambios)**:
```bash
cd ~/dotfiles
# ... editar archivos ...
git add .
git commit -m "Update configurations"
git push
```

**Máquina B (obtener cambios)**:
```bash
cd ~/dotfiles
git pull --recurse-submodules
stow -R */  # Actualizar enlaces si es necesario
```

### Agregar Nueva Herramienta

```bash
# 1. Crear estructura de paquete
mkdir -p nueva-herramienta/.config/nueva-herramienta

# 2. Mover configuración existente
mv ~/.config/nueva-herramienta/* nueva-herramienta/.config/nueva-herramienta/

# 3. Aplicar con Stow
stow nueva-herramienta

# 4. Commitear al repositorio
git add nueva-herramienta/
git commit -m "Add nueva-herramienta configuration"
```

### Manejo de Conflictos

Si Stow detecta un conflicto (archivo ya existe):

```bash
# Opción 1: Hacer backup manual
mv ~/.config/nvim ~/.config/nvim.backup
stow nvim

# Opción 2: Usar installer (backup automático)
./install.sh
# Seleccionar paquetes → Backups automáticos en ~/.dotfiles-backup/

# Opción 3: Forzar (no recomendado)
stow --adopt nvim  # Adopta archivos existentes (cuidado!)
```

## Documentación Centralizada

A partir de esta versión, toda la documentación del proyecto se encuentra centralizada en `docs/`:

- **Sin Enlaces Simbólicos**: Los archivos `.md` en `docs/` NO se enlacen a `~/.config/`
- **Organización Clara**: Estructura por categorías (services, guides, reference, advanced)
- **READMEs Mínimos**: Los paquetes tienen READMEs de referencia que apuntan a la documentación completa

Esto evita "ensuciar" la carpeta del usuario con archivos de documentación innecesarios en `~/.config/`.

## Recursos Adicionales

- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html)
- [Dotfiles Community](https://dotfiles.github.io/)
- [Scripts de Utilidad](../scripts/README.md)
- [Troubleshooting](reference/troubleshooting.md)

---

Para más información sobre cada servicio, consulta la [documentación por servicio](README.md#🛠️-documentación-por-servicio).

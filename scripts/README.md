# Scripts de Mantenimiento - Dotfiles

Conjunto de scripts de automatización para gestión, validación y respaldo del entorno dotfiles. Compatibles con Linux (Arch, Debian/Ubuntu) y macOS.

## Índice

- [Overview](#overview)
- [bootstrap.sh - Instalación Automatizada](#bootstrapsh---instalación-automatizada)
  - [Propósito](#propósito)
  - [Características](#características)
  - [Uso Básico](#uso-básico)
  - [Opciones y Flags](#opciones-y-flags)
  - [Flujo de Ejecución](#flujo-de-ejecución)
  - [Dependencias Instaladas](#dependencias-instaladas)
  - [Ejemplos de Uso](#ejemplos-de-uso)
- [health-check.sh - Validación del Entorno](#health-checksh---validación-del-entorno)
  - [Propósito](#propósito-1)
  - [Características](#características-1)
  - [Uso Básico](#uso-básico-1)
  - [Verificaciones Realizadas](#verificaciones-realizadas)
  - [Interpretación de Resultados](#interpretación-de-resultados)
  - [Ejemplos de Salida](#ejemplos-de-salida)
- [snapshot.sh - Gestión de Respaldos](#snapshotsh---gestión-de-respaldos)
  - [Propósito](#propósito-2)
  - [Características](#características-2)
  - [Uso Básico](#uso-básico-2)
  - [Comandos Disponibles](#comandos-disponibles)
  - [Estructura de Snapshots](#estructura-de-snapshots)
  - [Ejemplos de Uso](#ejemplos-de-uso-1)
- [Workflows Comunes](#workflows-comunes)
  - [Workflow 1: Instalación Inicial](#workflow-1-instalación-inicial)
  - [Workflow 2: Mantenimiento Regular](#workflow-2-mantenimiento-regular)
  - [Workflow 3: Actualización con Respaldo](#workflow-3-actualización-con-respaldo)
  - [Workflow 4: Recuperación ante Problemas](#workflow-4-recuperación-ante-problemas)
  - [Workflow 5: CI/CD y Automatización](#workflow-5-cicd-y-automatización)
- [Solución de Problemas](#solución-de-problemas)
- [Referencias](#referencias)

---

## Overview

El directorio `scripts/` contiene tres scripts principales para la gestión completa del entorno dotfiles:

| Script | Propósito | Cuándo Usarlo |
|--------|-----------|---------------|
| **bootstrap.sh** | Instalación y configuración inicial | Primera vez, reinstalación completa |
| **health-check.sh** | Validación y verificación del entorno | Después de cambios, troubleshooting |
| **snapshot.sh** | Creación y restauración de respaldos | Antes de cambios importantes, migración |

Todos los scripts son **cross-platform** (Linux + macOS) y **no destructivos por defecto**.

---

## bootstrap.sh - Instalación Automatizada

### Propósito

Script de configuración completa que automatiza la instalación de dependencias, aplicación de dotfiles con GNU Stow, y configuración del shell Zsh.

### Características

- **🔍 Detección Automática de OS**: Identifica Arch Linux, Debian/Ubuntu, macOS
- **📦 Gestión de Dependencias**: Instala herramientas core y opcionales automáticamente
- **💾 Respaldo Automático**: Crea backup de configuraciones existentes antes de aplicar
- **🔗 GNU Stow**: Aplica symlinks de todos los paquetes disponibles
- **🐚 Configuración de Shell**: Establece Zsh como shell por defecto
- **🔄 Git Submodules**: Inicializa plugins de Zsh automáticamente
- **✅ Modo Interactivo/No-Interactivo**: Confirmaciones opcionales con flag `-y`

### Uso Básico

```bash
# Instalación interactiva completa (recomendado)
cd ~/dotfiles
./scripts/bootstrap.sh

# Instalación no-interactiva (auto-confirma todo)
./scripts/bootstrap.sh -y
```

### Opciones y Flags

```bash
Usage: bootstrap.sh [OPTIONS]

OPTIONS:
    -h, --help          Mostrar ayuda
    -y, --yes           Modo no-interactivo (auto-confirmar)
    --no-backup         Saltar respaldo de configs existentes
    --no-deps           Saltar instalación de dependencias
    --no-stow           Saltar aplicación de stow
```

**Combinaciones Comunes:**

```bash
# Reinstalar solo dependencias (útil después de upgrade de OS)
./scripts/bootstrap.sh --no-stow --no-backup

# Aplicar solo stow sin reinstalar dependencias
./scripts/bootstrap.sh --no-deps --no-backup

# Modo automatizado para CI/CD
./scripts/bootstrap.sh -y
```

### Flujo de Ejecución

El script ejecuta las siguientes fases en orden:

1. **Detección de OS y Distribución**
   - Linux: Arch, Debian/Ubuntu, Fedora
   - macOS: Homebrew (Apple Silicon o Intel)

2. **Instalación de Package Manager** (solo macOS)
   - Instala Homebrew si no está presente
   - Configura PATH según arquitectura (arm64 vs x86_64)

3. **Instalación de Dependencias**
   - **Core**: `git`, `stow` (esenciales)
   - **Tools**: `neovim`, `tmux`, `zsh`, `starship`, `eza`, `bat`, `fd`, `ripgrep`, `zoxide`, `fzf`
   - **Dev**: `nodejs`, `python3`

4. **Respaldo de Configuraciones Existentes**
   - Detecta configs existentes en `~/.config/` y `~/`
   - Crea backup timestamped en `~/.dotfiles-backups/YYYYMMDD_HHMMSS/`
   - Solo respalda archivos reales (no symlinks)

5. **Inicialización de Git Submodules**
   - Clona plugins de Zsh (autosuggestions, syntax-highlighting, etc.)
   - Ejecuta `git submodule update --init --recursive`

6. **Aplicación de Stow Packages**
   - Aplica symlinks para: `nvim`, `zsh`, `zsh-plugins`, `tmux`, `starship`, `yazi`, `wezterm`, `docker`, `claude`, `git`
   - Usa `stow -R` (restow) para actualizar symlinks existentes

7. **Configuración de Shell**
   - Verifica si Zsh está en `/etc/shells`
   - Cambia shell por defecto con `chsh -s $(which zsh)`
   - Requiere logout/login para tomar efecto

8. **Post-Instalación**
   - Muestra pasos siguientes (Neovim, Tmux, verificación)
   - Indica ubicación de backup si se creó

### Dependencias Instaladas

#### Core (Esenciales)

```bash
git       # Control de versiones
stow      # Gestor de symlinks para dotfiles
```

#### Tools (Herramientas Principales)

```bash
neovim    # Editor de texto
tmux      # Multiplexor de terminal
zsh       # Shell moderno
starship  # Prompt personalizable
eza       # Reemplazo moderno de ls
bat       # Reemplazo de cat con syntax highlighting
fd        # Reemplazo de find (búsqueda rápida)
ripgrep   # Búsqueda de texto ultrarrápida (rg)
zoxide    # cd inteligente con frecuency-based jumping
fzf       # Fuzzy finder
```

#### Dev (Desarrollo)

```bash
nodejs    # JavaScript runtime
python3   # Python interpreter
```

**Instalación por Plataforma:**

| Dependencia | Arch Linux | Debian/Ubuntu | macOS |
|-------------|------------|---------------|-------|
| Core + Tools | `pacman -S` | `apt install` + sources externas | `brew install` |
| Starship | pacman | curl script | brew |
| Eza | pacman | External repo (deb.gierens.de) | brew |
| Bat | pacman | apt (como `batcat`) | brew |

### Ejemplos de Uso

#### Ejemplo 1: Primera Instalación (Nueva Máquina)

```bash
# Clonar repositorio
git clone https://github.com/usuario/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Ejecutar bootstrap (interactivo)
./scripts/bootstrap.sh

# Salida esperada:
# ╔════════════════════════════════════════════════════════════════╗
# ║  DOTFILES BOOTSTRAP                                            ║
# ╚════════════════════════════════════════════════════════════════╝
#
# → Detecting operating system...
# ✓ Detected: Linux (arch)
#
# → Installing dependencies...
# ℹ  Installing via pacman...
# ✓ Dependencies installed
#
# → Checking for existing configurations...
# ⚠  Found existing configurations
# Create backup before proceeding? (y/N): y
# ✓ Backed up: nvim
# ✓ Backup created at: /home/usuario/.dotfiles-backups/20240106_143022
#
# → Initializing git submodules...
# ✓ Submodules initialized
#
# → Applying dotfiles with GNU Stow...
# ✓ Stowed: nvim
# ✓ Stowed: zsh
# ✓ Stowed: tmux
# ℹ  Stowed 9 packages (0 failed)
#
# → Configuring default shell...
# Set Zsh as default shell? (y/N): y
# ✓ Default shell set to Zsh (restart required)
#
# → Post-installation notes
#
# ℹ  Next steps:
#   1. exec zsh - Start new Zsh session
#   2. nvim - Open Neovim (plugins auto-install)
#   3. git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
#      Then in tmux: Ctrl+s I to install plugins
#
# ✓ Bootstrap complete!
```

#### Ejemplo 2: Reinstalación Solo de Stow (Actualización)

```bash
# Actualizar repositorio
cd ~/dotfiles
git pull

# Reinstalar symlinks sin tocar dependencias ni backup
./scripts/bootstrap.sh --no-deps --no-backup

# Salida:
# → Detecting operating system...
# ✓ Detected: macOS
#
# → Initializing git submodules...
# ✓ Submodules initialized
#
# → Applying dotfiles with GNU Stow...
# ✓ Stowed: nvim
# ✓ Stowed: zsh
# [...]
```

#### Ejemplo 3: Modo CI/CD (GitHub Actions)

```bash
# En workflow de GitHub Actions
./scripts/bootstrap.sh -y --no-backup

# No solicita confirmaciones, ideal para automatización
```

---

## health-check.sh - Validación del Entorno

### Propósito

Script de verificación completa que valida la instalación de dotfiles, dependencias, symlinks, y configuraciones de herramientas. Diagnóstico ideal para troubleshooting.

### Características

- **✅ Verificación de Binarios**: Detecta herramientas instaladas y versiones
- **🔗 Validación de Symlinks**: Confirma que apuntan al repositorio dotfiles
- **🩺 Neovim Healthcheck**: Ejecuta `:checkhealth` automáticamente
- **🐚 Validación de Zsh**: Verifica plugins, shell por defecto, Starship
- **🖥️ Validación de Tmux**: Chequea TPM y plugins
- **📊 Git Submodules**: Confirma inicialización de submodules
- **📈 Reporte de Resumen**: Cuenta de checks passed/failed/warnings

### Uso Básico

```bash
cd ~/dotfiles
./scripts/health-check.sh
```

**No requiere argumentos** - ejecuta todas las verificaciones automáticamente.

### Verificaciones Realizadas

#### 1. Required Binaries (Esenciales)

Verifica presencia y versión de:

```bash
✓ git found - git version 2.43.0
✓ stow found - stow 2.4.0
✓ nvim found - NVIM v0.9.5
✓ tmux found - tmux 3.4
✓ zsh found - zsh 5.9
```

Si **falta una herramienta esencial**, marca como `✗ FAILED`.

#### 2. Optional Binaries (Recomendados)

Verifica herramientas opcionales:

```bash
✓ starship found (optional tool)
✓ eza found (optional tool)
✓ bat found (optional tool)
✓ fd found (optional tool)
✓ rg found (optional tool)
✓ zoxide found (optional tool)
✓ fzf found (optional tool)
⚠  node not found (optional but recommended)
⚠  python3 not found (optional but recommended)
```

Si **falta una herramienta opcional**, marca como `⚠ WARNING` (no crítico).

#### 3. Symlink Verification

Confirma que los symlinks apuntan al repositorio dotfiles:

```bash
✓ nvim → nvim
✓ tmux → tmux
✓ zsh → zsh
✓ .zsh → zsh-plugins
✓ starship.toml → starship
⚠  yazi symlink points elsewhere: /opt/yazi
⚠  wezterm not found (package not installed)
```

**Posibles estados:**
- `✓` Symlink correcto apuntando a dotfiles
- `⚠` Symlink existe pero apunta a otra ubicación
- `⚠` Archivo existe pero no es symlink (config manual)
- `⚠` No encontrado (paquete no instalado con stow)

#### 4. Neovim Configuration

Verifica configuración de Neovim:

```bash
✓ Neovim config directory exists
✓ init.lua found
✓ lazy.nvim plugin manager installed

Running :checkhealth...
✓ Neovim health check completed
⚠  Health check reported errors (check manually: nvim -c checkhealth)
```

Ejecuta `:checkhealth` automáticamente y detecta errores. Si hay problemas, recomienda revisión manual.

#### 5. Zsh Configuration

Verifica configuración de Zsh:

```bash
✓ Zsh is default shell
✓ Zsh config directory exists
✓ zsh-autosuggestions installed (git submodule)
✓ zsh-syntax-highlighting installed (git submodule)
✓ zsh-history-substring-search installed (git submodule)
✓ Starship prompt configured
```

**Chequea:**
- Shell por defecto (`$SHELL`)
- Directorio de config (`~/.config/zsh`)
- Plugins como git submodules
- Starship binary y config

#### 6. Tmux Configuration

Verifica configuración de Tmux:

```bash
✓ Tmux config found
✓ TPM (Tmux Plugin Manager) installed
✓ Tmux plugins initialized
```

**Chequea:**
- Config file (`~/.config/tmux/tmux.conf` o `~/.tmux.conf`)
- TPM instalado (`~/.tmux/plugins/tpm`)
- Plugins inicializados (e.g., `vim-tmux-navigator`)

Si TPM no está instalado, proporciona comando para instalarlo.

#### 7. Git Submodules

Verifica estado de submodules:

```bash
✓ Git submodules initialized
```

O:

```bash
⚠  Submodules not initialized (run: git submodule update --init --recursive)
```

### Interpretación de Resultados

El script genera un resumen al final:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Health Check Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ Passed:   32
  ✗ Failed:   0
  ⚠ Warnings: 3
  Total:     35

✓ All checks passed! Dotfiles are healthy.
```

**Interpretación:**

| Resultado | Significado | Acción Requerida |
|-----------|-------------|------------------|
| `✓ All checks passed` | Todo funcional | Ninguna |
| `⚠ Some warnings found` | Funcional con advertencias | Revisar warnings (no crítico) |
| `✗ Critical issues found` | Sistema no funcional | **Corregir errores antes de usar** |

**Exit Codes:**

```bash
echo $?
# 0 = Success (sin errores críticos)
# 1 = Failed (errores críticos encontrados)
```

### Ejemplos de Salida

#### Ejemplo 1: Sistema Saludable

```bash
./scripts/health-check.sh

╔════════════════════════════════════════════════════════════════╗
║  DOTFILES HEALTH CHECK                                         ║
╚════════════════════════════════════════════════════════════════╝

▶ Required Binaries
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ git found - git version 2.43.0
  ✓ stow found - stow 2.4.0
  ✓ nvim found - NVIM v0.9.5
  ✓ tmux found - tmux 3.4
  ✓ zsh found - zsh 5.9

  ✓ starship found (optional tool)
  ✓ eza found (optional tool)
  ✓ bat found (optional tool)
  ✓ fd found (optional tool)
  ✓ rg found (optional tool)
  ✓ zoxide found (optional tool)
  ✓ fzf found (optional tool)
  ✓ node found (optional tool)
  ✓ python3 found (optional tool)

▶ Symlink Verification
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ nvim → nvim
  ✓ tmux → tmux
  ✓ zsh → zsh
  ✓ .zsh → zsh-plugins
  ✓ starship.toml → starship
  ✓ yazi → yazi
  ✓ wezterm → wezterm

▶ Neovim Configuration
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ Neovim config directory exists
  ✓ init.lua found
  ✓ lazy.nvim plugin manager installed

  Running :checkhealth...
  ✓ Neovim health check completed

▶ Zsh Configuration
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ Zsh is default shell
  ✓ Zsh config directory exists
  ✓ zsh-autosuggestions installed (git submodule)
  ✓ zsh-syntax-highlighting installed (git submodule)
  ✓ zsh-history-substring-search installed (git submodule)
  ✓ Starship prompt configured

▶ Tmux Configuration
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ Tmux config found
  ✓ TPM (Tmux Plugin Manager) installed
  ✓ Tmux plugins initialized

▶ Git Submodules
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ Git submodules initialized

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Health Check Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ Passed:   28
  ✗ Failed:   0
  ⚠ Warnings: 0
  Total:     28

✓ All checks passed! Dotfiles are healthy.
```

#### Ejemplo 2: Sistema con Warnings (No Crítico)

```bash
./scripts/health-check.sh

[... output ...]

▶ Symlink Verification
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ nvim → nvim
  ✓ tmux → tmux
  ⚠  wezterm not found (package not installed)

[...]

▶ Tmux Configuration
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ Tmux config found
  ⚠  TPM not installed (run: git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Health Check Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ Passed:   25
  ✗ Failed:   0
  ⚠ Warnings: 3
  Total:     28

⚠ Some warnings found. Review above for details.
```

**Acción:** Sistema funcional, pero revisar warnings. Instalar TPM si quieres usar plugins de Tmux.

#### Ejemplo 3: Sistema con Errores Críticos

```bash
./scripts/health-check.sh

[...]

▶ Required Binaries
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ git found - git version 2.43.0
  ✗ stow not found (REQUIRED)
  ✗ nvim not found (REQUIRED)
  ✓ tmux found - tmux 3.4
  ✓ zsh found - zsh 5.9

[...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Health Check Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ Passed:   20
  ✗ Failed:   2
  ⚠ Warnings: 5
  Total:     27

✗ Critical issues found. Please fix before using dotfiles.
```

**Acción:** **NO USAR** hasta corregir errores. Ejecutar `./scripts/bootstrap.sh` para instalar dependencias faltantes.

---

## snapshot.sh - Gestión de Respaldos

### Propósito

Script de respaldo y restauración que crea snapshots comprimidos de configuraciones y permite rollback a estados anteriores. Esencial antes de cambios importantes o para migraciones entre máquinas.

### Características

- **📸 Snapshots Etiquetados**: Crea backups con etiquetas descriptivas
- **🗜️ Compresión tar.gz**: Snapshots compactos y portables
- **📂 Metadata**: Incluye info de fecha, hostname, usuario, OS
- **🔄 Rollback Seguro**: Restaura desde snapshots con confirmación
- **📋 Listado de Snapshots**: Visualiza todos los snapshots disponibles
- **💾 Pre-Rollback Backup**: Crea backup automático antes de restaurar
- **🔗 Resolución de Symlinks**: Copia contenido real, no symlinks

### Uso Básico

```bash
# Crear snapshot con etiqueta
cd ~/dotfiles
./scripts/snapshot.sh create "pre-update"

# Listar snapshots disponibles
./scripts/snapshot.sh list

# Restaurar desde snapshot
./scripts/snapshot.sh rollback <snapshot-name>.tar.gz
```

### Comandos Disponibles

```bash
Usage: snapshot.sh [COMMAND] [OPTIONS]

COMMANDS:
    create [LABEL]          Crear snapshot con etiqueta opcional
    list                    Listar todos los snapshots disponibles
    rollback <SNAPSHOT>     Restaurar desde snapshot
    help                    Mostrar ayuda
```

#### create - Crear Snapshot

Crea un snapshot comprimido de todas las configuraciones:

```bash
# Con etiqueta descriptiva (recomendado)
./scripts/snapshot.sh create "pre-neovim-refactor"
./scripts/snapshot.sh create "stable-2024-01"

# Sin etiqueta (usa 'manual' por defecto)
./scripts/snapshot.sh create
```

**Qué se respalda:**

```
~/.config/nvim       # Configuración de Neovim
~/.config/tmux       # Configuración de Tmux
~/.config/zsh        # Configuración de Zsh
~/.config/yazi       # Configuración de Yazi
~/.config/wezterm    # Configuración de WezTerm
~/.zsh               # Plugins de Zsh (zsh-plugins)
~/.tmux              # Plugins de Tmux
```

**Ubicación de Snapshots:**

```bash
~/.dotfiles-snapshots/
└── dotfiles_<LABEL>_YYYYMMDD_HHMMSS.tar.gz
```

**Ejemplo:**

```bash
./scripts/snapshot.sh create "pre-update"

╔════════════════════════════════════════════════════════════════╗
║  DOTFILES SNAPSHOT                                             ║
╚════════════════════════════════════════════════════════════════╝

→ Creating snapshot: pre-update

✓ Captured: nvim
✓ Captured: tmux
✓ Captured: zsh
✓ Captured: .zsh
✓ Captured: yazi
⚠  Could not copy wezterm (may be broken symlink)

→ Creating archive...

✓ Snapshot created successfully
ℹ  Location: /home/usuario/.dotfiles-snapshots/dotfiles_pre-update_20240106_143022.tar.gz
ℹ  Size: 2.4M
ℹ  Captured: 5 items (1 skipped)
```

#### list - Listar Snapshots

Muestra todos los snapshots disponibles con metadata:

```bash
./scripts/snapshot.sh list
# O shorthand:
./scripts/snapshot.sh ls
```

**Ejemplo de Salida:**

```bash
╔════════════════════════════════════════════════════════════════╗
║  DOTFILES SNAPSHOT                                             ║
╚════════════════════════════════════════════════════════════════╝

→ Available snapshots

No.   Snapshot                                      Size       Created
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1     dotfiles_pre-update_20240106_143022.tar.gz   2.4M       2024-01-06 14:30:22
2     dotfiles_stable-2024_20240105_120000.tar.gz  2.3M       2024-01-05 12:00:00
3     dotfiles_manual_20240104_093000.tar.gz       2.5M       2024-01-04 09:30:00
```

**Información Mostrada:**

- **No.**: Número de índice
- **Snapshot**: Nombre completo del archivo
- **Size**: Tamaño del archivo tar.gz
- **Created**: Fecha y hora de creación (cross-platform: Linux y macOS)

#### rollback - Restaurar desde Snapshot

Restaura configuraciones desde un snapshot existente:

```bash
# Por nombre completo
./scripts/snapshot.sh rollback dotfiles_pre-update_20240106_143022.tar.gz

# Por nombre corto (busca en ~/.dotfiles-snapshots/)
./scripts/snapshot.sh rollback dotfiles_pre-update_20240106_143022.tar.gz

# Alias: restore
./scripts/snapshot.sh restore <snapshot-name>
```

**Proceso de Rollback:**

1. **Validación**: Verifica que el snapshot existe
2. **Confirmación**: Solicita confirmación (es destructivo)
3. **Pre-Rollback Backup**: Crea snapshot automático del estado actual (`dotfiles_pre-rollback_TIMESTAMP.tar.gz`)
4. **Extracción**: Descomprime snapshot a directorio temporal
5. **Restauración**: Copia archivos a ubicaciones correspondientes
6. **Limpieza**: Elimina archivos temporales
7. **Reporte**: Muestra resultado (items restored/failed)

**Ejemplo:**

```bash
./scripts/snapshot.sh rollback dotfiles_stable-2024_20240105_120000.tar.gz

╔════════════════════════════════════════════════════════════════╗
║  DOTFILES SNAPSHOT                                             ║
╚════════════════════════════════════════════════════════════════╝

→ Rolling back from snapshot

ℹ  Snapshot: dotfiles_stable-2024_20240105_120000.tar.gz

⚠  This will replace current configurations!
Continue? (y/N): y

→ Creating pre-rollback backup...

→ Extracting snapshot...

→ Restoring configurations...
✓ Restored: nvim
✓ Restored: tmux
✓ Restored: zsh
✓ Restored: .zsh
✓ Restored: yazi

✓ Rollback completed
ℹ  Restored: 5 items (0 failed)
```

**⚠️ Importante:**

- **Destructivo**: Reemplaza configuraciones actuales
- **Symlinks Eliminados**: Rollback remueve symlinks de Stow y restaura archivos directos
- **Pre-Rollback Backup**: Siempre crea backup antes de restaurar (safety net)
- **Requerido Re-Stow**: Después de rollback, ejecutar `stow -R <paquete>` si quieres volver a symlinks

### Estructura de Snapshots

Cada snapshot es un archivo `.tar.gz` con estructura preservada:

```
dotfiles_<LABEL>_YYYYMMDD_HHMMSS.tar.gz
└── dotfiles-snapshot/
    ├── snapshot-info.txt         # Metadata del snapshot
    ├── .config/
    │   ├── nvim/                # Neovim config completo
    │   ├── tmux/                # Tmux config
    │   ├── zsh/                 # Zsh config
    │   ├── yazi/                # Yazi config
    │   └── wezterm/             # WezTerm config
    ├── .zsh/                     # Plugins de Zsh
    │   ├── zsh-autosuggestions/
    │   ├── zsh-syntax-highlighting/
    │   └── zsh-history-substring-search/
    └── .tmux/                    # Plugins de Tmux
        └── plugins/
```

**snapshot-info.txt** contiene:

```
Dotfiles Snapshot
=================
Label: pre-update
Created: Sat Jan  6 14:30:22 UTC 2024
Hostname: laptop-arch
User: usuario
OS: Linux

Contents:
.config/nvim/
.config/tmux/
.config/zsh/
.zsh/zsh-autosuggestions/
[...]
```

### Ejemplos de Uso

#### Ejemplo 1: Snapshot Antes de Actualización

```bash
# Antes de actualizar dotfiles desde Git
cd ~/dotfiles
./scripts/snapshot.sh create "pre-git-pull"
git pull
./scripts/health-check.sh

# Si algo salió mal:
./scripts/snapshot.sh rollback dotfiles_pre-git-pull_*.tar.gz
```

#### Ejemplo 2: Snapshots de Hitos (Milestones)

```bash
# Crear snapshot de estado estable conocido
./scripts/snapshot.sh create "stable-2024-01-working"

# Experimentar con cambios...
# Si funcionan:
./scripts/snapshot.sh create "stable-2024-02-updated"

# Si no funcionan:
./scripts/snapshot.sh list
./scripts/snapshot.sh rollback dotfiles_stable-2024-01-working_*.tar.gz
```

#### Ejemplo 3: Migración Entre Máquinas

```bash
# En máquina original:
cd ~/dotfiles
./scripts/snapshot.sh create "migration-laptop-to-desktop"
scp ~/.dotfiles-snapshots/dotfiles_migration-*.tar.gz desktop:~/

# En máquina nueva:
cd ~
tar -xzf dotfiles_migration-*.tar.gz
cd dotfiles-snapshot
# Copiar configs manualmente o usar rollback
```

#### Ejemplo 4: Testing de Configuraciones

```bash
# Crear snapshot de baseline
./scripts/snapshot.sh create "baseline-before-experiment"

# Probar configuración experimental
nvim ~/.config/nvim/lua/plugins/new-plugin.lua
# Testear...

# Si no funciona:
./scripts/snapshot.sh rollback dotfiles_baseline-before-experiment_*.tar.gz
cd ~/dotfiles
stow -R nvim  # Re-aplicar symlinks
```

---

## Workflows Comunes

### Workflow 1: Instalación Inicial

**Contexto:** Primera vez instalando dotfiles en nueva máquina.

```bash
# 1. Clonar repositorio
git clone https://github.com/usuario/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Ejecutar bootstrap (instalación completa)
./scripts/bootstrap.sh

# 3. Iniciar nueva sesión de Zsh
exec zsh

# 4. Verificar instalación
cd ~/dotfiles
./scripts/health-check.sh

# 5. Instalar Tmux plugins (si TPM no está inicializado)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux
# Dentro de tmux: Ctrl+s I

# 6. Abrir Neovim (plugins se instalan automáticamente)
nvim

# 7. Crear snapshot de estado inicial funcional
cd ~/dotfiles
./scripts/snapshot.sh create "initial-setup-working"
```

**Resultado:** Sistema completo y funcional con snapshot de baseline.

### Workflow 2: Mantenimiento Regular

**Contexto:** Revisión periódica de salud del sistema (semanal/mensual).

```bash
# Ejecutar health check
cd ~/dotfiles
./scripts/health-check.sh

# Si hay warnings, investigar:
# - Plugins desactualizados
# - Dependencias faltantes
# - Configs modificadas manualmente

# Actualizar submodules (plugins de Zsh)
git submodule update --remote

# Verificar que todo sigue funcional
./scripts/health-check.sh

# Crear snapshot de estado actual
./scripts/snapshot.sh create "monthly-$(date +%Y-%m)"
```

**Resultado:** Sistema verificado y snapshot mensual creado.

### Workflow 3: Actualización con Respaldo

**Contexto:** Actualizar dotfiles desde Git con safety net.

```bash
cd ~/dotfiles

# 1. Crear snapshot de estado actual (PRE-actualización)
./scripts/snapshot.sh create "pre-update"

# 2. Verificar estado actual
./scripts/health-check.sh

# 3. Actualizar repositorio
git pull

# 4. Re-aplicar stow (actualizar symlinks)
stow -R nvim zsh tmux starship yazi wezterm

# 5. Verificar que todo funciona
./scripts/health-check.sh

# 6. Testear en uso real
nvim
tmux
# ...

# 7. Si todo funciona, crear snapshot POST-actualización
./scripts/snapshot.sh create "post-update-stable"

# 8. Si algo salió mal, rollback
# ./scripts/snapshot.sh rollback dotfiles_pre-update_*.tar.gz
```

**Resultado:** Actualización segura con capacidad de rollback.

### Workflow 4: Recuperación ante Problemas

**Contexto:** Algo se rompió, necesitas recuperar configuración anterior.

```bash
# 1. Verificar estado actual (diagnóstico)
cd ~/dotfiles
./scripts/health-check.sh

# 2. Listar snapshots disponibles
./scripts/snapshot.sh list

# 3. Restaurar desde último snapshot funcional
./scripts/snapshot.sh rollback dotfiles_stable-2024-01_*.tar.gz
# Confirmar con 'y' cuando solicite

# 4. Re-aplicar stow si quieres volver a symlinks
stow -R nvim zsh tmux

# 5. Verificar recuperación
./scripts/health-check.sh

# 6. Reiniciar shell/servicios si es necesario
exec zsh
tmux kill-server && tmux
```

**Resultado:** Sistema recuperado a estado funcional anterior.

### Workflow 5: CI/CD y Automatización

**Contexto:** Testing automatizado de dotfiles en GitHub Actions.

```yaml
# .github/workflows/test-dotfiles.yml
name: Test Dotfiles

on: [push, pull_request]

jobs:
  test-linux:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          submodules: recursive

      - name: Bootstrap dotfiles
        run: ./scripts/bootstrap.sh -y --no-backup

      - name: Run health check
        run: ./scripts/health-check.sh

      - name: Create snapshot
        run: ./scripts/snapshot.sh create "ci-test"

      - name: Upload snapshot artifact
        uses: actions/upload-artifact@v3
        with:
          name: dotfiles-snapshot
          path: ~/.dotfiles-snapshots/

  test-macos:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
        with:
          submodules: recursive

      - name: Bootstrap dotfiles
        run: ./scripts/bootstrap.sh -y --no-backup

      - name: Run health check
        run: ./scripts/health-check.sh
```

**Resultado:** Testing automático en Linux y macOS en cada push.

---

## Solución de Problemas

### bootstrap.sh

#### Problema: "Stow conflicts detected"

```
ERROR: stow: Existing target is neither a link nor a directory: .config/nvim
```

**Causa:** Ya existe configuración en `~/.config/nvim` que no es symlink.

**Solución:**

```bash
# Opción 1: Dejar que bootstrap cree backup
./scripts/bootstrap.sh  # Responder 'y' a backup

# Opción 2: Backup manual y limpieza
mv ~/.config/nvim ~/.config/nvim.backup
./scripts/bootstrap.sh --no-backup
```

#### Problema: "Dependencies installation failed"

```
E: Unable to locate package neovim
```

**Causa:** Sistema no soportado o repositorios desactualizados.

**Solución:**

```bash
# Debian/Ubuntu: Actualizar repos
sudo apt update

# Añadir PPA para Neovim (si es muy antiguo)
sudo add-apt-repository ppa:neovim-ppa/stable
sudo apt update
sudo apt install neovim

# Luego reinstalar dotfiles
./scripts/bootstrap.sh --no-deps  # Skip deps, solo stow
```

#### Problema: "Submodules not updating"

```
⚠  Submodules not initialized
```

**Causa:** `.gitmodules` corrupto o submodules no descargados.

**Solución:**

```bash
# Reinicializar submodules manualmente
git submodule deinit --all -f
git submodule update --init --recursive

# O desde cero:
rm -rf zsh-plugins/.zsh/*
git submodule update --init --recursive
```

### health-check.sh

#### Problema: "nvim health check failed"

```
⚠  Health check reported errors
```

**Causa:** Plugins faltantes, LSP servers no instalados, o config corrupta.

**Solución:**

```bash
# Ejecutar checkhealth manualmente para ver detalles
nvim -c checkhealth

# Reinstalar lazy.nvim
rm -rf ~/.local/share/nvim/lazy
nvim  # Plugins se reinstalarán automáticamente

# Reinstalar Mason LSP servers
nvim
:Mason
# Instalar servers manualmente o ejecutar :MasonInstallAll
```

#### Problema: "Symlinks point elsewhere"

```
⚠  nvim symlink points elsewhere: /opt/nvim
```

**Causa:** Instalación manual previa de configs que interfieren.

**Solución:**

```bash
# Remover symlink incorrecto
rm ~/.config/nvim

# Re-aplicar stow
cd ~/dotfiles
stow -R nvim

# Verificar
./scripts/health-check.sh
```

### snapshot.sh

#### Problema: "Snapshot restore breaks symlinks"

**Causa:** Rollback copia archivos directos, eliminando symlinks de Stow.

**Solución:**

```bash
# Después de rollback, re-aplicar stow
cd ~/dotfiles
stow -R nvim zsh tmux starship yazi wezterm

# Verificar
./scripts/health-check.sh
```

#### Problema: "Snapshot size too large"

```
ℹ  Size: 500M
```

**Causa:** Inclusión de archivos grandes (cache, plugins compilados).

**Solución:**

Los snapshots solo incluyen configuraciones, no cache ni builds. Si es muy grande:

```bash
# Limpiar cache de Neovim antes de snapshot
rm -rf ~/.local/share/nvim/{shada,swap,undo}

# Limpiar lazy.nvim lockfile
rm ~/.config/nvim/lazy-lock.json

# Luego crear snapshot
./scripts/snapshot.sh create "clean-snapshot"
```

### Cross-Platform Issues

#### macOS: "readlink: illegal option -- f"

**Causa:** macOS usa BSD `readlink` sin flag `-f`.

**Solución:** Scripts ya manejan esto automáticamente con detección de OS. Si persiste:

```bash
# Instalar GNU coreutils (opcional)
brew install coreutils
# Luego usa greadlink en lugar de readlink
```

#### macOS: "stat: illegal option -- c"

**Causa:** macOS usa BSD `stat` con sintaxis diferente.

**Solución:** Scripts ya manejan esto (`stat -f` en macOS, `stat -c` en Linux).

---

## Referencias

### Documentación Relacionada

- [INSTALL.md](../docs/INSTALL.md) - Guía de instalación completa
- [ARCHITECTURE.md](../docs/ARCHITECTURE.md) - Arquitectura del proyecto y GNU Stow
- [Troubleshooting](../docs/reference/troubleshooting.md) - Solución de problemas general

### Scripts

- **bootstrap.sh**: `/home/usuario/dotfiles/scripts/bootstrap.sh`
- **health-check.sh**: `/home/usuario/dotfiles/scripts/health-check.sh`
- **snapshot.sh**: `/home/usuario/dotfiles/scripts/snapshot.sh`

### Recursos Externos

- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html)
- [Bash Best Practices](https://bertvv.github.io/cheat-sheets/Bash.html)
- [Git Submodules Documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)

### Ubicaciones de Archivos

```
~/dotfiles/                                  # Repositorio principal
~/.dotfiles-backups/                        # Backups de bootstrap
~/.dotfiles-snapshots/                      # Snapshots de snapshot.sh
~/.config/nvim/                             # Neovim config (symlink)
~/.config/tmux/                             # Tmux config (symlink)
~/.config/zsh/                              # Zsh config (symlink)
~/.zsh/                                     # Zsh plugins (symlink)
~/.tmux/                                    # Tmux plugins (directorio)
```

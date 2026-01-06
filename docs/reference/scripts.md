# Scripts - Documentación de Utilidades

Esta guía documenta los scripts de utilidad disponibles en `scripts/` para gestionar y mantener el entorno de dotfiles.

## Índice

1. [bootstrap.sh - Instalación Automática](#bootstrapsh---instalación-automática)
2. [health-check.sh - Validación del Sistema](#health-checksh---validación-del-sistema)
3. [snapshot.sh - Backups y Restauración](#snapshotsh---backups-y-restauración)

---

## bootstrap.sh - Instalación Automática

**Ubicación**: `scripts/bootstrap.sh`
**Propósito**: Configuración automatizada inicial del entorno de dotfiles

### Descripción

Script cross-platform que automatiza la instalación completa del entorno de desarrollo desde cero. Soporta Arch Linux, Debian/Ubuntu y macOS.

### Características

- **Detección automática de OS**: Identifica el sistema operativo y distribución
- **Instalación de dependencias**: Instala todas las herramientas necesarias
- **Backup inteligente**: Crea respaldo de configuraciones existentes
- **Aplicación con Stow**: Crea enlaces simbólicos automáticamente
- **Configuración de shell**: Cambia Zsh como shell por defecto
- **Inicialización de submodules**: Configura plugins de git submodules

### Uso Básico

```bash
cd ~/dotfiles
./scripts/bootstrap.sh
```

### Opciones

| Opción | Descripción |
|--------|-------------|
| `-h`, `--help` | Mostrar ayuda |
| `-y`, `--yes` | Modo no interactivo (auto-confirma todo) |
| `--no-backup` | Saltar backup de configs existentes |
| `--no-deps` | Saltar instalación de dependencias |
| `--no-stow` | Saltar aplicación de Stow |

### Ejemplos

**Instalación Completa Interactiva:**
```bash
./scripts/bootstrap.sh
```
Preguntará confirmación para cada paso.

**Instalación Automatizada:**
```bash
./scripts/bootstrap.sh -y
```
Ejecuta todo automáticamente sin preguntar.

**Instalar Solo Dependencias:**
```bash
./scripts/bootstrap.sh --no-stow --no-backup
```
Solo instala herramientas, no aplica configuraciones.

**Sin Backup (No Recomendado):**
```bash
./scripts/bootstrap.sh --no-backup
```
Salta el paso de backup (usar con precaución).

### Dependencias Instaladas

**Core (Esenciales):**
- `git` - Control de versiones
- `stow` - Gestor de enlaces simbólicos

**Herramientas (Recomendadas):**
- `neovim` - Editor modal
- `tmux` - Multiplexor de terminal
- `zsh` - Shell interactivo
- `starship` - Prompt inteligente
- `eza` - Reemplazo de ls con colores
- `bat` - Reemplazo de cat con syntax highlight
- `fd` - Reemplazo de find
- `ripgrep` - Búsqueda de texto ultra-rápida
- `zoxide` - cd inteligente
- `fzf` - Fuzzy finder

**Desarrollo:**
- `nodejs` - Runtime JavaScript
- `python3` - Runtime Python

### Proceso de Instalación

El script ejecuta los siguientes pasos en orden:

1. **Detección de OS**: Identifica sistema operativo y distribución
2. **Instalación de Package Manager**: Homebrew en macOS (si no existe)
3. **Instalación de Dependencias**: Instala todas las herramientas necesarias
4. **Backup de Configs**: Respalda configuraciones existentes a `~/.dotfiles-backups/`
5. **Inicialización de Submodules**: Clona plugins de Zsh
6. **Aplicación de Stow**: Crea enlaces simbólicos para cada paquete
7. **Configuración de Shell**: Cambia Zsh como shell por defecto
8. **Post-Install**: Muestra instrucciones de próximos pasos

### Paquetes Aplicados con Stow

El script aplica los siguientes paquetes automáticamente:
- `nvim` → `~/.config/nvim/`
- `zsh` → `~/.config/zsh/`
- `zsh-plugins` → `~/.zsh/`
- `tmux` → `~/.config/tmux/`
- `starship` → `~/.config/starship.toml`
- `yazi` → `~/.config/yazi/`
- `wezterm` → `~/.config/wezterm/`
- `docker` → `~/.config/docker/`
- `claude` → `~/.claude/`
- `git` → `~/.gitconfig`

### Ubicación de Backups

Los backups se guardan en:
```
~/.dotfiles-backups/YYYYMMDD_HHMMSS/
```

Ejemplo:
```
~/.dotfiles-backups/20260106_143022/
├── nvim/
├── tmux/
├── zsh/
└── ...
```

### Siguientes Pasos Post-Instalación

Después de ejecutar bootstrap, sigue estos pasos:

1. **Iniciar Zsh:**
   ```bash
   exec zsh
   ```

2. **Abrir Neovim** (plugins se auto-instalan):
   ```bash
   nvim
   ```

3. **Instalar TPM** (Tmux Plugin Manager):
   ```bash
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
   ```

4. **Instalar Plugins de Tmux** (dentro de tmux):
   - Presiona: `Ctrl+s` luego `Shift+I`

5. **Verificar Instalación:**
   ```bash
   ./scripts/health-check.sh
   ```

### Troubleshooting

**Error: "Stow conflicts detected"**
- Solución: Usar `--no-backup` SOLO si estás seguro de sobrescribir
- O mover manualmente los archivos conflictivos

**Error: "Zsh not found in /etc/shells"**
- El script agrega Zsh automáticamente
- Si falla, agregar manualmente: `which zsh | sudo tee -a /etc/shells`

**Error: "Permission denied on chsh"**
- Ejecutar: `sudo chsh -s $(which zsh) $USER`

**Homebrew no se instala en macOS**
- Verificar conexión a internet
- Instalar manualmente: `https://brew.sh/`

---

## health-check.sh - Validación del Sistema

**Ubicación**: `scripts/health-check.sh`
**Propósito**: Verificación completa de la instalación y salud del sistema de dotfiles

### Descripción

Script de diagnóstico que valida todos los componentes del entorno de desarrollo, desde binarios requeridos hasta configuraciones de plugins.

### Características

- **Verificación de binarios**: Comprueba herramientas instaladas con versiones
- **Validación de symlinks**: Verifica enlaces simbólicos de Stow
- **Health check de Neovim**: Ejecuta `:checkhealth` automáticamente
- **Validación de Zsh**: Comprueba shell, plugins y Starship
- **Verificación de Tmux**: Valida config y TPM
- **Estado de submodules**: Comprueba git submodules
- **Resumen con estadísticas**: Reporte completo de checks pasados/fallidos

### Uso

```bash
cd ~/dotfiles
./scripts/health-check.sh
```

### Salida

El script genera un reporte organizado por secciones:

```
╔════════════════════════════════════════════════════════════════╗
║  DOTFILES HEALTH CHECK                                         ║
╚════════════════════════════════════════════════════════════════╝

▶ Required Binaries
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ git found - git version 2.43.0
  ✓ stow found - stow 2.3.1
  ✓ nvim found - NVIM v0.9.5
  ✓ tmux found - tmux 3.3a
  ✓ zsh found - zsh 5.9

  ✓ starship found (optional tool)
  ✓ eza found (optional tool)
  ...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Health Check Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ Passed:   24
  ✗ Failed:   0
  ⚠ Warnings: 2
  Total:      26

✓ All checks passed! Dotfiles are healthy.
```

### Checks Realizados

#### 1. Required Binaries
Verifica instalación y versiones de:
- `git`, `stow`, `nvim`, `tmux`, `zsh` (REQUIRED)
- `starship`, `eza`, `bat`, `fd`, `rg`, `zoxide`, `fzf`, `node`, `python3` (OPTIONAL)

#### 2. Symlink Verification
Valida que los enlaces simbólicos apunten correctamente:
- `~/.config/nvim` → `dotfiles/nvim`
- `~/.config/tmux` → `dotfiles/tmux`
- `~/.config/zsh` → `dotfiles/zsh`
- `~/.zsh` → `dotfiles/zsh-plugins`
- `~/.config/starship.toml` → `dotfiles/starship`
- `~/.config/yazi` → `dotfiles/yazi`
- `~/.config/wezterm` → `dotfiles/wezterm`

#### 3. Neovim Configuration
- Verifica directorio de config (`~/.config/nvim`)
- Comprueba `init.lua`
- Valida instalación de `lazy.nvim`
- Ejecuta `:checkhealth` automáticamente
- Reporta errores encontrados en health check

#### 4. Zsh Configuration
- Verifica que Zsh es el shell por defecto
- Valida directorio de config (`~/.config/zsh`)
- Comprueba plugins (autosuggestions, syntax-highlighting, history-substring-search)
- Verifica instalación y config de Starship

#### 5. Tmux Configuration
- Comprueba archivo de configuración
- Verifica instalación de TPM (Tmux Plugin Manager)
- Valida que plugins estén inicializados

#### 6. Git Submodules
- Verifica estado de submodules
- Reporta si necesitan inicialización

### Interpretación de Resultados

**Símbolos:**
- ✓ (Verde) - Check pasado correctamente
- ✗ (Rojo) - Check fallido (acción requerida)
- ⚠ (Amarillo) - Advertencia (opcional pero recomendado)

**Estados:**
- `✓ All checks passed!` - Todo funcionando correctamente
- `⚠ Some warnings found` - Funcional pero con mejoras pendientes
- `✗ Critical issues found` - Problemas críticos requieren atención

### Ejemplos de Uso

**Verificación Completa:**
```bash
./scripts/health-check.sh
```

**Verificar Después de Bootstrap:**
```bash
./scripts/bootstrap.sh -y
./scripts/health-check.sh
```

**Verificar Antes de Actualizar:**
```bash
./scripts/snapshot.sh "pre-update"
git pull
stow -R */
./scripts/health-check.sh
```

### Solución de Problemas Comunes

**`✗ nvim not found (REQUIRED)`**
- Instalar Neovim: `sudo apt install neovim` o `brew install neovim`

**`⚠ lazy.nvim not installed (will auto-install on first run)`**
- Normal en primera instalación
- Abrir Neovim una vez para auto-instalar

**`⚠ TPM not installed`**
- Ejecutar: `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`

**`⚠ Zsh is not default shell`**
- Ejecutar: `chsh -s $(which zsh)`
- Reiniciar sesión

**`⚠ Submodules not initialized`**
- Ejecutar: `git submodule update --init --recursive`

---

## snapshot.sh - Backups y Restauración

**Ubicación**: `scripts/snapshot.sh`
**Propósito**: Crear y gestionar backups (snapshots) de configuraciones

### Descripción

Sistema de snapshots que permite crear backups completos del entorno y restaurar desde snapshots previos. Útil para experimentar cambios sin riesgo.

### Características

- **Snapshots con etiquetas**: Organizar backups con nombres descriptivos
- **Archivos comprimidos**: Backups en formato `.tar.gz` eficiente
- **Metadata incluida**: Información de fecha, hostname, usuario, OS
- **Listado de snapshots**: Ver todos los backups disponibles
- **Rollback seguro**: Restauración con backup automático pre-rollback
- **Confirmación interactiva**: Previene restauraciones accidentales

### Comandos

| Comando | Descripción |
|---------|-------------|
| `create [LABEL]` | Crear snapshot con etiqueta opcional |
| `list` | Listar todos los snapshots disponibles |
| `rollback <SNAPSHOT>` | Restaurar desde snapshot |
| `help` | Mostrar ayuda |

### Uso

**Crear Snapshot:**
```bash
./scripts/snapshot.sh create "pre-update"
./scripts/snapshot.sh create "working-nvim-config"
./scripts/snapshot.sh create               # Label: "manual"
```

**Listar Snapshots:**
```bash
./scripts/snapshot.sh list
```

Salida:
```
▶ Available snapshots

No.   Snapshot                                     Size       Created
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1     dotfiles_pre-update_20260106_140022.tar.gz   2.3M       2026-01-06 14:00:22
2     dotfiles_manual_20260105_183044.tar.gz       2.2M       2026-01-05 18:30:44
3     dotfiles_working-nvim_20260104_092133.tar.gz 2.4M       2026-01-04 09:21:33
```

**Restaurar desde Snapshot:**
```bash
./scripts/snapshot.sh rollback dotfiles_pre-update_20260106_140022.tar.gz
```

### Directorios Incluidos en Snapshot

Los snapshots capturan las siguientes configuraciones:
- `~/.config/nvim` - Neovim
- `~/.config/tmux` - Tmux
- `~/.config/zsh` - Zsh
- `~/.config/yazi` - Yazi
- `~/.config/wezterm` - WezTerm
- `~/.zsh` - Plugins de Zsh
- `~/.tmux` - Plugins de Tmux

**Nota**: Los snapshots capturan el contenido real de los archivos (resuelve symlinks), no los enlaces simbólicos.

### Ubicación de Snapshots

Los snapshots se guardan en:
```
~/.dotfiles-snapshots/
```

Ejemplo:
```
~/.dotfiles-snapshots/
├── dotfiles_pre-update_20260106_140022.tar.gz
├── dotfiles_manual_20260105_183044.tar.gz
├── dotfiles_working-nvim_20260104_092133.tar.gz
└── dotfiles_pre-rollback_20260106_141530.tar.gz
```

### Formato de Nombre

```
dotfiles_<label>_<timestamp>.tar.gz
```

Componentes:
- `label`: Etiqueta descriptiva (ej: "pre-update", "working-nvim")
- `timestamp`: Fecha y hora en formato `YYYYMMDD_HHMMSS`

### Proceso de Rollback

Cuando ejecutas rollback, el script:

1. **Valida snapshot**: Verifica que el archivo existe
2. **Advertencia**: Muestra advertencia de sobrescritura
3. **Confirmación**: Pide confirmación explícita (y/N)
4. **Pre-rollback backup**: Crea snapshot automático del estado actual
5. **Extracción**: Descomprime snapshot a ubicación temporal
6. **Limpieza de symlinks**: Elimina enlaces simbólicos actuales
7. **Restauración**: Copia archivos desde snapshot
8. **Reporte**: Muestra cantidad de items restaurados

### Ejemplos de Uso

**Antes de Actualizar:**
```bash
# Crear snapshot antes de cambios
./scripts/snapshot.sh create "pre-update"

# Hacer cambios
git pull
stow -R */

# Si algo sale mal, restaurar
./scripts/snapshot.sh rollback dotfiles_pre-update_*.tar.gz
```

**Experimentar Configuración:**
```bash
# Crear snapshot "stable"
./scripts/snapshot.sh create "stable-config"

# Experimentar con Neovim
nvim  # hacer cambios...

# Si no funciona, restaurar
./scripts/snapshot.sh rollback dotfiles_stable-config_*.tar.gz
```

**Workflow de Desarrollo:**
```bash
# Snapshot antes de cambios grandes
./scripts/snapshot.sh create "before-refactor"

# Desarrollar...
nvim lua/plugins/new-plugin.lua

# Verificar
./scripts/health-check.sh

# Si falla, rollback
./scripts/snapshot.sh rollback dotfiles_before-refactor_*.tar.gz
```

### Contenido del Snapshot

Cada snapshot incluye un archivo `snapshot-info.txt` con metadata:

```
Dotfiles Snapshot
=================
Label: pre-update
Created: Mon Jan  6 14:00:22 UTC 2026
Hostname: my-laptop
User: usuario
OS: Linux

Contents:
.config/nvim/
.config/nvim/init.lua
.config/nvim/lua/
.config/tmux/
...
```

### Gestión de Snapshots

**Ver Detalles de Snapshot:**
```bash
tar -tzf ~/.dotfiles-snapshots/dotfiles_pre-update_*.tar.gz | head -20
```

**Extraer Archivo Específico:**
```bash
tar -xzf ~/.dotfiles-snapshots/dotfiles_pre-update_*.tar.gz \
  dotfiles-snapshot/.config/nvim/init.lua \
  --strip-components=1
```

**Limpiar Snapshots Antiguos:**
```bash
# Manual: eliminar snapshots específicos
rm ~/.dotfiles-snapshots/dotfiles_old-snapshot_*.tar.gz

# O limpiar snapshots más antiguos de 30 días
find ~/.dotfiles-snapshots -name "*.tar.gz" -mtime +30 -delete
```

### Tamaño Típico de Snapshots

- **Minimal** (solo configs): ~1-2 MB
- **Completo** (configs + plugins): ~2-4 MB
- **Con cache de Neovim**: ~5-10 MB

### Diferencias vs Backup de Bootstrap

| Aspecto | bootstrap.sh backup | snapshot.sh |
|---------|---------------------|-------------|
| **Cuándo** | Solo durante instalación inicial | En cualquier momento |
| **Formato** | Directorio sin comprimir | Archivo .tar.gz comprimido |
| **Metadata** | Ninguna | Incluye snapshot-info.txt |
| **Restauración** | Manual | Automática con script |
| **Uso** | Una vez | Múltiples veces |

---

## Workflows Recomendados

### Workflow 1: Instalación Limpia

```bash
# 1. Clonar dotfiles
git clone https://github.com/usuario/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Inicializar submodules
git submodule update --init --recursive

# 3. Bootstrap automático
./scripts/bootstrap.sh -y

# 4. Verificar instalación
./scripts/health-check.sh

# 5. Crear snapshot inicial
./scripts/snapshot.sh create "initial-setup"
```

### Workflow 2: Actualización Segura

```bash
# 1. Snapshot del estado actual
./scripts/snapshot.sh create "pre-update-$(date +%Y%m%d)"

# 2. Pull cambios
git pull origin main

# 3. Re-aplicar con Stow
stow -R */

# 4. Verificar salud
./scripts/health-check.sh

# 5. Si hay problemas, rollback
# ./scripts/snapshot.sh rollback dotfiles_pre-update_*.tar.gz
```

### Workflow 3: Experimentación

```bash
# 1. Crear snapshot "stable"
./scripts/snapshot.sh create "stable"

# 2. Experimentar con cambios
nvim ~/.config/nvim/lua/plugins/new-feature.lua

# 3. Probar cambios
nvim

# 4. Si funciona, crear snapshot "working"
./scripts/snapshot.sh create "working-new-feature"

# 5. Si no funciona, rollback
./scripts/snapshot.sh rollback dotfiles_stable_*.tar.gz
```

### Workflow 4: Desarrollo y Testing

```bash
# 1. Health check inicial
./scripts/health-check.sh

# 2. Snapshot antes de desarrollar
./scripts/snapshot.sh create "before-dev"

# 3. Desarrollar feature
# ... hacer cambios ...

# 4. Testing
./scripts/health-check.sh

# 5. Si pasa, snapshot del feature
./scripts/snapshot.sh create "feature-complete"

# 6. Si falla, rollback
./scripts/snapshot.sh rollback dotfiles_before-dev_*.tar.gz
```

---

## Troubleshooting de Scripts

### bootstrap.sh

**Error: "Command not found: stow"**
- Instalar Stow manualmente: `sudo apt install stow` o `brew install stow`

**Error: "Git submodule error"**
- Verificar conectividad a internet
- Ejecutar manualmente: `git submodule update --init --recursive`

### health-check.sh

**Error: "nvim: command not found"**
- Instalar Neovim: `sudo apt install neovim`

**Warning: "Submodules not initialized"**
- Ejecutar: `git submodule update --init --recursive`

### snapshot.sh

**Error: "No space left on device"**
- Limpiar snapshots antiguos: `rm ~/.dotfiles-snapshots/*.tar.gz`
- Verificar espacio: `df -h ~`

**Error: "Permission denied"**
- Verificar permisos: `ls -la ~/.dotfiles-snapshots/`
- Crear directorio: `mkdir -p ~/.dotfiles-snapshots`

---

## Variables de Entorno

Los scripts usan las siguientes variables:

| Variable | Descripción | Default |
|----------|-------------|---------|
| `DOTFILES_DIR` | Ubicación del repo | Auto-detectado |
| `BACKUP_DIR` | Directorio de backups bootstrap | `~/.dotfiles-backups/` |
| `SNAPSHOT_DIR` | Directorio de snapshots | `~/.dotfiles-snapshots/` |
| `HOME` | Directorio home del usuario | `$HOME` |

---

## Tips y Best Practices

1. **Crea snapshots antes de cambios importantes**
   - Antes de updates: `snapshot.sh create "pre-update"`
   - Antes de experimentar: `snapshot.sh create "stable"`

2. **Ejecuta health-check periódicamente**
   - Después de updates: `health-check.sh`
   - Antes de commits importantes: `health-check.sh`

3. **Usa labels descriptivos en snapshots**
   - ✅ Bien: `"pre-neovim-refactor"`, `"working-tmux-config"`
   - ❌ Mal: `"snapshot1"`, `"test"`

4. **Limpia snapshots antiguos regularmente**
   - Revisar mensualmente: `snapshot.sh list`
   - Eliminar obsoletos: `rm ~/.dotfiles-snapshots/old_*.tar.gz`

5. **Bootstrap en entornos nuevos**
   - Usa `-y` en scripts automatizados: `bootstrap.sh -y`
   - Guarda logs: `bootstrap.sh 2>&1 | tee bootstrap.log`

---

## Recursos Adicionales

- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/)
- [Dotfiles Best Practices](https://dotfiles.github.io/)
- [Bash Scripting Guide](https://www.gnu.org/software/bash/manual/)

---

**Última actualización**: 2026-01-06

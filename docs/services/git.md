# Git - Control de Versiones Optimizado

Configuración de Git con git-delta integrado, tema Catppuccin Mocha y herramientas de merge visual con Neovim.

## Características Principales

- **🎨 Git Delta**: Diff viewer mejorado con syntax highlighting
- **🌈 Catppuccin Mocha**: Tema púrpura/cyan en diffs
- **📊 Side-by-Side**: Comparación visual en columnas
- **🔧 Neovim Merge Tool**: nvimdiff para resolución de conflictos
- **⚡ Aliases Útiles**: Comandos cortos para operaciones comunes
- **🔄 Auto-Prune**: Limpieza automática de ramas remotas

## Git Delta - Diff Viewer Mejorado

Git Delta transforma los diffs estándar de Git en una experiencia visual mejorada con:

### Features
- **Syntax Highlighting**: Código coloreado en diffs
- **Side-by-Side**: Comparación en dos columnas
- **Line Numbers**: Números de línea en ambos lados
- **Hyperlinks**: URLs clickeables en la terminal
- **Catppuccin Theme**: Colores consistentes con resto del setup

### Ejemplo de Output

**Diff estándar vs Delta**:
```
# Diff estándar (aburrido)
-const name = 'old'
+const name = 'new'

# Delta (hermoso)
┊ 45│const name = 'old'     ┊ 45│const name = 'new'
     ^^^^^ removed              ^^^^^ added
```

### Colores Catppuccin Mocha en Delta

| Elemento | Color | Hex |
|----------|-------|-----|
| **Archivos modificados** | Peach (naranja) | `#fab387` |
| **Líneas eliminadas** | Fondo rojo oscuro | `#442d30` |
| **Líneas agregadas** | Fondo verde oscuro | `#2e3d32` |
| **Líneas modificadas (énfasis)** | Rojo/verde más intenso | `#6e3f44` / `#3e5a3e` |
| **Números de línea** | Overlay (gris) | `#6c7086` |
| **Headers de hunks** | Mauve (morado) | `#cba6f7` |

## Configuración Principal

### User & Editor
```toml
[user]
name = "Tu Nombre"
email = "tu@email.com"

[core]
editor = nvim
pager = delta
```

### Delta Configuration
```toml
[delta]
features = catppuccin-mocha
navigate = true              # Navegar entre diffs con n/N
side-by-side = true         # Modo columnas
line-numbers = true         # Mostrar números de línea
syntax-theme = Catppuccin-mocha
hyperlinks = true           # URLs clickeables
```

## Merge y Diff Tools

### nvimdiff - Merge Tool Visual

Git está configurado para usar **nvimdiff** como herramienta de resolución de conflictos:

```bash
git mergetool
# Abre Neovim con 3 paneles:
# ┌────────────┬────────────┬────────────┐
# │   LOCAL    │   BASE     │   REMOTE   │
# │  (tuyo)    │ (ancestro) │  (remoto)  │
# ├────────────┴────────────┴────────────┤
# │           MERGED (resultado)         │
# └──────────────────────────────────────┘
```

**Keybindings en nvimdiff**:
- `:diffget LOCAL` - Aceptar cambio local (izquierda)
- `:diffget REMOTE` - Aceptar cambio remoto (derecha)
- `]c` - Siguiente conflicto
- `[c` - Conflicto anterior
- `:wqa` - Guardar y salir de todos los buffers

### Diff Tool
```bash
git difftool file.js
# Abre Neovim con dos paneles lado a lado
```

## Aliases Esenciales

### Status & Info
```bash
git s           # Status corto con branch
git st          # Status completo
git last        # Último commit con stats
```

### Add & Commit
```bash
git a file.js   # Add archivo específico
git aa          # Add all
git ap          # Add patch (interactivo)
git cm "msg"    # Commit con mensaje
git ca          # Commit amend
git can         # Commit amend sin editar mensaje
```

### Branches
```bash
git b           # Listar branches locales
git ba          # Listar todas las branches (local + remote)
git bd branch   # Borrar branch (safe)
git bD branch   # Forzar borrado de branch
```

### Checkout
```bash
git co branch   # Cambiar a branch
git cob new     # Crear y cambiar a nueva branch
```

### Log & History
```bash
git l           # Log oneline con graph
git lg          # Log de todas las branches con graph
git lgg         # Log detallado con colores y autor
git tree        # Árbol visual completo del repositorio
```

### Diff
```bash
git d           # Diff de cambios no staged
git ds          # Diff de cambios staged
git dw          # Diff palabra por palabra
```

### Stash
```bash
git sl          # Listar stashes
git ss "msg"    # Guardar stash con mensaje
git sp          # Pop último stash
git sa          # Apply último stash (sin remover)
```

### Remote
```bash
git p           # Push
git pl          # Pull
git pf          # Push force-with-lease (más seguro)
git r           # Ver remotes
```

### Utilidades
```bash
git unstage file    # Quitar archivo de staging
git undo            # Deshacer último commit (soft reset)
git cleanup         # Borrar branches mergeadas
git contributors    # Ver contribuidores con conteo de commits
```

## Pull & Push Strategy

### Pull Configuration
```toml
[pull]
rebase = false      # Merge strategy (no rebase)
ff = only          # Solo fast-forward
```

**Estrategia de Pull**:
- Pull solo hace fast-forward por defecto
- Requiere rebase manual si hay divergencia
- Previene merge commits accidentales

### Push Configuration
```toml
[push]
default = current          # Push branch actual al mismo nombre en remote
followTags = true         # Push tags junto con commits
autoSetupRemote = true    # Auto-crear rama remota si no existe
```

**Flujo de Trabajo**:
```bash
# Primera vez pusheando nueva branch
git push
# Git automáticamente crea 'origin/feature-branch'

# Siguientes pushes
git push  # Detecta automáticamente el remote
```

## Fetch Configuration

```toml
[fetch]
prune = true           # Borrar referencias remotas eliminadas
pruneTagas = true      # Borrar tags remotos eliminados
```

**Auto-limpieza**:
- `git fetch` automáticamente limpia ramas remotas eliminadas
- Mantiene sincronización limpia con repositorio remoto

## Git Rerere (Reuse Recorded Resolution)

```toml
[rerere]
enabled = true
```

**Qué hace Rerere**:
- Recuerda cómo resolviste conflictos anteriores
- Si el mismo conflicto aparece de nuevo, lo resuelve automáticamente
- Útil en rebases repetidos o cherry-picks

## Colores

### Branch Colors
```bash
# Branch actual: amarillo inverso
# Branches locales: amarillo
# Branches remotas: verde
```

### Diff Colors
```bash
# Meta info: amarillo bold
# Headers: magenta bold
# Líneas removidas: rojo bold
# Líneas agregadas: verde bold
```

### Status Colors
```bash
# Archivos agregados: verde
# Archivos modificados: amarillo
# Archivos sin track: rojo
```

## Workflows Comunes

### Workflow 1: Feature Branch con Delta

```bash
# 1. Crear feature branch
git cob feature/nueva-funcionalidad

# 2. Hacer cambios
# ... editar archivos ...

# 3. Ver diferencias con Delta
git d  # Side-by-side diff hermoso

# 4. Agregar y commitear
git aa
git cm "feat: agregar nueva funcionalidad"

# 5. Push
git p  # Auto-configura remote
```

### Workflow 2: Resolver Conflictos con nvimdiff

```bash
# 1. Pull y detectar conflicto
git pl
# CONFLICT (content): Merge conflict in file.js

# 2. Abrir merge tool visual
git mergetool
# Neovim se abre con 3 paneles

# 3. Resolver conflictos en Neovim
# LOCAL ← tu versión
# REMOTE → versión remota
# MERGED ← resultado final

# 4. Guardar y salir
:wqa

# 5. Commit merge
git cm "merge: resolver conflictos en file.js"
```

### Workflow 3: Stash para Cambiar de Contexto

```bash
# 1. Trabajando en feature A
# ... cambios no commiteados ...

# 2. Necesitas cambiar a feature B urgente
git ss "WIP: feature A mitad"

# 3. Cambiar a otra branch
git co feature-b
# ... trabajar en feature B ...

# 4. Volver a feature A
git co feature-a
git sp  # Recuperar stash
```

### Workflow 4: Review con Tree View

```bash
# Ver historial visual completo
git tree

# Output:
# * 7a3f2e1 - (HEAD -> main) feat: add auth (2 hours ago) <Usuario>
# * b4d2c1a - fix: resolve merge conflict (3 hours ago) <Usuario>
# | * 9e5f3b2 - (feature/ui) feat: new UI component (1 day ago) <Usuario>
# |/
# * c8a1d4b - chore: update dependencies (2 days ago) <Usuario>
```

### Workflow 5: Clean Up Merged Branches

```bash
# Después de mergear varias features
git cleanup
# Borra automáticamente branches mergeadas (excepto main/master/develop)

# Antes:
# * main
#   feature/auth (merged)
#   feature/ui (merged)
#   feature/api (merged)

# Después:
# * main
```

## Comparación: Delta vs Git Diff Estándar

| Feature | Git Diff Estándar | Git Delta |
|---------|-------------------|-----------|
| Syntax Highlighting | ❌ | ✅ |
| Side-by-Side | ❌ | ✅ |
| Line Numbers | ❌ | ✅ |
| Color Themes | Básico | Catppuccin Mocha |
| Hyperlinks | ❌ | ✅ |
| Navigation | ❌ | ✅ (n/N) |
| Readability | Baja | Alta |

## Solución de Problemas

### Delta no muestra colores

```bash
# Verificar que delta esté instalado
which delta
# Debería mostrar: /usr/local/bin/delta

# Verificar que está configurado como pager
git config --get core.pager
# Debería mostrar: delta

# Reinstalar si es necesario
brew install git-delta  # macOS
cargo install git-delta # Desde fuente
```

### nvimdiff no abre en mergetool

```bash
# Verificar configuración
git config --get merge.tool
# Debería mostrar: nvimdiff

# Verificar que Neovim esté instalado
which nvim
# Debería mostrar path de Neovim

# Configurar manualmente si falta
git config --global merge.tool nvimdiff
```

### Delta no respeta side-by-side en terminal pequeña

```bash
# Delta automáticamente cambia a modo vertical si el ancho es <160 columnas
# Forzar side-by-side siempre:
git config --global delta.side-by-side true
git config --global delta.wrap-max-lines unlimited
```

### Rerere no está funcionando

```bash
# Habilitar rerere
git config --global rerere.enabled true

# Verificar que está activado
git config --get rerere.enabled
# Debería mostrar: true

# Ver resoluciones guardadas
ls .git/rr-cache/
```

### Aliases no funcionan

```bash
# Verificar que .gitconfig está siendo leído
git config --list --show-origin | grep alias

# Debería mostrar aliases desde ~/.gitconfig

# Recargar configuración
source ~/.zshrc
```

## Tips Pro

### 1. Navegación en Delta

```bash
# Dentro de un git diff con Delta:
n    # Siguiente cambio
N    # Cambio anterior
q    # Salir
```

### 2. Diff de Branch Completo

```bash
# Ver todos los cambios entre branches
git d main..feature-branch

# Ver solo archivos modificados
git d --name-only main..feature-branch
```

### 3. Log con Búsqueda

```bash
# Buscar commits por mensaje
git l --grep="feat"

# Buscar commits por autor
git l --author="Tu Nombre"

# Buscar commits por fecha
git l --since="2 weeks ago"
```

### 4. Stash Selectivo

```bash
# Stash solo archivos específicos
git stash push -m "WIP" file1.js file2.js

# Stash con untracked files
git stash -u
```

### 5. Cherry-pick con Delta

```bash
# Ver commit antes de cherry-pick
git show <commit-hash>  # Delta muestra diff hermoso

# Cherry-pick
git cherry-pick <commit-hash>
```

## Integración con Otras Herramientas

### LazyGit

LazyGit usa la configuración de Git automáticamente:
- Delta se activa en diffs dentro de LazyGit
- nvimdiff se usa para conflictos desde LazyGit
- Todos los aliases están disponibles

**Desde Neovim**:
```vim
<leader>gg    " Abrir LazyGit
```

### Tmux

Ver cambios de Git en pane de Tmux:
```bash
# En un pane
git tree

# En otro pane
nvim file.js
```

### Shell Aliases (Zsh)

Aliases adicionales desde `.zshrc`:
```bash
g       # git
gst     # git status
gco     # git checkout
gcm     # git commit -m
gpl     # git pull
gp      # git push
lg      # lazygit
```

## Recursos Adicionales

- [Git Delta Documentation](https://github.com/dandavison/delta)
- [Catppuccin for Delta](https://github.com/catppuccin/delta)
- [Neovim Diffview Plugin](https://github.com/sindrets/diffview.nvim)
- [Pro Git Book](https://git-scm.com/book/en/v2)

## Referencias

- [Git Delta GitHub](https://github.com/dandavison/delta)
- [Git Official Docs](https://git-scm.com/doc)
- [Neovim Diff Mode](https://neovim.io/doc/user/diff.html)

![Git](https://img.shields.io/badge/git-%23fab387?style=for-the-badge&logo=git&logoColor=white&color=1e1e2e)

# Git - Control de Versiones

Configuración de Git con git-delta como pager, tema Catppuccin Mocha en diffs, nvimdiff para resolución de conflictos y un conjunto completo de aliases para operaciones comunes.

## Ubicacion de archivo

El archivo de configuración principal es `~/.gitconfig`, gestionado con GNU Stow desde:

```
dotfiles/git/.gitconfig  →  ~/.gitconfig
```

Para aplicar:

```bash
cd ~/dotfiles
stow git
```

---

## Git Delta - Diff Viewer

Git Delta reemplaza el pager estándar de Git con syntax highlighting, números de línea y vista en columnas.

### Configuracion

```toml
[core]
    pager = delta

[interactive]
    diffFilter = delta --color-only

[add.interactive]
    useBuiltin = false

[delta]
    features        = catppuccin-mocha
    navigate        = true
    light           = false
    side-by-side    = true
    line-numbers    = true
    syntax-theme    = Catppuccin-mocha
    hyperlinks      = true
    max-line-length = 512

    # Encabezados de archivo
    file-style            = bold "#fab387"
    file-decoration-style = "#fab387" ul

    # Formato de numeros de linea
    line-numbers-left-format  = "{nm:>4}┊"
    line-numbers-right-format = "{np:>4}│"
    line-numbers-left-style   = "#6c7086"
    line-numbers-right-style  = "#6c7086"

    # Encabezados de hunk
    hunk-header-style            = file line-number syntax
    hunk-header-decoration-style = "#cba6f7" box
```

### Descripcion de opciones Delta

| Opcion | Valor | Descripcion |
|--------|-------|-------------|
| `features` | `catppuccin-mocha` | Activa el bloque de colores `[delta "catppuccin-mocha"]` |
| `navigate` | `true` | Navegar entre hunks con `n` / `N` dentro del pager |
| `side-by-side` | `true` | Muestra el diff en dos columnas (antes / despues) |
| `line-numbers` | `true` | Numeros de linea en ambas columnas |
| `syntax-theme` | `Catppuccin-mocha` | Tema de syntax highlighting |
| `hyperlinks` | `true` | Convierte rutas de archivo en URLs clickeables en terminales compatibles |
| `max-line-length` | `512` | Longitud maxima antes de truncar (evita wrapping excesivo en side-by-side) |
| `hunk-header-style` | `file line-number syntax` | Muestra archivo, numero de linea y codigo en el encabezado del hunk |
| `hunk-header-decoration-style` | `"#cba6f7" box` | Encuadra el encabezado del hunk con el color Mauve |

### Paleta Catppuccin Mocha en diffs

El bloque `[delta "catppuccin-mocha"]` define los colores para lineas eliminadas y agregadas:

| Elemento | Color | Hex |
|----------|-------|-----|
| Archivos modificados (header) | Peach | `#fab387` |
| Lineas eliminadas | Fondo rojo oscuro | `#442d30` |
| Lineas eliminadas (enfasis intra-linea) | Rojo mas intenso | `#6e3f44` |
| Lineas agregadas | Fondo verde oscuro | `#2e3d32` |
| Lineas agregadas (enfasis intra-linea) | Verde mas intenso | `#3e5a3e` |
| Numeros de linea | Overlay (gris) | `#6c7086` |
| Encabezados de hunk | Mauve | `#cba6f7` |

La propiedad `map-styles` mapea los colores de merge de Git a la paleta Catppuccin:

```toml
map-styles = "bold purple => syntax #cba6f7, bold cyan => syntax #89dceb"
```

### Ejemplo visual

```
# Git diff estandar
-const name = 'old'
+const name = 'new'

# Git Delta (side-by-side con numeros de linea)
  45┊const name = 'old'     45│const name = 'new'
```

### Instalacion de Delta

```bash
# macOS
brew install git-delta

# Cargo (Rust)
cargo install git-delta
```

---

## Merge y Diff Tool - nvimdiff

Git usa Neovim en modo diff para resolución visual de conflictos y comparacion entre archivos.

### Configuracion

```toml
[merge]
    tool          = nvimdiff
    conflictstyle = diff3

[mergetool]
    prompt     = false
    keepBackup = false

[mergetool "nvimdiff"]
    cmd = nvim -d $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'

[diff]
    tool       = nvimdiff
    colorMoved = default

[difftool]
    prompt = false

[difftool "nvimdiff"]
    cmd = nvim -d $LOCAL $REMOTE
```

### Descripcion de opciones

| Opcion | Valor | Descripcion |
|--------|-------|-------------|
| `merge.conflictstyle` | `diff3` | Muestra el ancestro comun ademas de LOCAL y REMOTE en el marcador de conflicto |
| `mergetool.keepBackup` | `false` | No genera archivos `.orig` despues de resolver conflictos |
| `mergetool.prompt` | `false` | Abre la herramienta sin pedir confirmacion por cada archivo |
| `diff.colorMoved` | `default` | Destaca bloques de codigo movidos con un color distinto al de lineas agregadas/eliminadas |

### Layout de mergetool

```
git mergetool
# Abre Neovim con:
# ┌────────────┬────────────┐
# │   LOCAL    │   REMOTE   │
# │  (tuyo)    │  (remoto)  │
# ├────────────┴────────────┤
# │    MERGED (resultado)   │
# └─────────────────────────┘
```

La opcion `conflictstyle = diff3` agrega el bloque BASE (ancestro comun) dentro del marcador de conflicto, lo que permite entender mejor la intencion original de ambas versiones.

### Keybindings en nvimdiff

| Comando | Accion |
|---------|--------|
| `]c` | Siguiente conflicto |
| `[c` | Conflicto anterior |
| `:diffget LOCAL` | Aceptar version local (izquierda) |
| `:diffget REMOTE` | Aceptar version remota (derecha) |
| `:diffupdate` | Refrescar marcadores de diff |
| `:wqa` | Guardar y salir de todos los buffers |

### Uso de difftool

```bash
# Comparar archivo con la version en staging
git difftool archivo.js

# Comparar con otra branch
git difftool main..feature-branch -- archivo.js
```

---

## Aliases

Todos los aliases estan definidos en el bloque `[alias]` del `.gitconfig`.

### Status e informacion

| Alias | Comando completo | Descripcion |
|-------|-----------------|-------------|
| `git s` | `git status -sb` | Status corto con nombre de branch |
| `git st` | `git status` | Status completo |
| `git last` | `git log -1 HEAD --stat` | Ultimo commit con resumen de archivos cambiados |

### Add y staging

| Alias | Comando completo | Descripcion |
|-------|-----------------|-------------|
| `git a` | `git add` | Agregar archivo(s) especificos |
| `git aa` | `git add --all` | Agregar todos los cambios |
| `git ap` | `git add --patch` | Staging interactivo por hunk |

### Commit

| Alias | Comando completo | Descripcion |
|-------|-----------------|-------------|
| `git c` | `git commit` | Commit abriendo editor |
| `git cm` | `git commit -m` | Commit con mensaje en linea |
| `git ca` | `git commit --amend` | Modificar ultimo commit (abre editor) |
| `git can` | `git commit --amend --no-edit` | Modificar ultimo commit sin cambiar el mensaje |

### Branch

| Alias | Comando completo | Descripcion |
|-------|-----------------|-------------|
| `git b` | `git branch` | Listar branches locales |
| `git ba` | `git branch -a` | Listar branches locales y remotas |
| `git bd` | `git branch -d` | Eliminar branch (solo si esta mergeada) |
| `git bD` | `git branch -D` | Forzar eliminacion de branch |
| `git branches` | `git branch -a` | Alias largo equivalente a `git ba` |

### Checkout

| Alias | Comando completo | Descripcion |
|-------|-----------------|-------------|
| `git co` | `git checkout` | Cambiar de branch o restaurar archivo |
| `git cob` | `git checkout -b` | Crear y cambiar a nueva branch |

### Log e historial

| Alias | Comando completo | Descripcion |
|-------|-----------------|-------------|
| `git l` | `git log --oneline --graph --decorate` | Log compacto con grafo de la branch actual |
| `git lg` | `git log --oneline --graph --decorate --all` | Log compacto con grafo de todas las branches |
| `git lgg` | `git log --graph --pretty=format:'...' --abbrev-commit` | Log detallado con colores, autor y fecha relativa |
| `git tree` | igual que `lgg` con `--all` | Vista de arbol completa del repositorio |

### Diff

| Alias | Comando completo | Descripcion |
|-------|-----------------|-------------|
| `git d` | `git diff` | Cambios no staged (usa Delta automaticamente) |
| `git ds` | `git diff --staged` | Cambios en staging area |
| `git dw` | `git diff --word-diff` | Diff a nivel de palabra |

### Stash

| Alias | Comando completo | Descripcion |
|-------|-----------------|-------------|
| `git sl` | `git stash list` | Ver lista de stashes |
| `git ss` | `git stash save` | Guardar stash con mensaje |
| `git sp` | `git stash pop` | Aplicar y eliminar el ultimo stash |
| `git sa` | `git stash apply` | Aplicar el ultimo stash sin eliminarlo |

### Reset

| Alias | Comando completo | Descripcion |
|-------|-----------------|-------------|
| `git unstage` | `git reset HEAD --` | Quitar archivo(s) del staging area |
| `git undo` | `git reset --soft HEAD^` | Deshacer el ultimo commit (conserva cambios en staging) |

### Push, pull y remote

| Alias | Comando completo | Descripcion |
|-------|-----------------|-------------|
| `git p` | `git push` | Push a la rama remota configurada |
| `git pl` | `git pull` | Pull desde la rama remota |
| `git pf` | `git push --force-with-lease` | Push forzado seguro (falla si el remoto tiene commits nuevos) |
| `git r` | `git remote -v` | Ver lista de remotes con sus URLs |
| `git remotes` | `git remote -v` | Alias largo equivalente a `git r` |

### Tags y utilidades

| Alias | Comando completo | Descripcion |
|-------|-----------------|-------------|
| `git tags` | `git tag -l` | Listar todos los tags |
| `git contributors` | `git shortlog -sn` | Ver contribuidores ordenados por numero de commits |
| `git cleanup` | `!git branch --merged \| grep -v ...` | Eliminar branches locales ya mergeadas (excluye main, master, develop) |

---

## Configuracion de Pull y Push

### Pull

```toml
[pull]
    rebase = false
    ff     = only
```

| Opcion | Valor | Efecto |
|--------|-------|--------|
| `rebase` | `false` | El pull usa merge, no rebase |
| `ff` | `only` | El pull solo procede si es fast-forward; rechaza si hay divergencia |

Con `ff = only`, si tu branch y la rama remota divergieron, Git devuelve un error en lugar de crear un merge commit automatico. Esto fuerza a resolver la divergencia explicitamente con rebase o merge manual.

### Push

```toml
[push]
    default         = current
    followTags      = true
    autoSetupRemote = true
```

| Opcion | Valor | Efecto |
|--------|-------|--------|
| `default` | `current` | Push la branch actual al remote con el mismo nombre |
| `followTags` | `true` | Incluye tags anotados al hacer push |
| `autoSetupRemote` | `true` | Crea la rama remota automaticamente si no existe (elimina necesidad de `--set-upstream`) |

### Fetch

```toml
[fetch]
    prune     = true
    pruneTags = true
```

| Opcion | Valor | Efecto |
|--------|-------|--------|
| `prune` | `true` | Elimina referencias locales a ramas remotas que ya no existen |
| `pruneTags` | `true` | Elimina referencias locales a tags remotos que ya no existen |

---

## Optimizaciones

### Rerere (Reuse Recorded Resolution)

```toml
[rerere]
    enabled = true
```

Rerere guarda la resolucion de cada conflicto de merge. Si el mismo conflicto aparece de nuevo (por ejemplo, en rebases repetidos o cherry-picks), Git lo resuelve automaticamente usando la resolucion guardada.

```bash
# Ver resoluciones guardadas
ls .git/rr-cache/

# Borrar todas las resoluciones (reiniciar rerere)
git rerere forget
```

### Compresion

```toml
[core]
    compression = 9
```

Nivel de compresion zlib para objetos de Git (escala 0-9). El valor `9` maximiza la compresion a costa de mayor uso de CPU. Util en repositorios grandes con historial extenso.

### Protocolo version 2

```toml
[protocol]
    version = 2
```

Git Protocol v2 reduce la cantidad de datos transferidos en `git fetch` al permitir que el servidor filtre referencias antes de enviarlas al cliente. Mejora la velocidad en repositorios con muchas referencias (branches, tags).

### Autocorrect

```toml
[help]
    autocorrect = 1
```

Si escribes un comando con typo, Git lo corrige automaticamente despues de `1` decimo de segundo (100ms). Por ejemplo, `git stauts` ejecuta `git status` automaticamente.

---

## Colores del terminal

Los colores del terminal (distintos a los colores de Delta) aplican cuando Delta no esta activo o para elementos de la UI de Git.

### Branch

```toml
[color "branch"]
    current = yellow reverse
    local   = yellow
    remote  = green
```

### Diff

```toml
[color "diff"]
    meta = yellow bold
    frag = magenta bold
    old  = red bold
    new  = green bold
```

### Status

```toml
[color "status"]
    added     = green
    changed   = yellow
    untracked = red
```

---

## Configuracion de usuario y repositorio

```toml
[user]
    name  = Jonatan Tlilayatzi Cruz
    email = tlilayatzi.jonatan@outlook.com

[init]
    defaultBranch = main

[core]
    editor   = nvim
    filemode = false

[credential]
    helper = osxkeychain
```

| Opcion | Valor | Descripcion |
|--------|-------|-------------|
| `init.defaultBranch` | `main` | Nombre de branch inicial en `git init` |
| `core.filemode` | `false` | Ignora cambios en permisos de archivo (util en entornos con distintos sistemas de archivos) |
| `credential.helper` | `osxkeychain` | Usa el keychain de macOS para guardar credenciales de HTTPS |

---

## Workflows comunes

### Feature branch con Delta

```bash
# 1. Crear branch
git cob feature/nueva-funcionalidad

# 2. Ver cambios antes de agregar
git d  # side-by-side con syntax highlighting

# 3. Staging interactivo
git ap  # Seleccionar hunks especificos

# 4. Commit
git cm "feat: agregar nueva funcionalidad"

# 5. Push (crea la rama remota automaticamente)
git p
```

### Resolver conflictos con nvimdiff

```bash
# 1. Pull con conflicto
git pl
# CONFLICT (content): Merge conflict in archivo.js

# 2. Abrir merge tool
git mergetool
# Neovim abre con LOCAL / REMOTE arriba y MERGED abajo

# 3. Navegar entre conflictos
# ]c  →  siguiente conflicto
# [c  →  conflicto anterior

# 4. Resolver y guardar
:wqa

# 5. Commit merge
git cm "merge: resolver conflictos en archivo.js"
```

### Stash para cambio de contexto

```bash
# Guardar trabajo en progreso
git ss "WIP: feature A mitad"

# Cambiar de branch
git co feature-b

# Recuperar trabajo
git co feature-a
git sp
```

### Limpieza despues de merge

```bash
# Eliminar branches mergeadas localmente
git cleanup

# Sincronizar referencias remotas eliminadas
git fetch
# (prune y pruneTags se ejecutan automaticamente)
```

### Historial visual

```bash
# Ver arbol de commits con grafo
git tree

# Ejemplo de output:
# * 7a3f2e1 - (HEAD -> main) feat: add auth (2 hours ago) <Jonatan>
# * b4d2c1a - fix: resolve conflict (3 hours ago) <Jonatan>
# | * 9e5f3b2 - (feature/ui) feat: new component (1 day ago) <Jonatan>
# |/
# * c8a1d4b - chore: update deps (2 days ago) <Jonatan>
```

---

## Solucion de problemas

### Delta no muestra colores

```bash
# Verificar instalacion
which delta

# Verificar que esta configurado como pager
git config --get core.pager
# Esperado: delta

# Instalar si falta
brew install git-delta
```

### Delta no respeta side-by-side

Delta cambia a vista vertical automaticamente si el ancho de terminal es menor a 160 columnas. Para forzar siempre el modo columnas:

```bash
git config --global delta.side-by-side true
```

### nvimdiff no abre en mergetool

```bash
# Verificar configuracion
git config --get merge.tool
# Esperado: nvimdiff

# Verificar que Neovim esta instalado
which nvim

# Configurar manualmente
git config --global merge.tool nvimdiff
```

### Rerere no resuelve conflictos automaticamente

```bash
# Verificar que esta habilitado
git config --get rerere.enabled
# Esperado: true

# Ver resoluciones en cache
ls .git/rr-cache/

# Habilitar si esta desactivado
git config --global rerere.enabled true
```

### Pull rechazado con ff = only

```bash
# Error: fatal: Not possible to fast-forward, aborting.
# Solucion 1: rebase local sobre el remoto
git pull --rebase

# Solucion 2: merge explicito
git fetch
git merge origin/main
```

### Aliases no disponibles

```bash
# Verificar que .gitconfig esta siendo leido
git config --list --show-origin | grep alias

# Verificar symlink de Stow
ls -la ~/.gitconfig
# Esperado: ~/.gitconfig -> ~/dotfiles/git/.gitconfig
```

---

## Comparativa Delta vs diff estandar

| Caracteristica | Git diff | Git Delta |
|----------------|----------|-----------|
| Syntax highlighting | No | Si |
| Vista side-by-side | No | Si |
| Numeros de linea | No | Si |
| Tema de colores | Basico ANSI | Catppuccin Mocha |
| Hyperlinks | No | Si |
| Navegacion (n/N) | No | Si |
| Encabezado de hunk | Solo `@@` | Archivo + linea + codigo |
| Diff intra-linea | No | Si (enfasis) |

---

## Recursos

- [Git Delta - GitHub](https://github.com/dandavison/delta)
- [Catppuccin para Delta](https://github.com/catppuccin/delta)
- [Pro Git Book](https://git-scm.com/book/en/v2)
- [Neovim Diff Mode](https://neovim.io/doc/user/diff.html)
- [Git Protocol v2](https://git-scm.com/docs/protocol-v2)

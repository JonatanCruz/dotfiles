# Configuración de Zsh

Configuración modular de Zsh organizada en archivos por categoría para mejor mantenibilidad y escalabilidad.

## Estructura del Proyecto

```
zsh/
├── .zshrc                        # Punto de entrada (40 líneas)
├── .zshrc.backup                 # Backup del archivo monolítico original
└── .config/zsh/
    ├── config/                   # Configuración base
    │   ├── environment.zsh       # Variables de entorno, PATH, NVM, pyenv
    │   ├── history.zsh           # Configuración del historial
    │   ├── options.zsh           # Opciones de la shell (setopt)
    │   ├── completion.zsh        # Sistema de autocompletado
    │   └── keybindings.zsh       # Atajos de teclado
    │
    ├── aliases/                  # Aliases organizados por categoría
    │   ├── tools.zsh             # eza, bat, btop, tldr, fd, ripgrep
    │   ├── tmux.zsh              # Gestión de tmux
    │   ├── git.zsh               # Git y GitHub CLI
    │   ├── navigation.zsh        # cd, zoxide, operaciones de archivos
    │   ├── editor.zsh            # Neovim y edición de configuración
    │   └── utils.zsh             # Utilidades varias
    │
    └── plugins.zsh               # Carga de plugins y herramientas
```

## Características

- **Modular**: Cada categoría en su propio archivo
- **Escalable**: Fácil agregar nuevos aliases o configuraciones
- **Documentado**: Comentarios claros en cada archivo
- **Limpio**: .zshrc de solo ~40 líneas vs ~220 original
- **Organizado**: Estructura lógica por funcionalidad
- **Modo Vi**: Edición de línea de comandos estilo Vim
- **Historial**: 10,000 comandos persistentes compartidos entre sesiones
- **Autocompletado**: Menú interactivo con colores
- **Plugins**: Autosuggestions, syntax highlighting, substring search

## Instalación

### 1. Aplicar con Stow

```bash
cd ~/dotfiles
stow -R zsh
```

### 2. Cambiar Shell a Zsh (si no está configurado)

```bash
chsh -s $(which zsh)
```

Cierra sesión y vuelve a entrar.

### 3. Instalar Dependencias

**Herramientas CLI modernas:**
```bash
# Homebrew (macOS)
brew install eza bat fd ripgrep fzf btop tldr yazi

# Ubuntu/Debian
sudo apt install eza bat fd-find ripgrep fzf
```

**Zoxide (navegación inteligente):**
```bash
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
```

**NVM (Node Version Manager):**
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```

**Starship (prompt):**
```bash
brew install starship
# o
curl -sS https://starship.rs/install.sh | sh
```

## Aliases Principales

### Navegación de Archivos (eza)

```bash
ls          # Listar archivos con iconos
l           # Lista detallada
la          # Lista detallada con archivos ocultos
ll          # Lista con estado de Git
lt          # Vista de árbol (2 niveles)
llt         # Vista de árbol (3 niveles)
```

### Git

```bash
g           # git
lg          # lazygit

# Estados
gs          # git status (corto)
gst         # git status (completo)

# Staging
ga          # git add
gaa         # git add -A

# Commits
gc          # git commit -m
gca         # git commit -am

# Sincronización
gp          # git push
gpl         # git pull

# Ramas
gco         # git checkout
gcb         # git checkout -b (crear rama)
gb          # git branch

# Historial
gl          # git log (formato gráfico)

# GitHub CLI
ghpr        # gh pr create
ghprl       # gh pr list
ghprv       # gh pr view
ghis        # gh issue list
ghrc        # gh repo clone
ghrv        # gh repo view --web
```

### Tmux

```bash
tn <nombre>  # Crear sesión nueva
ta <nombre>  # Adjuntar a sesión
tl           # Listar sesiones
tk <nombre>  # Matar sesión
tks          # Matar todas las sesiones
```

### Navegación de Directorios

```bash
..          # cd ..
...         # cd ../..
....        # cd ../../..
~           # cd ~

# Zoxide (cd inteligente)
z <carpeta> # Saltar a carpeta frecuente
za / zi     # Búsqueda interactiva
zq          # Ver base de datos de carpetas
zrm         # Eliminar carpeta de base de datos
```

### Edición

```bash
v           # nvim
vim         # nvim
sv          # sudo nvim

# Configuraciones
zshrc       # Editar ~/.zshrc
tmuxconf    # Editar ~/.tmux.conf
nvimconf    # Abrir config de Neovim
```

### Utilidades

```bash
cat         # bat (syntax highlighting)
ff          # fd (buscar archivos, incluye ocultos)
rg          # ripgrep (case-insensitive)
yz          # yazi (file manager)
top         # btop (monitor de sistema)
help        # tldr (ayuda rápida)

c           # clear
e           # exit
t           # touch

ducks       # Mostrar carpetas más pesadas
myip        # Obtener IP pública
```

## Agregar Nuevos Aliases

### En Categoría Existente

1. Edita el archivo apropiado:
   ```bash
   nvim ~/.config/zsh/aliases/git.zsh
   ```

2. Agrega tu alias:
   ```bash
   alias gundo='git reset --soft HEAD~1'  # Deshacer último commit
   ```

3. Recarga:
   ```bash
   source ~/.zshrc
   ```

### Nueva Categoría

Ejemplo con Docker (ya configurado en este repositorio):

1. Crea nuevo archivo:
   ```bash
   nvim ~/.config/zsh/aliases/nueva-categoria.zsh
   ```

2. Agrega aliases:
   ```bash
   # Aliases de la nueva categoría
   alias ejemplo='comando'
   ```

3. Carga en `.zshrc`:
   ```bash
   source "${ZDOTDIR}/aliases/nueva-categoria.zsh"
   ```

### Categoría Docker (Incluida)

Este repositorio ya incluye aliases completos de Docker en:
- `aliases/docker.zsh` - Aliases y funciones útiles para Docker y Docker Compose

Para ver todos los aliases disponibles:
```bash
cat ~/.config/zsh/aliases/docker.zsh
```

El autocompletado de Docker se instala con el paquete `docker` de Stow. Ver `docker/README.md` para más información.

## Modificar Configuración Base

Los archivos de configuración están en `~/.config/zsh/config/`:

- **environment.zsh**: Variables de entorno, PATH, version managers
- **history.zsh**: Tamaño y comportamiento del historial
- **options.zsh**: Opciones de la shell (setopt)
- **completion.zsh**: Sistema de autocompletado
- **keybindings.zsh**: Atajos de teclado

Ejemplo - cambiar tamaño del historial:

```bash
nvim ~/.config/zsh/config/history.zsh
# Cambia HISTSIZE y SAVEHIST
source ~/.zshrc
```

## Características Avanzadas

### Historial Inteligente

- Compartido entre sesiones
- Ignora duplicados
- Ignora comandos que empiezan con espacio
- Búsqueda con `↑/↓` filtrando por lo que escribiste

### Modo Vi

- `ESC` - Modo normal
- `i` - Modo inserción
- `hjkl` - Navegación en modo normal
- `/` - Buscar en historial

Para cambiar a modo Emacs:
```bash
nvim ~/.config/zsh/config/keybindings.zsh
# Cambia 'bindkey -v' por 'bindkey -e'
```

### Autocompletado Mejorado

- **Tab** - Mostrar sugerencias
- **Tab Tab** - Navegar menú interactivo
- Colores para distinguir tipos de archivos
- Descripciones de comandos

### Plugins

- **zsh-autosuggestions**: Sugiere comandos basados en historial
  - `→` para aceptar sugerencia completa
  - `Ctrl+→` para aceptar palabra por palabra

- **zsh-you-should-use**: Te recuerda cuando usas comandos que tienen aliases
  - Ejemplo: `git status` → "You should use: gs"
  - Ayuda a aprender y usar tus aliases más eficientemente

- **zsh-completions**: Autocompletados adicionales para 250+ comandos
  - Mejora el autocompletado de docker, npm, yarn, cargo, pip, etc.
  - Se integra automáticamente con Tab

- **zsh-syntax-highlighting**: Resalta comandos mientras escribes
  - Verde: comando válido
  - Rojo: comando inválido
  - Azul: path existente

- **zsh-history-substring-search**: Busca en historial con `↑/↓`

### Integración FZF

```bash
Ctrl+R    # Buscar en historial
Ctrl+T    # Buscar archivos
Alt+C     # Cambiar directorio
```

### Zoxide

Aprende los directorios que más usas:
```bash
z dotfiles     # Salta a ~/dotfiles
z conf nv      # Salta a ~/.config/nvim (fuzzy)
```

## Comparación con Configuración Anterior

| Aspecto | Anterior | Actual |
|---------|----------|--------|
| Archivos | 1 monolítico | 13 modulares |
| Líneas .zshrc | 220 | 40 |
| Organización | Secciones | Archivos por categoría |
| Mantenibilidad | Media | Alta |
| Escalabilidad | Limitada | Excelente |
| Documentación | Comentarios inline | README + headers |

## Restaurar Configuración Anterior

Si necesitas volver a la configuración monolítica:

```bash
mv ~/.zshrc ~/.zshrc.modular
mv ~/.zshrc.backup ~/.zshrc
source ~/.zshrc
```

## Solución de Problemas

### Los aliases no funcionan

```bash
# Verifica que .zshrc está siendo cargado
echo $SHELL
# Debería mostrar: /usr/bin/zsh o similar

# Recarga la configuración
source ~/.zshrc
```

### Autocompletado no funciona

```bash
# Limpia la caché
rm ~/.zcompdump*
exec zsh
```

### Plugins no se cargan

```bash
# Verifica que estén instalados
ls ~/.zsh/
# Deberías ver:
# zsh-autosuggestions/
# zsh-syntax-highlighting/
# zsh-history-substring-search/

# Si faltan:
cd ~/dotfiles
stow zsh-plugins
```

### Error al cargar módulos

```bash
# Verifica que ZDOTDIR esté configurado
echo $ZDOTDIR
# Debería mostrar: /Users/tu-usuario/.config/zsh

# Verifica que los archivos existan
ls -la ~/.config/zsh/
```

## Performance

La configuración está optimizada para carga rápida:
- Caché de autocompletado con check de 24 horas
- Plugins cargados al final
- Starship inicializado al último
- Compinit con opción `-i` para evitar checks

## Recursos

- [Zsh Documentation](https://zsh.sourceforge.io/Doc/)
- [Starship](https://starship.rs/)
- [eza](https://github.com/eza-community/eza)
- [bat](https://github.com/sharkdp/bat)
- [fzf](https://github.com/junegunn/fzf)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [fd](https://github.com/sharkdp/fd)

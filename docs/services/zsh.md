# Zsh - Shell Modular y Personalizada

Configuración modular de Zsh con 5 módulos de configuración, 8 categorías de aliases, modo Vi, historial inteligente y 4 plugins esenciales.

## Características Principales

- **📂 Modular**: 5 archivos de configuración separados por función
- **🎯 Aliases Organizados**: 8 categorías (tools, git, tmux, gcloud, gh, docker, navigation, editor)
- **⌨️ Modo Vi**: Edición de línea de comandos estilo Vim
- **📝 Historial Inteligente**: 10,000 comandos persistentes compartidos
- **🎨 Autocompletado**: Menú interactivo con colores
- **🔌 4 Plugins**: Autosuggestions, syntax highlighting, substring search, you-should-use
- **⚡ Starship Prompt**: Prompt moderno con información de Git, Node, etc.
- **🧭 Integración**: FZF, Zoxide, NVM, Pyenv

## Estructura Modular

```
zsh/
├── .zshrc                      # Punto de entrada (40 líneas)
└── .config/zsh/
    ├── config/                 # Configuración base
    │   ├── environment.zsh     # PATH, NVM, pyenv
    │   ├── history.zsh         # Historial
    │   ├── options.zsh         # setopt
    │   ├── completion.zsh      # Autocompletado
    │   └── keybindings.zsh     # Modo Vi + atajos
    │
    ├── aliases/                # 8 categorías
    │   ├── tools.zsh           # eza, bat, btop, fd, ripgrep
    │   ├── git.zsh             # Git y LazyGit
    │   ├── tmux.zsh            # Gestión de tmux
    │   ├── gh.zsh              # GitHub CLI
    │   ├── gcloud.zsh          # Google Cloud CLI
    │   ├── docker.zsh          # Docker y Docker Compose
    │   ├── navigation.zsh      # cd, zoxide
    │   ├── editor.zsh          # Neovim
    │   └── utils.zsh           # Utilidades
    │
    └── plugins.zsh             # Carga de plugins
```

## Aliases Principales

### Navegación de Archivos (eza)

```bash
ls          # Listar con iconos
l           # Lista detallada
la          # Lista detallada con ocultos
ll          # Lista con estado de Git
lt          # Vista de árbol (2 niveles)
llt         # Vista de árbol (3 niveles)
```

### Git

```bash
g           # git
lg          # lazygit

# Estados
gs / gst    # git status

# Staging
ga / gaa    # git add / git add -A

# Commits
gc          # git commit -m
gca         # git commit -am

# Sincronización
gp / gpl    # git push / git pull

# Ramas
gco / gcb   # checkout / crear rama
gb          # listar ramas

# Historial
gl          # git log (gráfico)
```

### GitHub CLI (gh)

```bash
# Autenticación
ghauth      # gh auth login

# Repositorios
ghv         # Ver repo actual
ghvw        # Abrir repo en web
ghclone     # Clonar repo rápido

# Pull Requests
ghpr        # Listar PRs
ghprc       # Crear PR
ghprv       # Ver PR
ghprm       # Mergear PR

# Issues
ghis        # Listar issues
ghic        # Crear issue
ghiv        # Ver issue

# Workflows
ghw         # Listar workflows
ghr         # Listar runs
ghrw        # Ver run en vivo
```

### Google Cloud (gcloud)

```bash
# Configuración
g           # gcloud
gauth       # gcloud auth login
gproject    # Cambiar proyecto

# Compute Engine
gvmlist     # Listar VMs
gssh        # SSH a VM

# Kubernetes (GKE)
gkelist     # Listar clusters
gkecreds    # Obtener credenciales

# Cloud Run
grunlist    # Listar servicios
grundeploy  # Desplegar servicio

# Cloud Storage
gls         # Listar buckets/archivos
gcp         # Copiar archivos
```

### Tmux

```bash
tn <nombre> # Nueva sesión
ta <nombre> # Adjuntar a sesión
tl          # Listar sesiones
tk <nombre> # Matar sesión
tks         # Matar todas las sesiones
```

### Navegación de Directorios

```bash
..          # cd ..
...         # cd ../..
....        # cd ../../..

# Zoxide (cd inteligente)
z <carpeta> # Saltar a carpeta frecuente
zi / za     # Búsqueda interactiva
zq          # Ver base de datos
```

### Herramientas Modernas

```bash
cat         # bat (syntax highlighting)
ff          # fd (buscar archivos, incluye ocultos)
rg          # ripgrep (case-insensitive)
yz          # yazi (file manager)
top         # btop (monitor de sistema)
help        # tldr (ayuda rápida)
```

### Editor

```bash
v / vim     # nvim
sv          # sudo nvim

# Configuraciones
zshrc       # Editar ~/.zshrc
tmuxconf    # Editar ~/.tmux.conf
nvimconf    # Abrir config de Neovim
```

## Plugins

### zsh-autosuggestions
- Sugiere comandos basados en historial
- `→` para aceptar sugerencia completa
- `Ctrl+→` para aceptar palabra por palabra

### zsh-syntax-highlighting
- Resalta comandos mientras escribes
- Verde: comando válido
- Rojo: comando inválido
- Azul: path existente

### zsh-history-substring-search
- Busca en historial con `↑/↓`
- Filtra por lo que escribiste

### zsh-you-should-use
- Te recuerda cuando usas comandos que tienen aliases
- Ejemplo: `git status` → "You should use: gs"
- Ayuda a aprender aliases más eficientemente

## Modo Vi

- `ESC` - Modo normal
- `i` - Modo inserción
- `hjkl` - Navegación en modo normal
- `/` - Buscar en historial

## Historial Inteligente

- 10,000 comandos guardados
- Compartido entre sesiones
- Ignora duplicados
- Ignora comandos con espacio al inicio
- Búsqueda con `↑/↓` filtrando

## Integración FZF

```bash
Ctrl+R      # Buscar en historial
Ctrl+T      # Buscar archivos
Alt+C       # Cambiar directorio
```

## Autocompletado Mejorado

- **Tab** - Mostrar sugerencias
- **Tab Tab** - Navegar menú interactivo
- Colores para tipos de archivos
- Descripciones de comandos
- 250+ comandos soportados

## Zoxide

Aprende directorios que más usas:

```bash
z dotfiles      # Salta a ~/dotfiles
z conf nv       # Salta a ~/.config/nvim (fuzzy)
```

## Starship Prompt

Prompt personalizado con Catppuccin Mocha que muestra:
- Directorio actual
- Branch de Git + cambios
- Duración de comandos largos
- Versión de Node/Python/etc cuando aplica
- Indicador de modo Vi

## Personalización

### Agregar Alias en Categoría Existente

```bash
# 1. Editar archivo apropiado
nvim ~/.config/zsh/aliases/git.zsh

# 2. Agregar alias
alias gundo='git reset --soft HEAD~1'

# 3. Recargar
source ~/.zshrc
```

### Crear Nueva Categoría

```bash
# 1. Crear nuevo archivo
nvim ~/.config/zsh/aliases/nueva-categoria.zsh

# 2. Agregar aliases
alias ejemplo='comando'

# 3. Cargar en .zshrc
source "${ZDOTDIR}/aliases/nueva-categoria.zsh"
```

### Modificar Configuración Base

Archivos en `~/.config/zsh/config/`:
- `environment.zsh` - Variables de entorno, PATH
- `history.zsh` - Tamaño del historial
- `options.zsh` - Opciones de shell (setopt)
- `completion.zsh` - Sistema de autocompletado
- `keybindings.zsh` - Atajos de teclado

## Solución de Problemas

### Aliases no funcionan

```bash
# Verificar shell
echo $SHELL
# Debería mostrar: /usr/bin/zsh

# Recargar configuración
source ~/.zshrc
```

### Autocompletado no funciona

```bash
# Limpiar caché
rm ~/.zcompdump*
exec zsh
```

### Plugins no se cargan

```bash
# Verificar que estén instalados
ls ~/.zsh/
# Deberías ver:
# zsh-autosuggestions/
# zsh-syntax-highlighting/
# zsh-history-substring-search/
# zsh-you-should-use/

# Si faltan:
cd ~/dotfiles
stow zsh-plugins
```

## Performance

Configuración optimizada para carga rápida:
- Caché de autocompletado con check de 24 horas
- Plugins cargados al final
- Starship inicializado al último
- Compinit con opción `-i`

## Comparación con Configuración Anterior

| Aspecto | Anterior | Actual |
|---------|----------|--------|
| Archivos | 1 monolítico | 13 modulares |
| Líneas .zshrc | 220 | 40 |
| Organización | Secciones | Archivos por categoría |
| Mantenibilidad | Media | Alta |
| Escalabilidad | Limitada | Excelente |

## Recursos Adicionales

- [Aliases Completos](../reference/aliases.md)
- [Workflows](../guides/workflows.md)
- [Personalización](../guides/customization.md)

## Referencias

- [Zsh Documentation](https://zsh.sourceforge.io/Doc/)
- [Starship](https://starship.rs/)
- [eza](https://github.com/eza-community/eza)
- [bat](https://github.com/sharkdp/bat)
- [fzf](https://github.com/junegunn/fzf)
- [zoxide](https://github.com/ajeetdsouza/zoxide)

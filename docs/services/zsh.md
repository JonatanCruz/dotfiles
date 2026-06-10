![Zsh](https://img.shields.io/badge/zsh-%23cba6f7?style=for-the-badge&logo=zsh&logoColor=white&color=1e1e2e)

# Zsh - Shell Modular y Personalizada

Configuración modular de Zsh con 5 módulos de configuración base, 10 categorías de aliases, modo Vi, historial inteligente, lazy-loading y 4 plugins esenciales.

## Caracteristicas Principales

| Caracteristica | Detalle |
|---|---|
| Estructura | 5 archivos de configuracion separados por funcion |
| Aliases | 10 categorias (tools, git, tmux, gcloud, gh, docker, navigation, editor, utils, node) |
| Modo Vi | Edicion de linea de comandos estilo Vim con navegacion por historial |
| Historial | 10,000 comandos persistentes compartidos entre sesiones |
| Autocompletado | Menu interactivo con colores, case-insensitive, caching de 24 horas |
| Plugins | 4 plugins: autosuggestions, syntax-highlighting, substring-search, you-should-use |
| Prompt | Starship con Catppuccin Mocha (Git, Node, Python, duracion de comandos) |
| Integraciones | FZF, Zoxide, NVM, Pyenv, Direnv, GitHub CLI |
| Performance | Lazy-loading de NVM, Zoxide, Direnv y gh (400-600ms de ahorro) |

## Estructura Modular

```
zsh/
├── .zshrc                      # Punto de entrada (~40 lineas)
└── .config/zsh/
    ├── config/                 # Configuracion base
    │   ├── environment.zsh     # PATH, variables de entorno, lazy NVM
    │   ├── history.zsh         # Configuracion del historial
    │   ├── options.zsh         # setopt - opciones de la shell
    │   ├── completion.zsh      # Sistema de autocompletado
    │   └── keybindings.zsh     # Modo Vi + atajos de teclado
    │
    ├── aliases/                # 10 categorias de aliases
    │   ├── tools.zsh           # eza, bat, btop, fd, ripgrep, claude
    │   ├── git.zsh             # Git y LazyGit
    │   ├── tmux.zsh            # Gestion de sesiones tmux
    │   ├── gh.zsh              # GitHub CLI (aliases + funciones)
    │   ├── gcloud.zsh          # Google Cloud CLI (aliases + funciones)
    │   ├── docker.zsh          # Docker y Docker Compose (aliases + funciones)
    │   ├── navigation.zsh      # cd, zoxide, operaciones de archivos
    │   ├── editor.zsh          # Neovim y accesos a configuracion
    │   ├── node.zsh            # npm, pnpm, yarn, bun + funciones pkg*
    │   └── utils.zsh           # Utilidades generales
    │
    └── plugins.zsh             # Carga de plugins y herramientas
```

## Variables de Entorno

Variables exportadas en `environment.zsh`:

| Variable | Valor | Proposito |
|---|---|---|
| `EDITOR` | `nvim` | Editor predeterminado del sistema |
| `PAGER` | `less` | Paginador predeterminado |
| `TERM` | `xterm-256color` | Tipo de terminal (fallback si no esta definido) |
| `NVM_DIR` | `$HOME/.nvm` | Directorio de NVM |
| `BUN_INSTALL` | `$HOME/.bun` | Directorio de instalacion de Bun |
| `PYENV_ROOT` | `$HOME/.pyenv` | Directorio de pyenv |
| `FUNCNEST` | `1000` | Limite de anidamiento de funciones (para Starship/ZLE) |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | `100000` | Limite de tokens de salida de Claude Code |
| `DOTNET_ROOT` | `/usr/lib/dotnet` | Ruta del SDK de .NET |
| `ANDROID_HOME` | Detectado automaticamente | SDK de Android (macOS o Linux) |

### PATH extendido

El PATH incluye, en orden de prioridad:

1. `$HOME/.local/bin` - Binarios locales del usuario
2. `$BUN_INSTALL/bin` - Runtime Bun
3. `$PYENV_ROOT/bin` - Gestor de versiones Python
4. `$HOME/Library/Python/3.9/bin` - Paquetes Python de usuario (macOS)
5. `$HOME/.dotnet/tools` - Herramientas .NET
6. `$HOME/.opencode/bin` - OpenCode CLI
7. `$ANDROID_HOME/emulator`, `platform-tools`, `tools` - Android SDK

Homebrew se detecta automaticamente segun la plataforma: Apple Silicon (`/opt/homebrew`), Intel macOS (`/usr/local`) o Linux (`/home/linuxbrew`).

## Lazy-Loading (400-600ms de ahorro)

Las siguientes herramientas se inicializan **bajo demanda** en lugar de al inicio de cada sesion. El primer uso tarda un instante adicional; todas las sesiones posteriores son instantaneas.

| Herramienta | Ahorro estimado | Mecanismo |
|---|---|---|
| **NVM** | 200-300ms | Las funciones `nvm`, `node`, `npm`, `npx` son wrappers que cargan NVM al primer uso y se redefinen |
| **Zoxide** | 50-75ms | Las funciones `z` y `zi` cargan `zoxide init zsh` al primer uso y se redefinen |
| **Direnv** | 50-75ms | La funcion `direnv` carga el hook al primer uso y se redefine |
| **GitHub CLI** | ~50ms | Las completions de `gh` se cargan al primer uso de la funcion `gh` |

FZF se carga de forma inmediata por ser esencial para la interactividad del shell.

## Opciones del Shell (setopt)

Configuradas en `options.zsh`:

### Comportamiento general

| Opcion | Descripcion |
|---|---|
| `autocd` | Cambia de directorio sin escribir `cd` |
| `extendedglob` | Habilita patrones avanzados de glob (`~`, `^`, `#`) |
| `nomatch` | Devuelve error si un patron glob no encuentra coincidencias |
| `notify` | Notifica inmediatamente sobre cambios de estado en jobs en segundo plano |
| `NO_BEEP` | Deshabilita el beep de la terminal |

### Navegacion de directorios

| Opcion | Descripcion |
|---|---|
| `AUTO_PUSHD` | Agrega el directorio actual al stack automaticamente antes de cada `cd` |
| `PUSHD_SILENT` | No imprime el stack de directorios despues de `pushd`/`popd` |
| `PUSHD_IGNORE_DUPS` | No agrega entradas duplicadas al stack de directorios |

### Jobs y ordenamiento

| Opcion | Descripcion |
|---|---|
| `LONG_LIST_JOBS` | Muestra jobs en formato largo por defecto |
| `NUMERIC_GLOB_SORT` | Ordena archivos con numeros de forma numerica (ej. `file10` despues de `file9`) |

### Historial

Configurado en `history.zsh` con `HISTFILE=~/.zsh_history`, `HISTSIZE=10000`, `SAVEHIST=10000`:

| Opcion | Descripcion |
|---|---|
| `APPEND_HISTORY` | Agrega al archivo de historial en lugar de sobreescribirlo |
| `SHARE_HISTORY` | Comparte historial entre todas las sesiones de Zsh en tiempo real |
| `INC_APPEND_HISTORY` | Agrega comandos al historial de forma incremental (no solo al cerrar) |
| `HIST_IGNORE_DUPS` | No guarda comandos duplicados consecutivos |
| `HIST_IGNORE_SPACE` | No guarda comandos que empiezan con espacio |
| `HIST_VERIFY` | Muestra el comando expandido desde historial antes de ejecutarlo |

## Sistema de Autocompletado

Configurado en `completion.zsh`:

- **Caching de 24 horas**: `compinit` solo recarga el dump si tiene mas de 24 horas, reduciendo el tiempo de inicio
- **Case-insensitive**: Coincide `foo` con `Foo`, `FOO`, etc. (`m:{a-zA-Z}={A-Za-z}`)
- **Coincidencia parcial**: Soporta patrones como `r:|[._-]=* r:|=*` para fragmentos separados por puntos o guiones
- **Menu interactivo con colores**: `zstyle ':completion:*' menu select` activa la navegacion con flechas
- **Colores por tipo de archivo**: Usa `$LS_COLORS` para colorear entradas en el menu
- **Descripciones en grupos**: Muestra el nombre de cada grupo de completions formateado en negrita
- **Docker option-stacking**: Permite combinar flags de Docker (`-it`) sin necesidad de separarlos

Fuentes de completions adicionales:
- `~/.zsh/zsh-completions/src` - Completions de la comunidad
- `~/.docker/completions` - Completions oficiales de Docker

## Modo Vi y Atajos de Teclado

Configurado en `keybindings.zsh`:

| Atajo | Modo | Accion |
|---|---|---|
| `ESC` | insercion | Cambiar a modo normal |
| `i` | normal | Cambiar a modo insercion |
| `hjkl` | normal | Navegacion de cursor |
| `/` | normal | Buscar en historial |
| `↑` / `k` | normal | Historial anterior (filtrando por prefijo escrito) |
| `↓` / `j` | normal | Historial siguiente (filtrando por prefijo escrito) |

La busqueda por historial (`↑`/`↓`) utiliza `zsh-history-substring-search`, que filtra por lo que ya escribiste antes de presionar la tecla.

### Atajos de FZF

| Atajo | Accion |
|---|---|
| `Ctrl+R` | Buscar en historial con interfaz fuzzy |
| `Ctrl+T` | Buscar archivos en el directorio actual |
| `Alt+C` | Cambiar directorio con busqueda fuzzy |

## Plugins

El orden de carga es critico: `zsh-syntax-highlighting` debe ser el ultimo plugin.

### zsh-autosuggestions

Sugiere el comando completo basandose en el historial. La sugerencia aparece en gris.

- `→` acepta la sugerencia completa
- `Ctrl+→` acepta la siguiente palabra de la sugerencia

### zsh-syntax-highlighting

Colorea la linea de comandos mientras escribes:

- Verde: comando valido reconocido
- Rojo: comando no encontrado
- Azul: ruta de archivo existente

### zsh-history-substring-search

Reemplaza la busqueda de historial por defecto. Presionar `↑`/`↓` filtra el historial por el texto ya escrito en la linea.

### zsh-you-should-use

Recuerda cuando usas el comando largo en lugar del alias definido.

Ejemplo: ejecutar `git status` muestra un aviso sugiriendo `gs`.

## Aliases por Categoria

### Herramientas Modernas (tools.zsh)

Requiere: `eza`, `bat`, `btop`, `tldr`, `fd`, `ripgrep`. Se recomienda una Nerd Font para iconos.

```bash
# Listado de archivos (eza)
ls          # eza --icons
l           # eza -l --icons
la          # eza -la --icons (incluye ocultos)
ll          # eza -l --git --icons (muestra estado Git)
lt          # eza --tree --level=2
llt         # eza --tree --level=3

# Herramientas modernas
cat         # bat --paging=never (syntax highlighting)
top         # btop
monitor     # btop
help        # tldr

# Busqueda
grep        # grep --color=auto
ff          # fd --hidden (buscar archivos incluyendo ocultos)
rg          # rg -i (ripgrep case-insensitive)

# Claude Code
clauded     # claude --dangerously-skip-permissions con ENABLE_TOOL_SEARCH=true
```

### Git (git.zsh)

```bash
g           # git
lg          # lazygit

# Estado
gs          # git status -s (formato corto)
gst         # git status

# Historial
gl          # git log --oneline --graph --decorate --all

# Staging
ga          # git add
gaa         # git add -A

# Commits
gc          # git commit -m
gca         # git commit -am

# Sincronizacion
gp          # git push
gpl         # git pull

# Ramas
gco         # git checkout
gcb         # git checkout -b (crear rama nueva)
gb          # git branch
```

### Tmux (tmux.zsh)

```bash
tn <nombre>   # tmux new -s (nueva sesion)
ta <nombre>   # tmux a (conectar a sesion)
tl            # tmux ls (listar sesiones)
tk <nombre>   # tmux kill-session -t
tks           # tmux kill-server (matar todas las sesiones)
```

### Docker (docker.zsh)

```bash
# Docker basico
d             # docker
di            # docker images
dps           # docker ps
dpsa          # docker ps -a
dexec         # docker exec -it
dlogs         # docker logs -f
dinspect      # docker inspect

# Ciclo de vida
dbuild        # docker build
drun          # docker run
dstop         # docker stop
dstart        # docker start
drestart      # docker restart
drm           # docker rm
drmi          # docker rmi

# Limpieza
dprune        # docker system prune -a --volumes
dpruneimg     # docker image prune -a
dprunecont    # docker container prune
dprunevol     # docker volume prune
dprunenet     # docker network prune

# Docker Compose
dc            # docker compose
dcu           # docker compose up
dcud          # docker compose up -d
dcd           # docker compose down
dcb           # docker compose build
dcr           # docker compose restart
dcl           # docker compose logs -f
dcp           # docker compose ps
dcexec        # docker compose exec

# Redes
dnet          # docker network ls
dnetrm        # docker network rm
dnetinspect   # docker network inspect

# Volumenes
dvol          # docker volume ls
dvolrm        # docker volume rm
dvolinspect   # docker volume inspect

# Info
dstats        # docker stats
dinfo         # docker info
dversion      # docker version
```

Funciones de Docker:

```bash
dstopall      # Detener todos los contenedores en ejecucion
drmall        # Eliminar todos los contenedores (detenidos)
drmiall       # Eliminar todas las imagenes
dsh <cont>    # Abrir bash en un contenedor
dshell <cont> # Abrir sh en un contenedor
dlog <cont>   # Ver logs de un contenedor con follow
dcleanall     # Limpiar todo (con confirmacion): contenedores, imagenes, volumenes, redes
```

### GitHub CLI (gh.zsh)

Aliases cortos de uso frecuente:

```bash
# Autenticacion
ghauth           # gh auth login
ghauthstatus     # gh auth status
ghauthlogout     # gh auth logout
ghauthtoken      # gh auth token

# Repositorio actual
ghv              # gh repo view
ghvw             # gh repo view --web
ghb              # gh browse

# Pull Requests
ghprs            # gh pr list
ghprc            # gh pr create
ghprv            # gh pr view
ghprm            # gh pr merge
ghprdiff         # gh pr diff
ghprchecks       # gh pr checks
ghprdraft        # gh pr create --draft
ghprco           # gh pr checkout

# Issues
ghis             # gh issue list
ghic             # gh issue create
ghiv             # gh issue view

# Workflows / Actions
ghw              # gh workflow list
ghr              # gh run list
ghrv             # gh run view
ghrw             # gh run watch

# Gists
ghgistlist       # gh gist list
ghgistcreate     # gh gist create
ghgistview       # gh gist view

# Busqueda
ghsearchrepos    # gh search repos
ghsearchissues   # gh search issues
ghsearchprs      # gh search prs
ghsearchcode     # gh search code
```

Funciones de GitHub CLI:

```bash
ghpr-quick <titulo> [desc]  # Crear PR con titulo y cuerpo opcional
ghpr-last                   # Ver el ultimo PR abierto
ghpr-mine                   # Listar PRs del usuario autenticado
ghpr-squash <num>           # Mergear PR con squash y borrar rama
ghpr-approve <num> [msg]    # Aprobar PR con comentario (default: "LGTM")
ghpr-co <num>               # Checkout de PR por numero con listado de ayuda
ghpr-diff <num>             # Ver diff de un PR por numero
ghissue-quick <titulo>      # Crear issue con titulo y cuerpo opcional
ghissue-mine                # Listar issues asignados al usuario autenticado
ghrun-logs                  # Ver logs del ultimo run de GitHub Actions
ghstatus                    # Ver estado completo del repo (PRs, issues, actions)
ghclone <repo> [usuario]    # Clonar repo con usuario auto-detectado
ghrepo-new <nombre>         # Crear nuevo repo con descripcion y visibilidad
ghme                        # Ver perfil del usuario autenticado
ghtrending [lenguaje]       # Ver repos con mas estrellas del dia
ghcode <query>              # Buscar codigo en el repo actual
```

### Google Cloud (gcloud.zsh)

```bash
# Alias base (CONFLICTO: g tambien es alias de git - el ultimo cargado gana)
g              # gcloud

# Autenticacion y configuracion
gauth          # gcloud auth login
gauthlist      # gcloud auth list
gconfig        # gcloud config list
gproject       # gcloud config set project
gprojectlist   # gcloud projects list
gregion        # gcloud config set compute/region
gzone          # gcloud config set compute/zone

# Compute Engine
gvmlist        # gcloud compute instances list
gvmcreate      # gcloud compute instances create
gvmstart       # gcloud compute instances start
gvmstop        # gcloud compute instances stop
gssh           # gcloud compute ssh
gscp           # gcloud compute scp

# GKE (Kubernetes)
gkelist        # gcloud container clusters list
gkecreate      # gcloud container clusters create
gkecreds       # gcloud container clusters get-credentials

# Cloud Run
grunlist       # gcloud run services list
grundeploy     # gcloud run deploy
grunlogs       # gcloud run services logs read

# Cloud Functions
gfunclist      # gcloud functions list
gfuncdeploy    # gcloud functions deploy

# App Engine
gappdeploy     # gcloud app deploy
gappbrowse     # gcloud app browse

# Cloud SQL
gsqllist       # gcloud sql instances list
gsqlconnect    # gcloud sql connect

# Cloud Storage
gls            # gcloud storage ls
gcp            # gcloud storage cp
gmv            # gcloud storage mv
grm            # gcloud storage rm
gbuckets       # gcloud storage buckets list

# IAM
gserviceaccounts # gcloud iam service-accounts list
groles           # gcloud iam roles list

# Cloud Build
gbuildlist     # gcloud builds list
gbuildsubmit   # gcloud builds submit

# Logging
glogsread      # gcloud logging read
glogstail      # gcloud logging tail

# Redes
gnetworks      # gcloud compute networks list
gfirewall      # gcloud compute firewall-rules list
gips           # gcloud compute addresses list

# Artifact Registry
garlist        # gcloud artifacts repositories list
gcrlist        # gcloud container images list

# Info
ginfo          # gcloud info
gversion       # gcloud version
gcomponents    # gcloud components list
```

Funciones de Google Cloud:

```bash
gswitch <project-id>              # Cambiar de proyecto con listado de ayuda
gvmssh <nombre> [zona]            # SSH a una instancia (detecta zona automaticamente)
grunlogs-tail <servicio>          # Ver logs recientes de Cloud Run formateados
grun-deploy <svc> <imagen> [reg]  # Desplegar a Cloud Run con region configurable
gcontext                          # Ver configuracion activa (proyecto, cuenta, region, zona)
gresources                        # Listar VMs, clusters, servicios y buckets del proyecto
gcleanup                          # Eliminar todos los recursos del proyecto (con confirmacion)
```

### Navegacion (navigation.zsh)

```bash
# Navegacion rapida
..          # cd ..
...         # cd ../..
....        # cd ../../..
~           # cd ~

# Zoxide (cd inteligente con aprendizaje)
z <dir>     # Saltar a directorio frecuente (uso principal)
zi          # Busqueda interactiva con fzf
za          # Alias de zi (busqueda interactiva)
zq          # zoxide query -ls (ver base de datos con frecuencia)
zrm <ruta>  # Eliminar ruta de la base de datos de zoxide

# Operaciones de archivos (modo seguro)
cp          # cp -iv (pide confirmacion + verbose)
mv          # mv -iv (pide confirmacion + verbose)
mkdir       # mkdir -p (crea directorios padre si no existen)
t           # touch (crear archivos)
```

### Editor (editor.zsh)

```bash
v           # nvim
vim         # nvim
sv          # sudo nvim

# Acceso rapido a configuraciones
zshrc       # nvim ~/.zshrc
tmuxconf    # nvim ~/.tmux.conf
nvimconf    # cd ~/.config/nvim && nvim .
```

### Utilidades (utils.zsh)

```bash
yz          # yazi (file manager TUI)
c           # clear
e           # exit
ducks       # du -sh * | sort -rh | head -n 10 (top 10 por tamano)
myip        # curl ifconfig.me (IP publica)
```

### Node.js / Gestores de Paquetes (node.zsh)

#### NPM

```bash
ni          # npm install
nid         # npm install --save-dev
nig         # npm install -g
nu          # npm uninstall
nup         # npm update
nr          # npm run
nrs         # npm run start
nrd         # npm run dev
nrb         # npm run build
nrt         # npm run test
nrl         # npm run lint
nrf         # npm run format
nci         # npm ci
nls         # npm ls
nout        # npm outdated
nau         # npm audit
nauf        # npm audit fix
```

#### PNPM

```bash
pi          # pnpm install
pid         # pnpm install -D
pig         # pnpm install -g
pu          # pnpm uninstall
pup         # pnpm update
pr          # pnpm run
prs         # pnpm run start
prd         # pnpm run dev
prb         # pnpm run build
prt         # pnpm run test
prl         # pnpm run lint
prf         # pnpm run format
pa          # pnpm add
pad         # pnpm add -D
pag         # pnpm add -g
px          # pnpm dlx (ejecutar sin instalar)
```

#### Yarn

```bash
yi          # yarn install
ya          # yarn add
yad         # yarn add -D
yag         # yarn global add
yu          # yarn upgrade
yr          # yarn run
yrs         # yarn start
yrd         # yarn dev
yrb         # yarn build
yrt         # yarn test
yrl         # yarn lint
```

#### Bun

```bash
bi          # bun install
ba          # bun add
bad         # bun add -d
br          # bun run
brs         # bun run start
brd         # bun run dev
brb         # bun run build
brt         # bun run test
bx          # bunx (ejecutar sin instalar)
```

## Funciones Inteligentes de Node (pkg*)

Detectan automaticamente el gestor de paquetes del proyecto por el lockfile presente. El orden de deteccion es: `bun.lockb` > `pnpm-lock.yaml` > `yarn.lock` > `package-lock.json` > npm (fallback).

```bash
pkg <cmd>       # Ejecutar cualquier comando con el gestor correcto
                # Ejemplo: pkg add axios  →  pnpm add axios (si hay pnpm-lock.yaml)

pkgi            # Instalar todas las dependencias con el gestor correcto
                # Equivale a: bun install | pnpm install | yarn install | npm install

pkgr <script>   # Ejecutar un script npm con el gestor correcto
                # Ejemplo: pkgr dev  →  bun run dev

pkgclean        # Eliminar node_modules y reinstalar desde cero
                # Ejecuta: rm -rf node_modules && pkgi
```

Estas funciones eliminan la necesidad de recordar que gestor usa cada proyecto del equipo.

## Starship Prompt

Configurado con tema Catppuccin Mocha. Muestra:

- Directorio actual (con ruta abreviada)
- Branch de Git y estado de cambios (staged, unstaged, untracked)
- Duracion de comandos que tardan mas de un umbral
- Version de runtime activo (Node, Python, etc.) cuando aplica
- Indicador del modo Vi (Normal / Insert)

Starship se inicializa como ultima linea de `plugins.zsh` para garantizar que todo el entorno este configurado antes de que el prompt lo lea.

## Plugins

### Instalacion y Gestion

Los plugins se manejan como submódulos de Git en el directorio `~/.zsh/`:

```bash
# Verificar que los plugins esten instalados
ls ~/.zsh/
# zsh-autosuggestions/
# zsh-history-substring-search/
# zsh-syntax-highlighting/
# zsh-you-should-use/

# Si no estan (instalacion via Stow)
cd ~/dotfiles
stow zsh-plugins
```

## Personalizacion

### Agregar un alias en una categoria existente

```bash
# 1. Editar el archivo de la categoria correspondiente
nvim ~/.config/zsh/aliases/git.zsh

# 2. Agregar el alias
alias gundo='git reset --soft HEAD~1'

# 3. Recargar la configuracion
source ~/.zshrc
```

### Crear una nueva categoria de aliases

```bash
# 1. Crear el archivo
nvim ~/.config/zsh/aliases/nueva-categoria.zsh

# 2. Definir aliases o funciones
alias ejemplo='comando --flags'

# 3. Agregar la carga en .zshrc
source "${ZDOTDIR}/aliases/nueva-categoria.zsh"
```

### Modificar configuracion base

Los archivos en `~/.config/zsh/config/` controlan el comportamiento central:

- `environment.zsh` - Variables de entorno, PATH, lazy-loading de herramientas
- `history.zsh` - Tamano del historial, opciones de guardado
- `options.zsh` - Opciones de la shell (setopt)
- `completion.zsh` - Sistema de autocompletado y estilos
- `keybindings.zsh` - Modo Vi y atajos de teclado

## Solucion de Problemas

### Los aliases no funcionan

```bash
# Verificar que el shell activo es Zsh
echo $SHELL
# Deberia mostrar: /usr/bin/zsh o /bin/zsh

# Recargar la configuracion
source ~/.zshrc
```

### El autocompletado no responde

```bash
# Limpiar el cache de completions
rm ~/.zcompdump*
exec zsh
```

### Los plugins no se cargan

```bash
# Verificar que los directorios existen
ls ~/.zsh/

# Reaplicar con Stow desde el directorio del repositorio
cd ~/dotfiles
stow -R zsh-plugins
```

### NVM o Node no se encuentran

La primera vez que se usa `node`, `npm`, `npx` o `nvm` en una sesion, se carga NVM (lazy-loading). Si el binario no existe aun:

```bash
# Verificar que NVM esta instalado
ls $NVM_DIR
# Deberia existir nvm.sh

# Cargar NVM manualmente en la sesion actual
source "$NVM_DIR/nvm.sh"
nvm install --lts
```

### Zoxide no recuerda directorios

La primera vez que se usa `z` o `zi` en una sesion, se inicializa zoxide. Si la base de datos esta vacia, hay que visitar los directorios primero con `cd` o `z`:

```bash
# Ver base de datos con frecuencias
zq

# Agregar directorio manualmente
zoxide add ~/proyectos/mi-proyecto
```

## Comparacion con Configuracion Anterior

| Aspecto | Anterior | Actual |
|---|---|---|
| Archivos | 1 monolitico | 15 modulares (5 config + 10 aliases) |
| Lineas en .zshrc | ~220 | ~40 |
| Organizacion | Secciones en un archivo | Archivos por categoria |
| Tiempo de inicio | Sin lazy-loading | 400-600ms mas rapido |
| Mantenibilidad | Media | Alta |
| Escalabilidad | Limitada | Agregar archivo = nueva categoria |

## Referencias

- [Zsh Documentation](https://zsh.sourceforge.io/Doc/)
- [Starship](https://starship.rs/)
- [eza](https://github.com/eza-community/eza)
- [bat](https://github.com/sharkdp/bat)
- [fzf](https://github.com/junegunn/fzf)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [GNU Stow](https://www.gnu.org/software/stow/)

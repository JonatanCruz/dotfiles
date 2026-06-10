# Aliases — Referencia Completa

Todos los aliases y funciones disponibles en este entorno de desarrollo, organizados por herramienta. Los aliases de shell se definen en `zsh/.config/zsh/aliases/` y los aliases de git en `git/.gitconfig`.

---

## Indice

1. [Top 15 mas usados](#top-15-mas-usados)
2. [Git — Shell](#git--shell)
3. [GitHub CLI](#github-cli)
4. [Docker](#docker)
5. [Node.js — Package Managers](#nodejs--package-managers)
6. [Tmux](#tmux)
7. [Herramientas Modernas](#herramientas-modernas)
8. [Navegacion](#navegacion)
9. [Editor](#editor)
10. [Utilidades](#utilidades)
11. [Google Cloud (gcloud)](#google-cloud-gcloud)
12. [Gitconfig](#gitconfig)

---

## Top 15 mas usados

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `gs` | `git status -s` | Estado corto de git |
| `gaa` | `git add -A` | Agregar todos los cambios |
| `gc "msg"` | `git commit -m "msg"` | Commit rapido |
| `gp` | `git push` | Push a remote |
| `lg` | `lazygit` | Interfaz TUI para git |
| `ll` | `eza -l --git --icons` | Listar archivos con info git |
| `z <dir>` | zoxide | Saltar a directorio por historial |
| `dcud` | `docker compose up -d` | Levantar compose en background |
| `v` | `nvim` | Abrir Neovim |
| `ta <sesion>` | `tmux a` | Conectarse a sesion tmux |
| `ghb` | `gh browse` | Abrir repo actual en navegador |
| `ghprc` | `gh pr create` | Crear Pull Request |
| `cat <file>` | `bat --paging=never` | Ver archivo con syntax highlight |
| `pkgi` | detecta lockfile | Instalar deps con el gestor correcto |
| `pkg <cmd>` | detecta lockfile | Ejecutar comando con el gestor correcto |

---

## Git — Shell

Archivo: `zsh/.config/zsh/aliases/git.zsh`

> Nota: `gcloud.zsh` tambien define `alias g='gcloud'`. Si ambos archivos estan activos, el orden de carga determina cual prevalece. Para git, usar el comando completo `git` o el alias `lg` para lazygit.

### Basicos

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `g` | `git` | Comando git base |
| `lg` | `lazygit` | Abrir LazyGit (interfaz TUI) |

### Estado y log

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `gs` | `git status -s` | Estado corto |
| `gst` | `git status` | Estado completo |
| `gl` | `git log --oneline --graph --decorate --all` | Log grafico compacto |

### Staging y commits

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `ga` | `git add` | Agregar archivos |
| `gaa` | `git add -A` | Agregar todos los cambios |
| `gc` | `git commit -m` | Commit con mensaje |
| `gca` | `git commit -am` | Commit con add y mensaje |

### Push y pull

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `gp` | `git push` | Push a remote |
| `gpl` | `git pull` | Pull de remote |

### Branches

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `gco` | `git checkout` | Cambiar de branch |
| `gcb` | `git checkout -b` | Crear y cambiar a branch |
| `gb` | `git branch` | Listar branches |

---

## GitHub CLI

Archivo: `zsh/.config/zsh/aliases/gh.zsh`

### Autenticacion y configuracion

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `ghauth` | `gh auth login` | Login a GitHub |
| `ghauthstatus` | `gh auth status` | Ver estado de autenticacion |
| `ghauthlogout` | `gh auth logout` | Logout de GitHub |
| `ghauthrefresh` | `gh auth refresh` | Refrescar token |
| `ghauthtoken` | `gh auth token` | Ver token de acceso |
| `ghconfig` | `gh config list` | Listar configuracion |
| `ghconfigset` | `gh config set` | Establecer valor de configuracion |
| `ghconfigget` | `gh config get` | Leer valor de configuracion |

### Repositorios

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `ghrepo` | `gh repo` | Comando repo base |
| `ghrepolist` | `gh repo list` | Listar repos |
| `ghreposearch` | `gh search repos` | Buscar repositorios |
| `ghrepoview` | `gh repo view` | Ver info de repo |
| `ghrepoweb` | `gh repo view --web` | Abrir repo en navegador |
| `ghrepocreate` | `gh repo create` | Crear nuevo repo |
| `ghrepoclone` | `gh repo clone` | Clonar repo |
| `ghrepofork` | `gh repo fork` | Forkear repo |
| `ghreporename` | `gh repo rename` | Renombrar repo |
| `ghrepodelete` | `gh repo delete` | Eliminar repo |
| `ghreposync` | `gh repo sync` | Sincronizar repo |
| `ghrepoarchive` | `gh repo archive` | Archivar repo |
| `ghv` | `gh repo view` | Ver repo (alias corto) |
| `ghvw` | `gh repo view --web` | Ver repo en web (alias corto) |
| `ghb` | `gh browse` | Abrir repo actual en web |

### Releases

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `ghreleases` | `gh release list` | Listar releases |
| `ghrelease` | `gh release view` | Ver release |
| `ghreleasecreate` | `gh release create` | Crear release |
| `ghreleasedownload` | `gh release download` | Descargar release |

### Pull Requests

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `ghpr` | `gh pr` | Comando PR base |
| `ghprlist` | `gh pr list` | Listar PRs |
| `ghprview` | `gh pr view` | Ver PR |
| `ghprweb` | `gh pr view --web` | Abrir PR en web |
| `ghprstatus` | `gh pr status` | Estado de PRs del usuario |
| `ghprcreate` | `gh pr create` | Crear PR |
| `ghprdraft` | `gh pr create --draft` | Crear PR como borrador |
| `ghpredit` | `gh pr edit` | Editar PR |
| `ghprclose` | `gh pr close` | Cerrar PR |
| `ghprreopen` | `gh pr reopen` | Reabrir PR |
| `ghprready` | `gh pr ready` | Marcar PR como listo |
| `ghprdiff` | `gh pr diff` | Ver diff del PR |
| `ghprreview` | `gh pr review` | Revisar PR |
| `ghprchecks` | `gh pr checks` | Ver checks del PR |
| `ghprmerge` | `gh pr merge` | Mergear PR |
| `ghprcheckout` | `gh pr checkout` | Checkout de PR |
| `ghprco` | `gh pr checkout` | Checkout de PR (alias corto) |
| `ghprcomment` | `gh pr comment` | Comentar en PR |
| `ghprs` | `gh pr list` | Listar PRs (alias corto) |
| `ghprc` | `gh pr create` | Crear PR (alias corto) |
| `ghprv` | `gh pr view` | Ver PR (alias corto) |
| `ghprm` | `gh pr merge` | Mergear PR (alias corto) |

### Issues

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `ghissue` | `gh issue` | Comando issue base |
| `ghissuelist` | `gh issue list` | Listar issues |
| `ghissueview` | `gh issue view` | Ver issue |
| `ghissueweb` | `gh issue view --web` | Abrir issue en web |
| `ghissuestatus` | `gh issue status` | Estado de issues del usuario |
| `ghissuecreate` | `gh issue create` | Crear issue |
| `ghissueedit` | `gh issue edit` | Editar issue |
| `ghissueclose` | `gh issue close` | Cerrar issue |
| `ghissuereopen` | `gh issue reopen` | Reabrir issue |
| `ghissuecomment` | `gh issue comment` | Comentar en issue |
| `ghissuesearch` | `gh search issues` | Buscar issues |
| `ghis` | `gh issue list` | Listar issues (alias corto) |
| `ghic` | `gh issue create` | Crear issue (alias corto) |
| `ghiv` | `gh issue view` | Ver issue (alias corto) |

### Gists

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `ghgist` | `gh gist` | Comando gist base |
| `ghgistlist` | `gh gist list` | Listar gists |
| `ghgistcreate` | `gh gist create` | Crear gist |
| `ghgistview` | `gh gist view` | Ver gist |
| `ghgistedit` | `gh gist edit` | Editar gist |
| `ghgistdelete` | `gh gist delete` | Eliminar gist |
| `ghgistclone` | `gh gist clone` | Clonar gist |

### Workflows y Actions

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `ghworkflow` | `gh workflow` | Comando workflow base |
| `ghworkflowlist` | `gh workflow list` | Listar workflows |
| `ghworkflowview` | `gh workflow view` | Ver workflow |
| `ghworkflowrun` | `gh workflow run` | Ejecutar workflow |
| `ghworkflowenable` | `gh workflow enable` | Habilitar workflow |
| `ghworkflowdisable` | `gh workflow disable` | Deshabilitar workflow |
| `ghrun` | `gh run` | Comando run base |
| `ghrunlist` | `gh run list` | Listar runs |
| `ghrunview` | `gh run view` | Ver run |
| `ghrunwatch` | `gh run watch` | Seguir run en tiempo real |
| `ghrunrerun` | `gh run rerun` | Re-ejecutar run |
| `ghruncancel` | `gh run cancel` | Cancelar run |
| `ghrundownload` | `gh run download` | Descargar artefactos del run |
| `ghrunlogs` | `gh run view --log` | Ver logs de un run |
| `ghw` | `gh workflow list` | Listar workflows (alias corto) |
| `ghr` | `gh run list` | Listar runs (alias corto) |
| `ghrv` | `gh run view` | Ver run (alias corto) |
| `ghrw` | `gh run watch` | Seguir run (alias corto) |

### Proyectos

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `ghproject` | `gh project` | Comando project base |
| `ghprojectlist` | `gh project list` | Listar proyectos |
| `ghprojectview` | `gh project view` | Ver proyecto |
| `ghprojectcreate` | `gh project create` | Crear proyecto |

### Busqueda

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `ghsearch` | `gh search` | Busqueda global |
| `ghsearchrepos` | `gh search repos` | Buscar repositorios |
| `ghsearchissues` | `gh search issues` | Buscar issues |
| `ghsearchprs` | `gh search prs` | Buscar PRs |
| `ghsearchcode` | `gh search code` | Buscar en codigo |

### Usuarios y organizaciones

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `ghuser` | `gh api user` | Info del usuario autenticado |
| `ghorgs` | `gh api user/orgs` | Listar organizaciones del usuario |

### Funciones

**`ghpr-quick '<titulo>' [descripcion]`**
Crear PR con titulo y cuerpo opcional directamente desde la terminal.

**`ghpr-last`**
Ver el ultimo PR abierto del repositorio.

**`ghissue-quick '<titulo>' [descripcion]`**
Crear issue con titulo y cuerpo opcional.

**`ghpr-mine`**
Listar todos los PRs (abiertos y cerrados) creados por el usuario autenticado.

**`ghissue-mine`**
Listar issues abiertos asignados al usuario autenticado.

**`ghstatus`**
Resumen del repositorio actual: info, PRs abiertos, issues abiertos y ultimas GitHub Actions.

**`ghpr-co <pr-number>`**
Checkout de un PR por numero. Sin argumentos, muestra los PRs disponibles.

**`ghpr-diff <pr-number>`**
Ver el diff de un PR especifico.

**`ghpr-squash <pr-number>`**
Mergear PR con squash y eliminar la branch automaticamente.

**`ghpr-approve <pr-number> [comentario]`**
Aprobar un PR con comentario opcional (por defecto: "LGTM").

**`ghrun-logs`**
Ver los logs del ultimo GitHub Actions run.

**`ghrelease-create <tag> [title] [notes]`**
Crear un release con tag, titulo y notas de release.

**`ghclone <repo> [usuario]`**
Clonar un repositorio del usuario autenticado o de otro usuario especificado.

**`ghtrending [lenguaje]`**
Ver los repositorios con mas estrellas del dia, opcionalmente filtrado por lenguaje.

**`ghcode <query>`**
Buscar codigo en el repositorio actual de GitHub.

**`ghme`**
Ver el perfil completo del usuario autenticado (nombre, bio, repos, seguidores).

**`ghrepo-new <nombre> [descripcion] [privado:y/n]`**
Crear un nuevo repositorio con nombre, descripcion y visibilidad, y clonarlo automaticamente.

---

## Docker

Archivo: `zsh/.config/zsh/aliases/docker.zsh`

### Docker basico

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `d` | `docker` | Comando docker base |
| `di` | `docker images` | Listar imagenes |
| `dps` | `docker ps` | Listar contenedores activos |
| `dpsa` | `docker ps -a` | Listar todos los contenedores |
| `drm` | `docker rm` | Eliminar contenedor |
| `drmi` | `docker rmi` | Eliminar imagen |
| `dexec` | `docker exec -it` | Ejecutar comando interactivo en contenedor |
| `dlogs` | `docker logs -f` | Ver logs en tiempo real |
| `dinspect` | `docker inspect` | Inspeccionar objeto docker |

### Build y run

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `dbuild` | `docker build` | Build de imagen |
| `drun` | `docker run` | Ejecutar contenedor |
| `dstop` | `docker stop` | Detener contenedor |
| `dstart` | `docker start` | Iniciar contenedor |
| `drestart` | `docker restart` | Reiniciar contenedor |

### Limpieza

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `dprune` | `docker system prune -a --volumes` | Limpieza completa del sistema |
| `dpruneimg` | `docker image prune -a` | Limpiar imagenes no usadas |
| `dprunecont` | `docker container prune` | Limpiar contenedores detenidos |
| `dprunevol` | `docker volume prune` | Limpiar volumenes no usados |
| `dprunenet` | `docker network prune` | Limpiar redes no usadas |

### Docker Compose

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `dc` | `docker compose` | Comando compose base |
| `dcu` | `docker compose up` | Levantar servicios |
| `dcud` | `docker compose up -d` | Levantar servicios en background |
| `dcd` | `docker compose down` | Bajar servicios |
| `dcb` | `docker compose build` | Build de servicios |
| `dcr` | `docker compose restart` | Reiniciar servicios |
| `dcl` | `docker compose logs -f` | Ver logs en tiempo real |
| `dcp` | `docker compose ps` | Estado de servicios |
| `dcexec` | `docker compose exec` | Ejecutar comando en servicio |

### Network y volumes

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `dnet` | `docker network ls` | Listar redes |
| `dnetrm` | `docker network rm` | Eliminar red |
| `dnetinspect` | `docker network inspect` | Inspeccionar red |
| `dvol` | `docker volume ls` | Listar volumenes |
| `dvolrm` | `docker volume rm` | Eliminar volumen |
| `dvolinspect` | `docker volume inspect` | Inspeccionar volumen |

### Stats e informacion

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `dstats` | `docker stats` | Uso de recursos en tiempo real |
| `dinfo` | `docker info` | Info del sistema Docker |
| `dversion` | `docker version` | Ver version de Docker |

### Funciones

**`dstopall`**
Detener todos los contenedores activos (`docker stop $(docker ps -q)`).

**`drmall`**
Eliminar todos los contenedores (`docker rm $(docker ps -a -q)`).

**`drmiall`**
Eliminar todas las imagenes (`docker rmi $(docker images -q)`).

**`dsh <contenedor>`**
Entrar al shell `/bin/bash` de un contenedor.

**`dshell <contenedor>`**
Entrar al shell `/bin/sh` de un contenedor.

**`dlog <contenedor>`**
Ver logs en tiempo real de un contenedor especifico.

**`dcleanall`**
Limpieza completa con confirmacion: elimina contenedores, imagenes, volumenes y redes.

---

## Node.js — Package Managers

Archivo: `zsh/.config/zsh/aliases/node.zsh`

### npm

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `ni` | `npm install` | Instalar dependencias |
| `nid` | `npm install --save-dev` | Instalar como devDependency |
| `nig` | `npm install -g` | Instalar globalmente |
| `nu` | `npm uninstall` | Desinstalar paquete |
| `nup` | `npm update` | Actualizar paquetes |
| `nr` | `npm run` | Ejecutar script |
| `nrs` | `npm run start` | Start |
| `nrd` | `npm run dev` | Dev server |
| `nrb` | `npm run build` | Build |
| `nrt` | `npm run test` | Tests |
| `nrl` | `npm run lint` | Linting |
| `nrf` | `npm run format` | Formatear codigo |
| `nci` | `npm ci` | Clean install |
| `nls` | `npm ls` | Listar paquetes instalados |
| `nout` | `npm outdated` | Ver paquetes desactualizados |
| `nau` | `npm audit` | Auditoria de seguridad |
| `nauf` | `npm audit fix` | Fix automatico de auditoria |

### pnpm

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `pi` | `pnpm install` | Instalar dependencias |
| `pid` | `pnpm install -D` | Instalar como devDependency |
| `pig` | `pnpm install -g` | Instalar globalmente |
| `pu` | `pnpm uninstall` | Desinstalar paquete |
| `pup` | `pnpm update` | Actualizar paquetes |
| `pr` | `pnpm run` | Ejecutar script |
| `prs` | `pnpm run start` | Start |
| `prd` | `pnpm run dev` | Dev server |
| `prb` | `pnpm run build` | Build |
| `prt` | `pnpm run test` | Tests |
| `prl` | `pnpm run lint` | Linting |
| `prf` | `pnpm run format` | Formatear codigo |
| `pa` | `pnpm add` | Agregar paquete |
| `pad` | `pnpm add -D` | Agregar como devDependency |
| `pag` | `pnpm add -g` | Agregar globalmente |
| `px` | `pnpm dlx` | Ejecutar paquete sin instalar |

### yarn

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `yi` | `yarn install` | Instalar dependencias |
| `ya` | `yarn add` | Agregar paquete |
| `yad` | `yarn add -D` | Agregar como devDependency |
| `yag` | `yarn global add` | Agregar globalmente |
| `yu` | `yarn upgrade` | Actualizar paquetes |
| `yr` | `yarn run` | Ejecutar script |
| `yrs` | `yarn start` | Start |
| `yrd` | `yarn dev` | Dev server |
| `yrb` | `yarn build` | Build |
| `yrt` | `yarn test` | Tests |
| `yrl` | `yarn lint` | Linting |

### bun

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `bi` | `bun install` | Instalar dependencias |
| `ba` | `bun add` | Agregar paquete |
| `bad` | `bun add -d` | Agregar como devDependency |
| `br` | `bun run` | Ejecutar script |
| `brs` | `bun run start` | Start |
| `brd` | `bun run dev` | Dev server |
| `brb` | `bun run build` | Build |
| `brt` | `bun run test` | Tests |
| `bx` | `bunx` | Ejecutar paquete sin instalar |

### Funciones — deteccion automatica de gestor

Estas funciones detectan el lockfile del proyecto y usan el gestor correcto: `bun.lockb` → bun, `pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn, `package-lock.json` → npm.

**`pkg <comando>`**
Ejecuta cualquier comando con el gestor detectado. Ejemplo: `pkg add lodash`.

**`pkgi`**
Instala todas las dependencias con el gestor correcto del proyecto.

**`pkgr <script>`**
Ejecuta un script del `package.json` con el gestor correcto.

**`pkgclean`**
Elimina `node_modules/` y reinstala todas las dependencias desde cero.

---

## Tmux

Archivo: `zsh/.config/zsh/aliases/tmux.zsh`

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `tn` | `tmux new -s` | Crear nueva sesion: `tn <nombre>` |
| `ta` | `tmux a` | Conectarse a sesion: `ta <nombre>` |
| `tl` | `tmux ls` | Listar sesiones activas |
| `tk` | `tmux kill-session -t` | Matar sesion: `tk <nombre>` |
| `tks` | `tmux kill-server` | Matar todas las sesiones |

```bash
# Uso tipico
tn proyecto      # Crear sesion "proyecto"
ta proyecto      # Conectarse a "proyecto"
tl               # Ver todas las sesiones activas
tk proyecto      # Terminar sesion "proyecto"
```

---

## Herramientas Modernas

Archivo: `zsh/.config/zsh/aliases/tools.zsh`

Requiere: `eza`, `bat`, `btop`, `tldr`, `fd`, `ripgrep`. Se recomienda una Nerd Font para los iconos.

### eza — listado de archivos

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `ls` | `eza --icons` | Listar con iconos |
| `l` | `eza -l --icons` | Listar en formato detallado |
| `la` | `eza -la --icons` | Listar todo incluidos ocultos |
| `ll` | `eza -l --git --icons` | Listar con estado git |
| `lt` | `eza --tree --level=2` | Vista arbol (2 niveles) |
| `llt` | `eza --tree --level=3` | Vista arbol (3 niveles) |

### bat — visualizacion de archivos

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `cat` | `bat --paging=never` | Mostrar archivo con syntax highlighting |

### Monitor y ayuda

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `top` | `btop` | Monitor de sistema interactivo |
| `monitor` | `btop` | Alias de btop |
| `help` | `tldr` | Paginas de ayuda simplificadas |

### Busqueda

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `grep` | `grep --color=auto` | Grep con colores |
| `ff` | `fd --hidden` | Buscar archivos incluyendo ocultos |
| `rg` | `rg -i` | Ripgrep sin distincion de mayusculas |

### Claude Code

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `clauded` | `set ENABLE_TOOL_SEARCH=true && claude --dangerously-skip-permissions` | Claude Code con busqueda de herramientas habilitada |

---

## Navegacion

Archivo: `zsh/.config/zsh/aliases/navigation.zsh`

### Directorios rapidos

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `..` | `cd ..` | Subir un nivel |
| `...` | `cd ../..` | Subir dos niveles |
| `....` | `cd ../../..` | Subir tres niveles |
| `~` | `cd ~` | Ir al directorio home |

### Zoxide — navegacion inteligente

Zoxide aprende los directorios mas visitados y permite saltar a ellos con fragmentos del nombre.

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `za` | `zi` | Selector interactivo con fzf |
| `zq` | `zoxide query -ls` | Ver base de datos de rutas indexadas |
| `zrm` | `zoxide remove` | Eliminar ruta de la base de datos |

```bash
z docs         # Saltar al directorio mas visitado que contiene "docs"
za             # Abrir selector interactivo
zq             # Ver todas las rutas con puntaje
```

### Operaciones seguras de archivos

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `cp` | `cp -iv` | Copiar con confirmacion y verbose |
| `mv` | `mv -iv` | Mover con confirmacion y verbose |
| `mkdir` | `mkdir -p` | Crear directorio creando padres si hace falta |
| `t` | `touch` | Crear archivo vacio |

---

## Editor

Archivo: `zsh/.config/zsh/aliases/editor.zsh`

### Neovim

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `v` | `nvim` | Abrir Neovim |
| `vim` | `nvim` | Alias de compatibilidad para vim |
| `sv` | `sudo nvim` | Abrir Neovim con privilegios de root |

### Edicion rapida de configuracion

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `zshrc` | `nvim ~/.zshrc` | Editar configuracion de Zsh |
| `tmuxconf` | `nvim ~/.tmux.conf` | Editar configuracion de Tmux |
| `nvimconf` | `cd ~/.config/nvim && nvim .` | Abrir directorio de config de Neovim |

---

## Utilidades

Archivo: `zsh/.config/zsh/aliases/utils.zsh`

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `yz` | `yazi` | Abrir Yazi (explorador de archivos TUI) |
| `c` | `clear` | Limpiar la terminal |
| `e` | `exit` | Cerrar la sesion de terminal |
| `ducks` | `du -sh * \| sort -rh \| head -n 10` | Top 10 archivos/dirs por tamano |
| `myip` | `curl ifconfig.me` | Ver IP publica actual |

---

## Google Cloud (gcloud)

Archivo: `zsh/.config/zsh/aliases/gcloud.zsh`

> Nota: Este archivo define `alias g='gcloud'`, lo que redefine el alias `g='git'` de `git.zsh` segun el orden de carga.

### Autenticacion y configuracion

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `g` | `gcloud` | Comando gcloud base |
| `gauth` | `gcloud auth login` | Autenticar con Google Cloud |
| `gauthlist` | `gcloud auth list` | Listar cuentas autenticadas |
| `grevoke` | `gcloud auth revoke` | Revocar autenticacion |
| `gconfig` | `gcloud config list` | Ver configuracion activa |
| `gconfigs` | `gcloud config configurations list` | Listar configuraciones |
| `gconfigactivate` | `gcloud config configurations activate` | Activar configuracion |
| `gconfigcreate` | `gcloud config configurations create` | Crear configuracion |
| `gproject` | `gcloud config set project` | Establecer proyecto activo |
| `gprojectlist` | `gcloud projects list` | Listar proyectos disponibles |
| `gregion` | `gcloud config set compute/region` | Establecer region por defecto |
| `gzone` | `gcloud config set compute/zone` | Establecer zona por defecto |

### Compute Engine (VMs)

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `gvm` | `gcloud compute instances` | Comando de instancias base |
| `gvmlist` | `gcloud compute instances list` | Listar instancias VM |
| `gvmcreate` | `gcloud compute instances create` | Crear instancia |
| `gvmdelete` | `gcloud compute instances delete` | Eliminar instancia |
| `gvmstart` | `gcloud compute instances start` | Iniciar instancia |
| `gvmstop` | `gcloud compute instances stop` | Detener instancia |
| `gvmreset` | `gcloud compute instances reset` | Resetear instancia |
| `gvmdescribe` | `gcloud compute instances describe` | Describir instancia |
| `gssh` | `gcloud compute ssh` | SSH a instancia |
| `gscp` | `gcloud compute scp` | Copiar archivos a/desde instancia |
| `gmachines` | `gcloud compute machine-types list` | Listar tipos de maquina |
| `gdisks` | `gcloud compute disks list` | Listar discos |

### Kubernetes Engine (GKE)

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `gke` | `gcloud container` | Comando container base |
| `gkelist` | `gcloud container clusters list` | Listar clusters |
| `gkecreate` | `gcloud container clusters create` | Crear cluster |
| `gkedelete` | `gcloud container clusters delete` | Eliminar cluster |
| `gkedescribe` | `gcloud container clusters describe` | Describir cluster |
| `gkeresize` | `gcloud container clusters resize` | Redimensionar cluster |
| `gkecreds` | `gcloud container clusters get-credentials` | Obtener credenciales para kubectl |
| `gkenodes` | `gcloud container node-pools list` | Listar node pools |

### Cloud Run

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `grun` | `gcloud run` | Comando Cloud Run base |
| `grunlist` | `gcloud run services list` | Listar servicios |
| `grundeploy` | `gcloud run deploy` | Desplegar servicio |
| `grundelete` | `gcloud run services delete` | Eliminar servicio |
| `grundescribe` | `gcloud run services describe` | Describir servicio |
| `grunlogs` | `gcloud run services logs read` | Leer logs de servicio |

### Cloud Functions

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `gfunc` | `gcloud functions` | Comando Cloud Functions base |
| `gfunclist` | `gcloud functions list` | Listar funciones |
| `gfuncdeploy` | `gcloud functions deploy` | Desplegar funcion |
| `gfuncdelete` | `gcloud functions delete` | Eliminar funcion |
| `gfuncdescribe` | `gcloud functions describe` | Describir funcion |
| `gfunclogs` | `gcloud functions logs read` | Leer logs de funcion |

### App Engine

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `gapp` | `gcloud app` | Comando App Engine base |
| `gappdeploy` | `gcloud app deploy` | Desplegar aplicacion |
| `gappversions` | `gcloud app versions list` | Listar versiones |
| `gappservices` | `gcloud app services list` | Listar servicios |
| `gappbrowse` | `gcloud app browse` | Abrir app en navegador |
| `gapplogs` | `gcloud app logs tail` | Ver logs en tiempo real |

### Cloud SQL

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `gsql` | `gcloud sql` | Comando Cloud SQL base |
| `gsqllist` | `gcloud sql instances list` | Listar instancias SQL |
| `gsqlcreate` | `gcloud sql instances create` | Crear instancia SQL |
| `gsqldelete` | `gcloud sql instances delete` | Eliminar instancia SQL |
| `gsqldescribe` | `gcloud sql instances describe` | Describir instancia SQL |
| `gsqlconnect` | `gcloud sql connect` | Conectarse a instancia SQL |
| `gsqldbs` | `gcloud sql databases list` | Listar bases de datos |
| `gsqldbcreate` | `gcloud sql databases create` | Crear base de datos |

### Cloud Storage (GCS)

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `gstorage` | `gcloud storage` | Comando storage base |
| `gls` | `gcloud storage ls` | Listar contenido de bucket |
| `gcp` | `gcloud storage cp` | Copiar archivos |
| `gmv` | `gcloud storage mv` | Mover archivos |
| `grm` | `gcloud storage rm` | Eliminar archivos |
| `gmkdir` | `gcloud storage buckets create` | Crear bucket |
| `gbuckets` | `gcloud storage buckets list` | Listar buckets |
| `gbucketdescribe` | `gcloud storage buckets describe` | Describir bucket |

### IAM

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `giam` | `gcloud iam` | Comando IAM base |
| `gserviceaccounts` | `gcloud iam service-accounts list` | Listar service accounts |
| `gsamake` | `gcloud iam service-accounts create` | Crear service account |
| `gsakeys` | `gcloud iam service-accounts keys list` | Listar keys de service account |
| `gsakey` | `gcloud iam service-accounts keys create` | Crear key de service account |
| `groles` | `gcloud iam roles list` | Listar roles disponibles |
| `gpolicy` | `gcloud projects get-iam-policy` | Ver politica IAM del proyecto |

### Cloud Build

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `gbuild` | `gcloud builds` | Comando Cloud Build base |
| `gbuildlist` | `gcloud builds list` | Listar builds |
| `gbuildsubmit` | `gcloud builds submit` | Enviar build |
| `gbuildlogs` | `gcloud builds log` | Ver logs de build |

### Logging y Monitoring

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `glogs` | `gcloud logging` | Comando logging base |
| `glogsread` | `gcloud logging read` | Leer logs |
| `glogstail` | `gcloud logging tail` | Seguir logs en tiempo real |

### Servicios y APIs

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `gservices` | `gcloud services list` | Listar APIs habilitadas |
| `gserviceenable` | `gcloud services enable` | Habilitar API |
| `gservicedisable` | `gcloud services disable` | Deshabilitar API |

### Redes

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `gnetworks` | `gcloud compute networks list` | Listar redes VPC |
| `gsubnets` | `gcloud compute networks subnets list` | Listar subredes |
| `gfirewall` | `gcloud compute firewall-rules list` | Listar reglas de firewall |
| `gfwcreate` | `gcloud compute firewall-rules create` | Crear regla de firewall |
| `gfwdelete` | `gcloud compute firewall-rules delete` | Eliminar regla de firewall |
| `gips` | `gcloud compute addresses list` | Listar IPs reservadas |
| `glbs` | `gcloud compute forwarding-rules list` | Listar load balancers |

### Artifact Registry y Container Registry

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `gar` | `gcloud artifacts` | Comando Artifact Registry base |
| `garlist` | `gcloud artifacts repositories list` | Listar repositorios |
| `garcreate` | `gcloud artifacts repositories create` | Crear repositorio |
| `gcr` | `gcloud container images` | Comando Container Registry base |
| `gcrlist` | `gcloud container images list` | Listar imagenes |

### Informacion general

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `ginfo` | `gcloud info` | Info del entorno gcloud |
| `gversion` | `gcloud version` | Ver version de gcloud |
| `ghelp` | `gcloud help` | Ayuda de gcloud |
| `gcomponents` | `gcloud components list` | Listar componentes instalados |

### Funciones

**`gswitch <project-id>`**
Cambiar el proyecto activo. Sin argumentos, lista los proyectos disponibles.

**`gvmssh <instance-name> [zone]`**
SSH a una instancia VM buscando la zona automaticamente. Sin argumentos, lista las instancias.

**`grunlogs-tail <service-name>`**
Ver los ultimos 50 logs de un servicio Cloud Run. Sin argumentos, lista los servicios.

**`grun-deploy <service-name> <image-url> [region]`**
Desplegar una imagen a Cloud Run con configuracion estandar. Region por defecto: `us-central1`.

**`gcontext`**
Ver la configuracion activa: proyecto, cuenta, region y zona.

**`gresources`**
Listar los recursos principales del proyecto actual: VMs, clusters GKE, servicios Cloud Run y buckets GCS.

**`gcleanup`**
Eliminar todos los recursos del proyecto con confirmacion explicita. Irreversible.

---

## Gitconfig

Archivo: `git/.gitconfig`, seccion `[alias]`. Se usan como `git <alias>`.

### Status y staging

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `s` | `status -sb` | Status corto con nombre de branch |
| `st` | `status` | Status completo |
| `a` | `add` | Agregar archivos al staging |
| `aa` | `add --all` | Agregar todos los cambios |
| `ap` | `add --patch` | Staging interactivo por hunks |

### Commits

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `c` | `commit` | Abrir editor para commit |
| `cm` | `commit -m` | Commit con mensaje en linea |
| `ca` | `commit --amend` | Modificar el ultimo commit |
| `can` | `commit --amend --no-edit` | Modificar ultimo commit sin editar mensaje |

### Branches

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `b` | `branch` | Listar branches locales |
| `ba` | `branch -a` | Listar branches locales y remotas |
| `bd` | `branch -d` | Eliminar branch (requiere merge) |
| `bD` | `branch -D` | Forzar eliminacion de branch |

### Checkout

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `co` | `checkout` | Cambiar de branch o restaurar archivo |
| `cob` | `checkout -b` | Crear branch y hacer checkout |

### Log

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `l` | `log --oneline --graph --decorate` | Log compacto del historial |
| `lg` | `log --oneline --graph --decorate --all` | Log compacto con todas las branches |
| `lgg` | log con formato pretty y colores | Log grafico detallado con autor y fecha |
| `last` | `log -1 HEAD --stat` | Ultimo commit con archivos modificados |
| `tree` | log grafico con formato pretty y `--all` | Vista de arbol del historial completo |
| `contributors` | `shortlog -sn` | Lista de contribuidores por numero de commits |

### Diff

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `d` | `diff` | Diff del working tree |
| `ds` | `diff --staged` | Diff de cambios en staging |
| `dw` | `diff --word-diff` | Diff a nivel de palabras |

### Stash

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `sl` | `stash list` | Listar entradas del stash |
| `ss` | `stash save` | Guardar en stash |
| `sp` | `stash pop` | Aplicar y eliminar ultima entrada |
| `sa` | `stash apply` | Aplicar sin eliminar del stash |

### Reset

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `unstage` | `reset HEAD --` | Quitar archivos del staging |
| `undo` | `reset --soft HEAD^` | Deshacer ultimo commit manteniendo cambios |

### Remotes

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `r` | `remote -v` | Ver remotes con URLs |
| `remotes` | `remote -v` | Ver remotes (nombre alternativo) |

### Push y pull

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `p` | `push` | Push a remote |
| `pl` | `pull` | Pull de remote |
| `pf` | `push --force-with-lease` | Push forzado seguro (falla si hay cambios remotos) |

### Utilidades

| Alias | Expansion | Descripcion |
|-------|-----------|-------------|
| `tags` | `tag -l` | Listar tags |
| `branches` | `branch -a` | Listar todas las branches |
| `cleanup` | elimina branches ya mergeadas | Limpia branches locales integradas en main/master/develop |

---

## Personalizacion

Para agregar aliases propios sin modificar los archivos del repositorio:

- **Aliases de shell adicionales**: crear `~/.config/zsh/aliases/personal.zsh` (se carga automaticamente si el directorio esta en el `fpath`)
- **Aliases de git**: editar la seccion `[alias]` en `git/.gitconfig`
- **Por categoria**: editar el archivo correspondiente en `zsh/.config/zsh/aliases/`

Despues de modificar aliases de shell, recargar la configuracion:

```bash
source ~/.zshrc
```

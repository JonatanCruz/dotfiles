# Aliases - Referencia Completa de Comandos

Esta guía consolida todos los aliases disponibles en este entorno de desarrollo, organizados por herramienta y categoría.

## Índice

1. [Git - Control de Versiones](#git---control-de-versiones)
2. [GitHub CLI - Gestión de Repos](#github-cli---gestión-de-repos)
3. [Docker - Contenedores](#docker---contenedores)
4. [Tmux - Multiplexor de Terminal](#tmux---multiplexor-de-terminal)
5. [Herramientas Modernas](#herramientas-modernas)
6. [Navegación - Directorios](#navegación---directorios)
7. [Aliases de Gitconfig](#aliases-de-gitconfig)

---

## Git - Control de Versiones

### Básicos

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `g` | `git` | Comando git base |
| `lg` | `lazygit` | Abrir LazyGit (interfaz TUI) |

### Estado y Log

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `gs` | `git status -s` | Estado corto |
| `gst` | `git status` | Estado completo |
| `gl` | `git log --oneline --graph --decorate --all` | Log gráfico compacto |

### Staging y Commits

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `ga` | `git add` | Agregar archivos |
| `gaa` | `git add -A` | Agregar todos los cambios |
| `gc` | `git commit -m` | Commit con mensaje |
| `gca` | `git commit -am` | Commit con add y mensaje |

### Push y Pull

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `gp` | `git push` | Push a remote |
| `gpl` | `git pull` | Pull de remote |

### Branches

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `gco` | `git checkout` | Cambiar de branch |
| `gcb` | `git checkout -b` | Crear y cambiar a branch |
| `gb` | `git branch` | Listar branches |

---

## GitHub CLI - Gestión de Repos

### Autenticación

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `ghauth` | `gh auth login` | Login a GitHub |
| `ghauthstatus` | `gh auth status` | Ver estado de auth |
| `ghauthlogout` | `gh auth logout` | Logout de GitHub |
| `ghauthtoken` | `gh auth token` | Ver token de acceso |

### Repositorios

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `ghrepolist` | `gh repo list` | Listar repos |
| `ghrepoview` | `gh repo view` | Ver info de repo |
| `ghrepoweb` | `gh repo view --web` | Abrir repo en navegador |
| `ghrepocreate` | `gh repo create` | Crear nuevo repo |
| `ghrepoclone` | `gh repo clone` | Clonar repo |
| `ghb` | `gh browse` | Abrir repo actual en web |

### Pull Requests

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `ghprlist` | `gh pr list` | Listar PRs |
| `ghprview` | `gh pr view` | Ver PR |
| `ghprweb` | `gh pr view --web` | Abrir PR en web |
| `ghprcreate` | `gh pr create` | Crear PR |
| `ghprcheckout` | `gh pr checkout` | Checkout de PR |
| `ghprmerge` | `gh pr merge` | Mergear PR |
| `ghprs` | `gh pr list` | Alias corto de list |
| `ghprc` | `gh pr create` | Alias corto de create |
| `ghprm` | `gh pr merge` | Alias corto de merge |

### Issues

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `ghissuelist` | `gh issue list` | Listar issues |
| `ghissueview` | `gh issue view` | Ver issue |
| `ghissuecreate` | `gh issue create` | Crear issue |
| `ghissueclose` | `gh issue close` | Cerrar issue |
| `ghis` | `gh issue list` | Alias corto de list |
| `ghic` | `gh issue create` | Alias corto de create |

### Workflows y Actions

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `ghworkflow` | `gh workflow` | Comando workflow base |
| `ghworkflowlist` | `gh workflow list` | Listar workflows |
| `ghworkflowrun` | `gh workflow run` | Ejecutar workflow |
| `ghrunlist` | `gh run list` | Listar runs |
| `ghrunview` | `gh run view` | Ver run |
| `ghrunwatch` | `gh run watch` | Seguir run en tiempo real |
| `ghw` | `gh workflow list` | Alias corto |
| `ghr` | `gh run list` | Alias corto |

### Funciones Útiles

**`ghpr-quick '<título>' [descripción]`**
Crear PR rápido con título y descripción opcional.

**`ghissue-quick '<título>' [descripción]`**
Crear issue rápido con título y descripción opcional.

**`ghstatus`**
Ver estado completo del repositorio (info, PRs, issues, actions).

**`ghpr-co <pr-number>`**
Checkout de PR por número.

**`ghpr-squash <pr-number>`**
Mergear PR con squash y eliminar branch.

**`ghpr-approve <pr-number> [comentario]`**
Aprobar PR con comentario opcional.

**`ghclone <repo> [usuario]`**
Clonar repositorio rápidamente.

**`ghme`**
Ver información del perfil de usuario actual.

---

## Docker - Contenedores

### Docker Básico

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `d` | `docker` | Comando docker base |
| `di` | `docker images` | Listar imágenes |
| `dps` | `docker ps` | Listar contenedores activos |
| `dpsa` | `docker ps -a` | Listar todos los contenedores |
| `drm` | `docker rm` | Eliminar contenedor |
| `drmi` | `docker rmi` | Eliminar imagen |
| `dexec` | `docker exec -it` | Ejecutar comando en contenedor |
| `dlogs` | `docker logs -f` | Ver logs en tiempo real |

### Build y Run

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `dbuild` | `docker build` | Build imagen |
| `drun` | `docker run` | Ejecutar contenedor |
| `dstop` | `docker stop` | Detener contenedor |
| `dstart` | `docker start` | Iniciar contenedor |
| `drestart` | `docker restart` | Reiniciar contenedor |

### Limpieza

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `dprune` | `docker system prune -a --volumes` | Limpieza completa |
| `dpruneimg` | `docker image prune -a` | Limpiar imágenes |
| `dprunecont` | `docker container prune` | Limpiar contenedores |
| `dprunevol` | `docker volume prune` | Limpiar volúmenes |
| `dprunenet` | `docker network prune` | Limpiar redes |

### Docker Compose

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `dc` | `docker compose` | Comando compose base |
| `dcu` | `docker compose up` | Levantar servicios |
| `dcud` | `docker compose up -d` | Levantar servicios (detached) |
| `dcd` | `docker compose down` | Bajar servicios |
| `dcb` | `docker compose build` | Build servicios |
| `dcr` | `docker compose restart` | Reiniciar servicios |
| `dcl` | `docker compose logs -f` | Ver logs en tiempo real |
| `dcp` | `docker compose ps` | Ver estado de servicios |
| `dcexec` | `docker compose exec` | Ejecutar comando en servicio |

### Network y Volumes

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `dnet` | `docker network ls` | Listar redes |
| `dnetrm` | `docker network rm` | Eliminar red |
| `dnetinspect` | `docker network inspect` | Inspeccionar red |
| `dvol` | `docker volume ls` | Listar volúmenes |
| `dvolrm` | `docker volume rm` | Eliminar volumen |
| `dvolinspect` | `docker volume inspect` | Inspeccionar volumen |

### Stats y Info

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `dstats` | `docker stats` | Ver uso de recursos |
| `dinfo` | `docker info` | Info del sistema Docker |
| `dversion` | `docker version` | Ver versión |

### Funciones Útiles

**`dstopall`**
Detener todos los contenedores activos.

**`drmall`**
Eliminar todos los contenedores.

**`drmiall`**
Eliminar todas las imágenes.

**`dsh <contenedor>`**
Entrar a shell bash del contenedor.

**`dshell <contenedor>`**
Entrar a shell sh del contenedor.

**`dlog <contenedor>`**
Ver logs en tiempo real de un contenedor.

**`dcleanall`**
Limpieza completa de Docker con confirmación (contenedores, imágenes, volúmenes, redes).

---

## Tmux - Multiplexor de Terminal

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `tn` | `tmux new -s` | Crear nueva sesión: `tn <nombre>` |
| `ta` | `tmux a` | Conectarse a sesión: `ta <nombre>` |
| `tl` | `tmux ls` | Listar sesiones activas |
| `tk` | `tmux kill-session -t` | Matar sesión: `tk <nombre>` |
| `tks` | `tmux kill-server` | Matar todas las sesiones |

**Ejemplo de uso:**
```bash
tn proyecto      # Crear sesión "proyecto"
ta proyecto      # Conectarse a "proyecto"
tl               # Ver todas las sesiones
tk proyecto      # Matar sesión "proyecto"
```

---

## Herramientas Modernas

### Eza (reemplazo de ls)

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `ls` | `eza --icons` | Listar con iconos |
| `l` | `eza -l --icons` | Listar detallado |
| `la` | `eza -la --icons` | Listar todo (incluye ocultos) |
| `ll` | `eza -l --git --icons` | Listar con info git |
| `lt` | `eza --tree --level=2` | Árbol (2 niveles) |
| `llt` | `eza --tree --level=3` | Árbol (3 niveles) |

### Bat (reemplazo de cat)

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `cat` | `bat --paging=never` | Mostrar archivos con syntax highlight |

### Monitor y Ayuda

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `top` | `btop` | Monitor de sistema mejorado |
| `monitor` | `btop` | Alias de btop |
| `help` | `tldr` | Ayuda rápida de comandos |

### Búsqueda

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `grep` | `grep --color=auto` | Grep con colores |
| `ff` | `fd --hidden` | Find file con fd (incluye ocultos) |
| `rg` | `rg -i` | Ripgrep case-insensitive |

### Claude Code

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `clauded` | `set ENABLE_TOOL_SEARCH=true && claude --dangerously-skip-permissions` | Claude Code con búsqueda habilitada |

---

## Navegación - Directorios

### Navegación Rápida

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `..` | `cd ..` | Subir un nivel |
| `...` | `cd ../..` | Subir dos niveles |
| `....` | `cd ../../..` | Subir tres niveles |
| `~` | `cd ~` | Ir a home |

### Zoxide (cd inteligente)

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `za` | `zi` | Zoxide interactivo (con fzf) |
| `zq` | `zoxide query -ls` | Ver base de datos de rutas |
| `zrm` | `zoxide remove` | Eliminar ruta de BD |

**Uso de Zoxide:**
```bash
z docs         # Saltar a directorio más visitado que contiene "docs"
za             # Selector interactivo con fzf
zq             # Ver todas las rutas indexadas
```

### Operaciones Seguras

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `cp` | `cp -iv` | Copiar con confirmación y verbose |
| `mv` | `mv -iv` | Mover con confirmación y verbose |
| `mkdir` | `mkdir -p` | Crear directorios (crea padres) |
| `t` | `touch` | Crear archivo vacío |

---

## Aliases de Gitconfig

Los siguientes aliases están definidos en `.gitconfig` y se usan con `git <alias>`.

### Status y Add

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `s` | `status -sb` | Status corto con branch |
| `st` | `status` | Status completo |
| `a` | `add` | Add archivos |
| `aa` | `add --all` | Add todos los cambios |
| `ap` | `add --patch` | Add interactivo por hunks |

### Commit

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `c` | `commit` | Commit |
| `cm` | `commit -m` | Commit con mensaje |
| `ca` | `commit --amend` | Amend último commit |
| `can` | `commit --amend --no-edit` | Amend sin editar mensaje |

### Branch

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `b` | `branch` | Listar branches |
| `ba` | `branch -a` | Listar todas (incluye remotas) |
| `bd` | `branch -d` | Eliminar branch |
| `bD` | `branch -D` | Forzar eliminar branch |

### Checkout

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `co` | `checkout` | Checkout |
| `cob` | `checkout -b` | Crear y checkout branch |

### Log

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `l` | `log --oneline --graph --decorate` | Log compacto |
| `lg` | `log --oneline --graph --decorate --all` | Log gráfico completo |
| `lgg` | Log con formato detallado y colores | Formato pretty |
| `last` | `log -1 HEAD --stat` | Último commit con stats |
| `tree` | Log gráfico completo con formato pretty | Árbol visual |
| `contributors` | `shortlog -sn` | Lista de contribuidores |

### Diff

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `d` | `diff` | Diff de working tree |
| `ds` | `diff --staged` | Diff de staged changes |
| `dw` | `diff --word-diff` | Diff por palabras |

### Stash

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `sl` | `stash list` | Listar stashes |
| `ss` | `stash save` | Guardar stash |
| `sp` | `stash pop` | Aplicar y eliminar stash |
| `sa` | `stash apply` | Aplicar stash (sin eliminar) |

### Reset

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `unstage` | `reset HEAD --` | Quitar de staging |
| `undo` | `reset --soft HEAD^` | Deshacer último commit (mantiene cambios) |

### Remote

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `r` | `remote -v` | Ver remotes |
| `remotes` | `remote -v` | Ver remotes |

### Push/Pull

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `p` | `push` | Push a remote |
| `pl` | `pull` | Pull de remote |
| `pf` | `push --force-with-lease` | Push forzado seguro |

### Limpieza

| Alias | Comando | Descripción |
|-------|---------|-------------|
| `cleanup` | Limpia branches mergeadas | Elimina branches ya integradas |
| `tags` | `tag -l` | Listar tags |
| `branches` | `branch -a` | Listar todas las branches |

---

## Tips de Uso

### Combinaciones Útiles

```bash
# Git workflow rápido
gs              # Ver estado
gaa             # Agregar todo
gc "mensaje"    # Commit
gp              # Push

# Docker workflow
dcud            # Levantar compose en background
dcl             # Ver logs
dcd             # Bajar servicios

# Navegación eficiente
z proyectos     # Saltar a carpeta proyectos
ll              # Ver archivos con info git
lt              # Ver estructura de árbol

# GitHub CLI workflow
ghprc           # Crear PR
ghprlist        # Ver PRs
ghb             # Abrir repo en web

# Tmux workflow
tn dev          # Crear sesión dev
ta dev          # Conectarse a dev
tl              # Ver sesiones
```

### Aliases más usados

**Top 10 comandos más útiles:**
1. `gs` - Ver estado de git rápidamente
2. `gaa` - Agregar todos los cambios
3. `gc "mensaje"` - Commit rápido
4. `z <carpeta>` - Saltar a directorio
5. `ll` - Listar archivos con info git
6. `dcud` - Levantar docker compose
7. `lg` - LazyGit (interfaz TUI para git)
8. `ta <sesión>` - Conectar a tmux
9. `ghb` - Abrir repo en navegador
10. `cat <archivo>` - Ver archivo con syntax highlighting

---

## Personalización

Para agregar tus propios aliases:

1. **Git aliases** → Edita `~/.gitconfig` sección `[alias]`
2. **Zsh aliases** → Crea/edita `~/.config/zsh/aliases/personal.zsh`
3. **GitHub CLI** → Edita `~/.config/zsh/aliases/gh.zsh`
4. **Docker** → Edita `~/.config/zsh/aliases/docker.zsh`

Después de agregar aliases, recarga Zsh:
```bash
source ~/.config/zsh/.zshrc
```

---

## Recursos Adicionales

- [Git Aliases Documentation](https://git-scm.com/book/en/v2/Git-Basics-Git-Aliases)
- [GitHub CLI Manual](https://cli.github.com/manual/)
- [Docker CLI Reference](https://docs.docker.com/engine/reference/commandline/cli/)
- [Tmux Cheatsheet](https://tmuxcheatsheet.com/)
- [Eza Documentation](https://github.com/eza-community/eza)
- [Bat Documentation](https://github.com/sharkdp/bat)
- [Zoxide Documentation](https://github.com/ajeetdsouza/zoxide)

---

**Última actualización**: 2026-01-06

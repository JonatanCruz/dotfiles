# Docker - Completion y Configuración

Configuración de Docker con completions para Zsh y aliases útiles para desarrollo.

## Características Principales

- **🔧 Zsh Completion**: Autocompletado inteligente de comandos Docker
- **⚡ Aliases Rápidos**: Comandos cortos para operaciones comunes
- **🎨 Integración Shell**: Funciona perfectamente con Zsh y Starship
- **📦 Docker Compose**: Completion completo para docker-compose

## Completion Setup

### Instalación de Completion

El completion de Docker se instala automáticamente con GNU Stow:

```bash
# Aplicar configuración
stow docker

# Esto crea symlink:
# ~/.zsh/completions/_docker -> ~/dotfiles/docker/.zsh/completions/_docker
```

### Verificación

```bash
# Verificar que el completion está cargado
echo $fpath | grep docker

# Testear completion (presiona Tab)
docker <Tab>
# Debería mostrar comandos disponibles: run, ps, images, etc.
```

## Aliases Disponibles

Los aliases de Docker están definidos en `zsh/.config/zsh/aliases/docker.zsh` y se cargan automáticamente:

### Comandos Docker Básicos
```bash
# Ver contenedores activos
dps          # docker ps

# Ver todos los contenedores (incluidos detenidos)
dpsa         # docker ps -a

# Ver imágenes
di           # docker images

# Ver logs
dlogs        # docker logs
dlogsf       # docker logs -f (seguir logs en tiempo real)
```

### Docker Compose
```bash
# Levantar servicios
dc           # docker-compose
dcu          # docker-compose up
dcud         # docker-compose up -d (background)

# Detener servicios
dcd          # docker-compose down
dcdr         # docker-compose down --remove-orphans

# Ver logs de compose
dcl          # docker-compose logs
dclf         # docker-compose logs -f (seguir logs)

# Ejecutar comandos en contenedor
dce          # docker-compose exec
dcr          # docker-compose run

# Rebuild
dcb          # docker-compose build
dcub         # docker-compose up --build
```

### Gestión de Contenedores
```bash
# Parar contenedor
dstop        # docker stop

# Eliminar contenedor
drm          # docker rm
drmf         # docker rm -f (forzar)

# Eliminar todos los contenedores detenidos
dprune       # docker container prune -f
```

### Gestión de Imágenes
```bash
# Eliminar imagen
drmi         # docker rmi
drmif        # docker rmi -f (forzar)

# Limpiar imágenes sin usar
diprune      # docker image prune -a -f
```

### Gestión de Volúmenes
```bash
# Ver volúmenes
dvls         # docker volume ls

# Eliminar volumen
dvrm         # docker volume rm

# Limpiar volúmenes sin usar
dvprune      # docker volume prune -f
```

### Limpieza Completa
```bash
# Limpiar todo el sistema Docker
dsystem      # docker system prune -a -f --volumes
```

## Workflows Comunes

### Workflow 1: Desarrollo con Docker Compose

```bash
# 1. Levantar stack de desarrollo
dcud    # docker-compose up -d

# 2. Ver logs de un servicio específico
dclf api    # Seguir logs del servicio 'api'

# 3. Ejecutar comando en contenedor
dce api npm test    # Ejecutar tests en contenedor 'api'

# 4. Rebuild después de cambios
dcub    # docker-compose up --build

# 5. Detener todo
dcd     # docker-compose down
```

### Workflow 2: Debugging de Contenedor

```bash
# 1. Ver contenedores activos
dps

# 2. Ver logs de contenedor específico
dlogsf <container-name>

# 3. Ejecutar shell en contenedor
docker exec -it <container-name> /bin/sh

# 4. Ver procesos del contenedor
docker top <container-name>

# 5. Ver stats de recursos
docker stats <container-name>
```

### Workflow 3: Limpieza de Sistema

```bash
# 1. Ver espacio usado
docker system df

# 2. Eliminar contenedores detenidos
dprune

# 3. Eliminar imágenes sin usar
diprune

# 4. Eliminar volúmenes sin usar
dvprune

# 5. Limpieza completa (CUIDADO: elimina todo)
dsystem
```

### Workflow 4: Actualizar Imagen

```bash
# 1. Parar contenedor
dstop <container-name>

# 2. Eliminar contenedor
drm <container-name>

# 3. Pull nueva versión de imagen
docker pull <image:tag>

# 4. Recrear contenedor
docker run ...    # o dcu si usas docker-compose
```

## Integración con Otras Herramientas

### Zsh + Docker Completion

El completion de Docker en Zsh proporciona:

**Autocompletado inteligente**:
- Nombres de contenedores en comandos como `docker stop`, `docker logs`
- Nombres de imágenes en `docker run`, `docker rmi`
- Flags y opciones de cada comando
- Servicios de docker-compose

**Ejemplo**:
```bash
docker logs <Tab>
# Muestra lista de contenedores activos:
# app-backend-1    app-frontend-1    postgres-1
```

### Starship Prompt + Docker Context

Starship puede mostrar el contexto de Docker activo:

```toml
# En starship.toml
[docker_context]
format = " [$symbol$context]($style) "
symbol = "🐳 "
```

### Neovim Terminal

Ejecutar comandos Docker desde terminal de Neovim:

```vim
# Abrir terminal
:terminal

# Ejecutar comando Docker con alias
dps
dlogsf api
```

## Completion Avanzado

### Docker Run Options

El completion sugiere opciones comunes:

```bash
docker run <Tab>
# Muestra:
# -d    Detached mode
# -p    Publish port
# -v    Mount volume
# -e    Environment variable
# --name    Container name
# --rm    Remove after exit
```

### Docker Compose Services

```bash
dce <Tab>
# Muestra servicios definidos en docker-compose.yml:
# api    frontend    postgres    redis
```

### Image Tags

```bash
docker run nginx:<Tab>
# Muestra tags disponibles (si están cacheados):
# latest    alpine    1.21    1.21-alpine
```

## Solución de Problemas

### Completion no funciona

```bash
# Verificar que completion está instalado
ls ~/.zsh/completions/_docker
# Debería existir

# Recargar completions de Zsh
rm ~/.zcompdump
exec zsh

# Verificar que está en fpath
echo $fpath | grep completions
```

### Aliases no se cargan

```bash
# Verificar que aliases están definidos
cat ~/.config/zsh/aliases/docker.zsh

# Verificar que se están cargando en .zshrc
grep "docker.zsh" ~/.config/zsh/.zshrc

# Recargar shell
source ~/.config/zsh/.zshrc
```

### Permission Denied en comandos Docker

```bash
# Agregar usuario al grupo docker (Linux)
sudo usermod -aG docker $USER

# Aplicar cambios (logout/login o)
newgrp docker

# Verificar
docker ps    # No debería requerir sudo
```

### Docker Compose no encontrado

```bash
# Verificar instalación
which docker-compose

# Instalar si falta (Linux)
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verificar versión
docker-compose --version
```

## Tips Pro

### 1. Alias con Funciones de Zsh

Crear aliases más complejos en `~/.config/zsh/aliases/docker.zsh`:

```bash
# Parar y eliminar contenedor en un comando
function drmf() {
  docker stop "$1" && docker rm "$1"
}

# Logs de último contenedor creado
function dlast() {
  docker logs -f $(docker ps -lq)
}

# Entrar al último contenedor
function dex() {
  docker exec -it $(docker ps -lq) /bin/sh
}
```

### 2. Docker System Info

```bash
# Ver información completa del sistema Docker
docker system df -v

# Ver eventos en tiempo real
docker events
```

### 3. Inspect Containers

```bash
# Ver configuración completa
docker inspect <container-name>

# Extraer IP del contenedor
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container-name>

# Extraer variables de entorno
docker inspect -f '{{.Config.Env}}' <container-name>
```

### 4. Filtros en Docker PS

```bash
# Ver solo contenedores con status específico
docker ps -a --filter "status=exited"

# Ver contenedores de imagen específica
docker ps --filter "ancestor=nginx"
```

### 5. Docker Compose Override

```bash
# Usar archivo override local (no commiteado)
dcu -f docker-compose.yml -f docker-compose.override.yml
```

## Comandos Útiles

```bash
# Ver versión de Docker
docker --version

# Ver info del sistema Docker
docker info

# Ver espacio usado por Docker
docker system df

# Ver redes
docker network ls

# Crear red
docker network create my-network

# Ver volúmenes
docker volume ls

# Crear volumen
docker volume create my-volume
```

## Comparación: Con vs Sin Aliases

| Comando Completo | Alias | Ahorro |
|-----------------|-------|--------|
| `docker ps` | `dps` | 7 caracteres |
| `docker-compose up -d` | `dcud` | 14 caracteres |
| `docker logs -f` | `dlogsf` | 8 caracteres |
| `docker-compose down --remove-orphans` | `dcdr` | 30 caracteres |
| `docker system prune -a -f --volumes` | `dsystem` | 27 caracteres |

## Recursos Adicionales

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Hub](https://hub.docker.com/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

## Referencias

- [Docker CLI Reference](https://docs.docker.com/engine/reference/commandline/cli/)
- [Docker Compose CLI Reference](https://docs.docker.com/compose/reference/)
- [Zsh Completion System](https://github.com/zsh-users/zsh-completions)

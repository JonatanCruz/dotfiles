# ==============================================================================
# DOCKER - Aliases para Docker y Docker Compose
# ==============================================================================

# Docker básico
alias d='docker'
alias di='docker images'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias drm='docker rm'
alias drmi='docker rmi'
alias dexec='docker exec -it'
alias dlogs='docker logs -f'
alias dinspect='docker inspect'

# Docker build y run
alias dbuild='docker build'
alias drun='docker run'
alias dstop='docker stop'
alias dstart='docker start'
alias drestart='docker restart'

# Docker limpieza
alias dprune='docker system prune -a --volumes'
alias dpruneimg='docker image prune -a'
alias dprunecont='docker container prune'
alias dprunevol='docker volume prune'
alias dprunenet='docker network prune'

# Docker Compose
alias dc='docker compose'
alias dcu='docker compose up'
alias dcud='docker compose up -d'
alias dcd='docker compose down'
alias dcb='docker compose build'
alias dcr='docker compose restart'
alias dcl='docker compose logs -f'
alias dcp='docker compose ps'
alias dcexec='docker compose exec'

# Docker network
alias dnet='docker network ls'
alias dnetrm='docker network rm'
alias dnetinspect='docker network inspect'

# Docker volumes
alias dvol='docker volume ls'
alias dvolrm='docker volume rm'
alias dvolinspect='docker volume inspect'

# Docker stats y información
alias dstats='docker stats'
alias dinfo='docker info'
alias dversion='docker version'

# Funciones útiles
# Detener todos los contenedores
dstopall() {
    docker stop $(docker ps -q)
}

# Eliminar todos los contenedores
drmall() {
    docker rm $(docker ps -a -q)
}

# Eliminar todas las imágenes
drmiall() {
    docker rmi $(docker images -q)
}

# Entrar a un contenedor (shell bash)
dsh() {
    docker exec -it "$1" /bin/bash
}

# Entrar a un contenedor (shell sh)
dshell() {
    docker exec -it "$1" /bin/sh
}

# Ver logs de un contenedor
dlog() {
    docker logs -f "$1"
}

# Limpiar todo (contenedores, imágenes, volúmenes, redes)
dcleanall() {
    echo "⚠️  Esto eliminará TODOS los contenedores, imágenes, volúmenes y redes no utilizados"
    read "?¿Continuar? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker system prune -a --volumes -f
        echo "✓ Limpieza completa realizada"
    fi
}

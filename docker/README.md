# Docker Configuration

Archivo de autocompletado para Docker en Zsh.

## Estructura

```
docker/
└── .docker/
    └── completions/
        └── _docker      # Script de completion oficial de Docker
```

## Instalación

### 1. Aplicar con Stow

```bash
cd ~/dotfiles
stow docker
```

Esto creará un symlink: `~/.docker -> ~/dotfiles/docker/.docker`

### 2. Recargar Zsh

```bash
source ~/.zshrc
# o
exec zsh
```

## Características

- **Autocompletado inteligente**: Presiona Tab después de comandos Docker
- **Option-stacking**: Autocompletado mejorado para opciones de comandos
- **Comandos soportados**: docker, docker compose, y todos los subcomandos

## Uso

```bash
docker <Tab>              # Ver todos los comandos disponibles
docker run <Tab>          # Autocompletar opciones de 'run'
docker compose <Tab>      # Ver comandos de compose
```

## Actualizar Completion

Si Docker actualiza sus comandos, regenera el archivo:

```bash
docker completion zsh > ~/dotfiles/docker/.docker/completions/_docker
git add docker/.docker/completions/_docker
git commit -m "chore(docker): Actualizar completion de Docker"
```

## Aliases de Docker

Los aliases de Docker están configurados en el paquete **zsh** en:
- `zsh/.config/zsh/aliases/docker.zsh`

Ver el README de zsh para la lista completa de aliases disponibles.

## Desinstalar

```bash
cd ~/dotfiles
stow -D docker
```

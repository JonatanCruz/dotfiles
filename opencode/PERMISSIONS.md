# OpenCode Permissions Configuration

## Configuración para Servidor Remoto

Esta configuración está optimizada para ejecutar OpenCode en un servidor remoto con **mínimos permisos requeridos**, permitiendo que los modelos trabajen de forma autónoma sin interrupciones constantes.

## Resumen de Permisos

### ✅ AUTOMÁTICO (Sin confirmación)

#### Operaciones de Archivos
- **Lectura**: Todos los archivos (excepto archivos sensibles)
- **Escritura**: Crear nuevos archivos
- **Edición**: Modificar archivos existentes
- **Búsqueda**: glob, grep, list

#### Comandos Git Seguros
- `git status`
- `git diff`
- `git log`
- `git branch`
- `git add`
- `git commit`
- `git push` (normal, no force)
- `git pull`
- `git fetch`

#### Package Managers (Instalación/Ejecución)
- `npm install`
- `npm run`
- `npm test`
- `yarn install`
- `pnpm install`

#### Docker (Consulta/Ejecución)
- `docker ps`
- `docker logs`
- `docker exec`

#### Herramientas
- Task management (todoread, todowrite)
- Web fetching

### ⚠️ REQUIERE CONFIRMACIÓN

#### Comandos Destructivos de Archivos
- `rm` (cualquier variante)
- `rm -f`
- `rm -r`
- `rm -rf`
- `rmdir`
- `unlink`
- `shred`
- `dd`

#### Git Destructivo
- `git push --force`
- `git push -f`
- `git reset --hard`
- `git clean -fd`
- `git branch -D`

#### Sistema
- `sudo` (cualquier comando)
- `chmod -R`
- `chown -R`

#### Package Managers (Publicación)
- `npm publish`
- `yarn publish`
- `pnpm publish`

#### Docker Destructivo
- `docker rm`
- `docker rmi`
- `docker system prune`
- `docker volume rm`

### 🚫 BLOQUEADO (Denegado)

#### Archivos Sensibles
- `*.env` (todos los archivos de entorno)
- `.env*`
- `*.key` (claves privadas)
- `*.pem` (certificados)
- `*.crt` (certificados)
- `*.p12`, `*.pfx` (certificados)
- `id_rsa*` (claves SSH)
- `id_ed25519` (claves SSH)
- `*.asc`, `*.gpg` (claves GPG)
- `credentials*`
- `secrets*`

**Excepción**: `*.env.example` y `.env.example` están permitidos

## Ventajas de Esta Configuración

1. **Autonomía**: Los modelos pueden leer, escribir y editar código sin interrupciones
2. **Seguridad**: Comandos destructivos requieren confirmación explícita
3. **Protección**: Archivos sensibles están completamente bloqueados
4. **Productividad**: Operaciones comunes de desarrollo son automáticas
5. **Control**: Operaciones críticas (rm, force push, sudo) requieren aprobación

## Uso Recomendado

### Para desarrollo normal:
```bash
opencode
# El modelo puede:
# - Leer cualquier archivo del proyecto
# - Crear/editar archivos
# - Ejecutar git add/commit/push
# - Instalar dependencias
# - Ejecutar tests
```

### Para operaciones destructivas:
```bash
# El modelo pedirá confirmación para:
# - Borrar archivos
# - Force push
# - Comandos sudo
# - Publicar paquetes
```

## Personalización

Para ajustar permisos, edita:
```bash
~/.config/opencode/opencode.json
```

O en el repositorio de dotfiles:
```bash
~/dotfiles/opencode/.config/opencode/opencode.json
```

Luego aplica con Stow:
```bash
cd ~/dotfiles
stow -R opencode
```

## Verificación

Para verificar que la configuración está activa:
```bash
cat ~/.config/opencode/opencode.json | grep -A 5 "PERMISSIONS"
```

Deberías ver:
```
// PERMISSIONS - MINIMAL PROMPTS FOR REMOTE SERVER
```

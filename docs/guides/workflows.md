# Workflows - Flujos de Trabajo Comunes

Guía de workflows prácticos para maximizar productividad con este entorno.

## Índice

- [Workflow 1: Desarrollo Web Full-Stack](#workflow-1-desarrollo-web-full-stack)
- [Workflow 2: Navegación Eficiente de Código](#workflow-2-navegación-eficiente-de-código)
- [Workflow 3: Gestión Avanzada de Sesiones Tmux](#workflow-3-gestión-avanzada-de-sesiones-tmux)
- [Workflow 4: Git Workflow Profesional](#workflow-4-git-workflow-profesional)
- [Workflow 5: Debugging y Análisis de Logs](#workflow-5-debugging-y-análisis-de-logs)
- [Workflow 6: Docker Development](#workflow-6-docker-development)
- [Integración vim-tmux-navigator](#integración-vim-tmux-navigator)

---

## Workflow 1: Desarrollo Web Full-Stack

**Escenario**: Desarrollar una aplicación web (frontend + backend + base de datos)

### Setup Inicial

```bash
# 1. Crear sesión Tmux para el proyecto
tmux new -s fullstack-app

# 2. Navegar al proyecto
cd ~/proyectos/mi-app

# 3. Abrir Neovim en el proyecto
nvim .
```

### Layout de Tmux Recomendado

```
┌──────────────────────────┬──────────────────────────┐
│                          │                          │
│   Panel 1: Neovim        │   Panel 2: Terminal      │
│   (Editor principal)     │   (Git, comandos, tests) │
│                          │                          │
│                          │                          │
├──────────────────────────┴──────────────────────────┤
│   Panel 3: Backend Server                           │
│   (npm run dev / python manage.py runserver)        │
├─────────────────────────────────────────────────────┤
│   Panel 4: Frontend Server                          │
│   (npm run start / vite dev)                        │
└─────────────────────────────────────────────────────┘
```

**Crear Layout**:
```bash
# En Tmux, desde panel inicial:
Ctrl+s + |       # Split vertical (crea Panel 2)
Ctrl+s + j       # Moverse a panel izquierdo
Ctrl+s + -       # Split horizontal (crea Panel 3)
Ctrl+s + -       # Split horizontal de nuevo (crea Panel 4)
```

### Workflow Típico

**Panel 1 (Neovim)**:
```bash
# Navegar a componente frontend
Space + ff → escribir "UserProfile" → Enter

# Ver estructura del proyecto
Space + e  # Toggle nvim-tree

# Editar componente
# Uso intensivo de LSP:
K          # Ver documentación de función
gd         # Ir a definición de componente importado
Space + rn # Renombrar variable en todo el proyecto

# Guardar cambios
Space + w
```

**Panel 2 (Terminal para Git y Comandos)**:
```bash
# Ver cambios
gst  # Alias de git status

# Ver diff con Delta
git d  # Alias de git diff (visualización side-by-side)

# Ejecutar tests
npm test

# Ver logs de base de datos
docker logs postgres-container -f
```

**Panel 3 (Backend Server)**:
```bash
# Iniciar servidor backend
npm run dev

# O para Python:
python manage.py runserver

# O para Docker:
docker-compose up backend
```

**Panel 4 (Frontend Server)**:
```bash
# Iniciar servidor frontend
npm start

# O Vite:
npm run dev

# O Next.js:
npm run dev
```

### Uso de LazyGit Integrado

Desde Panel 1 (Neovim):
```vim
Space + gg    " Abrir LazyGit en ventana flotante
```

**En LazyGit**:
- `j/k` - Navegar archivos modificados
- `Space` - Stage/unstage archivo
- `c` - Commit (abre editor de mensaje)
- `P` - Push a remote
- `p` - Pull from remote
- `x` - Ver menú completo de comandos
- `q` - Cerrar LazyGit

### Navegación Seamless entre Paneles

**Crítico**: Usa vim-tmux-navigator para navegar sin pensar:

```bash
Ctrl+h  # Ir a panel izquierdo (funciona en Neovim splits Y Tmux panes)
Ctrl+j  # Ir a panel abajo
Ctrl+k  # Ir a panel arriba
Ctrl+l  # Ir a panel derecho
```

**Ejemplo de flujo**:
1. Estás editando en Neovim (Panel 1)
2. `Ctrl+l` → Saltas a Terminal (Panel 2)
3. Ejecutas `npm test`
4. `Ctrl+j` → Saltas a Backend logs (Panel 3)
5. Ves error en logs
6. `Ctrl+k` → Vuelves a Neovim (Panel 1)
7. Arreglas el error
8. `Ctrl+l` + `Ctrl+j` → Tests de nuevo

### Guardar y Restaurar Sesión

```bash
# Guardar sesión (antes de cerrar laptop)
Ctrl+s + Ctrl+s

# Detach de sesión
Ctrl+s + d

# Restaurar sesión (después de reinicio)
tmux attach -t fullstack-app
# Los paneles, directorios y procesos se restauran automáticamente
```

---

## Workflow 2: Navegación Eficiente de Código

**Escenario**: Entender un codebase grande y navegar rápido entre archivos

### Exploración Inicial

```bash
# 1. Abrir proyecto en Neovim
nvim .

# 2. Ver estructura del proyecto
Space + e  # Abrir nvim-tree

# 3. Búsqueda fuzzy de archivos
Space + ff
# Empieza a escribir nombre del archivo
# Usa Ctrl+n/Ctrl+p para navegar resultados
# Enter para abrir
```

### Búsqueda de Código

```bash
# Buscar texto en todo el proyecto (live grep)
Space + fg
# Escribir término de búsqueda
# Ver preview en tiempo real
# Enter para saltar al archivo

# Buscar en buffers abiertos
Space + fb

# Buscar en historial de archivos recientes
Space + fo
```

### Uso Intensivo de LSP

```vim
" Desde Neovim, estando en un símbolo:

K           " Hover documentation (ver tipo y docs del símbolo)
gd          " Go to definition (saltar a definición)
gr          " Go to references (ver todos los usos del símbolo)
gi          " Go to implementation (para interfaces)

Space + rn  " Rename symbol en todo el proyecto
Space + ca  " Code actions (imports automáticos, refactorings)
Space + d   " Ver todos los diagnósticos del proyecto

]d          " Siguiente diagnóstico (error/warning)
[d          " Diagnóstico anterior
```

### Navegación por Symbols

```vim
" Buscar símbolos en archivo actual
Space + fs

" Buscar símbolos en todo el proyecto
Space + fw

" Saltar a función/clase rápido:
" 1. Space + fs
" 2. Escribir nombre de función
" 3. Enter
```

### Workflow con Yazi para Contexto

```bash
# 1. Abrir Yazi para ver estructura completa
yazi

# Navegación rápida:
h/j/k/l   # Movimiento Vim-style
Enter     # Abrir archivo en Neovim

# 2. Ver preview de archivos sin abrirlos
# (Yazi muestra preview automático en panel derecho)

# 3. Abrir múltiples archivos:
Space     # Seleccionar archivo 1
j         # Bajar
Space     # Seleccionar archivo 2
Enter     # Abrir todos en Neovim (multiple buffers)

# 4. Quit con CD al directorio
Q

# 5. Abrir Neovim desde directorio correcto
nvim
```

### Marks y Jumps en Neovim

```vim
" Crear marks para volver rápido a ubicaciones:
ma          " Crear mark 'a' en línea actual

" Saltar a marks:
'a          " Saltar a línea del mark 'a'
`a          " Saltar a columna exacta del mark 'a'

" Ver lista de marks:
:marks

" Jumplist (historial de saltos):
Ctrl+o      " Saltar a ubicación anterior
Ctrl+i      " Saltar a ubicación siguiente

" Changelist (historial de cambios):
g;          " Ir a cambio anterior
g,          " Ir a cambio siguiente
```

---

## Workflow 3: Gestión Avanzada de Sesiones Tmux

**Escenario**: Trabajar en múltiples proyectos simultáneamente con contexto separado

### Estrategia Multi-Proyecto

```bash
# Crear sesiones por proyecto
tmux new -s proyecto-a
# ... trabajar en proyecto-a ...
Ctrl+s + d  # Detach

tmux new -s proyecto-b
# ... trabajar en proyecto-b ...
Ctrl+s + d  # Detach

tmux new -s hotfix-prod
# ... hotfix urgente ...
Ctrl+s + d  # Detach

# Listar todas las sesiones
tmux ls
```

### SessionX: Fuzzy Finder de Sesiones

```bash
# Desde dentro de Tmux:
Ctrl+s + o

# Se abre fuzzy finder con preview de todas las sesiones
# j/k para navegar
# Enter para cambiar a sesión
# Ctrl+d para matar sesión (sin cambiar)
```

### Workflow por Tipo de Proyecto

#### Proyecto Web (3 paneles)
```bash
tmux new -s web-app
# Layout: Editor + Terminal + Server
Ctrl+s + |    # Split vertical
Ctrl+s + j + -    # Split horizontal en panel derecho
```

#### Proyecto Backend (4 paneles)
```bash
tmux new -s backend-api
# Layout: Editor + Terminal + Server + Logs
Ctrl+s + |    # Split vertical
Ctrl+s + j + -    # Split 1
Ctrl+s + j + -    # Split 2
```

#### Proyecto DevOps (2 paneles)
```bash
tmux new -s devops
# Layout: Editor + Terminal (wide)
Ctrl+s + -    # Split horizontal
```

### Persistencia Automática con Resurrect + Continuum

**Configuración automática**:
- Tmux guarda tu sesión cada 15 minutos
- Si tu computadora se reinicia, restaura automáticamente al abrir Tmux

**Comandos manuales**:
```bash
# Guardar sesión manualmente
Ctrl+s + Ctrl+s

# Restaurar sesión manualmente
Ctrl+s + Ctrl+r
```

**Qué se guarda**:
- Paneles y su layout
- Directorios de trabajo
- Comandos en ejecución (vim, nvim, node, etc.)
- Variables de entorno

### Ventanas (Tabs) en Tmux

```bash
# Crear nueva ventana (tab)
Ctrl+s + c

# Renombrar ventana
Ctrl+s + ,
# Escribir nuevo nombre → Enter

# Cambiar entre ventanas
Ctrl+s + n    # Siguiente ventana
Ctrl+s + p    # Ventana anterior
Ctrl+s + [0-9]    # Ventana específica

# Ver lista de ventanas
Ctrl+s + w
# Navegar con j/k → Enter para seleccionar

# Layout sugerido por tipo de ventana:
# - Ventana 1: "editor" (Neovim + terminal)
# - Ventana 2: "servers" (backend + frontend)
# - Ventana 3: "docker" (docker-compose logs)
# - Ventana 4: "monitoring" (htop, logs, etc.)
```

---

## Workflow 4: Git Workflow Profesional

**Escenario**: Trabajo en feature branch con commits atómicos y code reviews

### Feature Branch Workflow

```bash
# 1. Verificar rama actual y estado
gst    # Alias de git status

# 2. Crear feature branch
git cob feature/nueva-funcionalidad
# Alias de: git checkout -b feature/nueva-funcionalidad

# 3. Trabajar en código (Neovim)
nvim

# 4. Ver cambios con Delta (diff hermoso)
git d    # Alias de git diff
# Side-by-side con syntax highlighting
# Navegar con n/N entre cambios

# 5. Agregar cambios
git aa    # Alias de git add --all
# O agregar específicos:
git a src/components/NewFeature.js

# 6. Ver staged changes
git ds    # Alias de git diff --staged

# 7. Commit atómico con mensaje descriptivo
git cm "feat: agregar nueva funcionalidad de autenticación"
# Alias de: git commit -m

# 8. Push (auto-configura remote si no existe)
git p    # Alias de git push
```

### LazyGit Workflow (Más Visual)

```bash
# Desde Neovim:
Space + gg

# O desde terminal:
lazygit
```

**Workflow en LazyGit**:
1. **Files Panel** (panel izquierdo):
   - `j/k` - Navegar archivos modificados
   - `Space` - Stage/unstage archivo
   - `a` - Stage todos los archivos
   - `d` - Ver diff del archivo (panel derecho)

2. **Staging**:
   - `Tab` - Cambiar entre "Files" y "Staged Files"
   - `Enter` en archivo - Ver chunks para stage parcial
   - `Space` en chunk - Stage solo ese chunk

3. **Commit**:
   - `c` - Abrir editor de commit message
   - Escribir mensaje → Guardar y cerrar
   - Commit aparece en "Commits" panel

4. **Push/Pull**:
   - `P` (Shift+p) - Push
   - `p` - Pull
   - `f` - Fetch

5. **Branches**:
   - `[` - Ver panel de branches
   - `n` - Crear nueva branch
   - `Space` - Checkout a branch
   - `m` - Merge branch

6. **Log Visual**:
   - Ver commits con graph visual
   - `Enter` en commit - Ver files changed
   - `d` en commit - Ver full diff

### Resolver Conflictos con nvimdiff

```bash
# 1. Pull/merge genera conflicto
git pl    # Alias de git pull
# CONFLICT (content): Merge conflict in src/auth.js

# 2. Abrir merge tool
git mergetool

# 3. Neovim se abre con 3 paneles + panel de resultado:
# ┌────────────┬────────────┬────────────┐
# │   LOCAL    │   BASE     │   REMOTE   │
# │  (tuyo)    │ (ancestro) │  (remoto)  │
# ├────────────┴────────────┴────────────┤
# │           MERGED (resultado)         │
# └──────────────────────────────────────┘
```

**Comandos en nvimdiff**:
```vim
:diffget LOCAL     " Aceptar cambio de LOCAL (panel izquierdo)
:diffget REMOTE    " Aceptar cambio de REMOTE (panel derecho)

]c                 " Siguiente conflicto
[c                 " Conflicto anterior

:wqa               " Guardar y salir de todos los buffers
```

**Después de resolver**:
```bash
# 4. Commit merge
git cm "merge: resolver conflictos en auth.js"

# 5. Push
git p
```

### Workflow de Code Review

```bash
# 1. Ver log visual del feature branch
git tree
# Alias que muestra graph completo con colores

# 2. Ver diff de feature branch vs main
git d main..feature/mi-feature

# 3. Ver solo archivos modificados
git d --name-only main..feature/mi-feature

# 4. Ver último commit con stats
git last
# Alias que muestra: commit + diff + stats

# 5. Amend último commit (si olvidaste algo)
git can
# Alias de: git commit --amend --no-edit
```

---

## Workflow 5: Debugging y Análisis de Logs

**Escenario**: Investigar un bug en aplicación running

### Setup de Debugging

```bash
# Crear sesión dedicada
tmux new -s debugging

# Layout sugerido:
# ┌──────────────────────┬──────────────────────┐
# │  Neovim (código)     │  Logs (tail -f)      │
# ├──────────────────────┴──────────────────────┤
# │  Terminal (comandos, grep, búsqueda)        │
# └─────────────────────────────────────────────┘

Ctrl+s + |    # Split vertical
Ctrl+s + j + -    # Split horizontal en panel izquierdo
```

### Panel 1: Neovim con Búsqueda

```vim
" Buscar función que causa error
Space + fg
" Escribir nombre de función → Enter

" Agregar prints/logs estratégicos
" Guardar con Space + w
```

### Panel 2: Logs en Tiempo Real

```bash
# Ver logs de aplicación
tail -f logs/app.log

# O logs de Docker
docker logs -f container-name

# O logs de servicio systemd
journalctl -fu service-name

# Filtrar logs con grep:
tail -f logs/app.log | grep ERROR
tail -f logs/app.log | grep "user_id: 123"
```

### Panel 3: Comandos de Investigación

```bash
# Buscar en archivos de código
rg "function_name" --type js

# Ver historial de cambios de archivo problemático
git log --oneline -- src/auth.js

# Ver diff de commit específico
git show 7a3f2e1

# Buscar en Docker
docker ps -a | grep api
docker inspect api-container
docker exec -it api-container /bin/sh
```

### Workflow de Análisis

1. **Reproducir Error**:
   ```bash
   # En Panel 3:
   curl -X POST http://localhost:3000/api/login \
     -H "Content-Type: application/json" \
     -d '{"email": "test@example.com", "password": "wrong"}'
   ```

2. **Ver Logs en Tiempo Real** (Panel 2):
   - Observar stack trace
   - Identificar línea de error

3. **Saltar a Código** (Panel 1):
   ```vim
   " Usar navegación para ir a línea específica
   :123    " Ir a línea 123

   " O buscar función
   /function_name
   ```

4. **Agregar Debugging**:
   ```javascript
   // En Panel 1 (Neovim):
   console.log('DEBUG: user:', user);
   console.log('DEBUG: password:', password);
   ```

5. **Guardar y Reiniciar Servidor**:
   ```bash
   " En Neovim:
   Space + w    " Guardar

   " En Panel 3:
   Ctrl+c    " Matar servidor
   npm run dev    " Reiniciar
   ```

6. **Reproducir de Nuevo** (Panel 3):
   - Ver nuevos logs en Panel 2
   - Identificar causa raíz

7. **Fix en Código** (Panel 1)

8. **Commit Fix**:
   ```bash
   Space + gg    " LazyGit desde Neovim
   # Stage → Commit → Push
   ```

---

## Workflow 6: Docker Development

**Escenario**: Desarrollo con Docker Compose (múltiples servicios)

### Setup Inicial

```bash
# Estructura de proyecto:
# proyecto/
#   ├── docker-compose.yml
#   ├── backend/
#   ├── frontend/
#   └── database/

# Crear sesión Tmux
tmux new -s docker-dev

# Layout:
# ┌────────────────┬────────────────┐
# │  Neovim        │  Docker logs   │
# ├────────────────┴────────────────┤
# │  Terminal (docker commands)     │
# └─────────────────────────────────┘

Ctrl+s + |
Ctrl+s + j + -
```

### Panel 1: Neovim (Código)

```bash
nvim .
```

### Panel 2: Docker Logs

```bash
# Ver logs de todos los servicios
dcl    # Alias de docker-compose logs

# Seguir logs en tiempo real
dclf   # Alias de docker-compose logs -f

# Logs de servicio específico
dclf backend
dclf frontend
dclf postgres
```

### Panel 3: Docker Commands

**Levantar Stack**:
```bash
# Levantar servicios en background
dcud   # Alias de docker-compose up -d

# Ver servicios corriendo
dps    # Alias de docker ps

# Ver todos los contenedores (incluidos detenidos)
dpsa   # Alias de docker ps -a
```

**Ejecutar Comandos en Contenedores**:
```bash
# Ejecutar comando en contenedor corriendo
dce backend npm test
# Alias de: docker-compose exec backend npm test

# Ejecutar bash en contenedor
dce backend /bin/sh

# Correr migrations
dce backend python manage.py migrate

# Ver logs de base de datos
dce postgres psql -U user -d database
```

**Rebuild y Restart**:
```bash
# Rebuild imagen y levantar
dcub   # Alias de docker-compose up --build

# Rebuild solo
dcb    # Alias de docker-compose build

# Restart servicio específico
docker-compose restart backend
```

**Limpieza**:
```bash
# Detener y eliminar contenedores
dcd    # Alias de docker-compose down

# Detener y eliminar con volúmenes
docker-compose down -v

# Limpiar contenedores detenidos
dprune   # Alias de docker container prune -f

# Limpiar imágenes sin usar
diprune  # Alias de docker image prune -a -f

# Limpieza completa del sistema Docker
dsystem  # Alias de docker system prune -a -f --volumes
```

### Workflow Típico

1. **Hacer cambios en código** (Panel 1 - Neovim)
   ```vim
   " Editar backend/src/api.js
   Space + w    " Guardar
   ```

2. **Ver impacto en logs** (Panel 2 - automáticamente actualizado si hot-reload está activo)

3. **Si requiere rebuild** (Panel 3):
   ```bash
   dcb backend    # Rebuild solo backend
   docker-compose restart backend    # Restart
   ```

4. **Testear cambios** (Panel 3):
   ```bash
   curl http://localhost:3000/api/health

   # O ejecutar tests dentro del contenedor
   dce backend npm test
   ```

5. **Ver logs detallados si hay error** (Panel 2):
   ```bash
   dclf backend | grep ERROR
   ```

6. **Troubleshooting**:
   ```bash
   # Ver configuración de contenedor
   docker inspect backend-container

   # Ver variables de entorno
   dce backend env

   # Ver networking
   docker network ls
   docker network inspect project_default
   ```

---

## Integración vim-tmux-navigator

**Filosofía**: Navegación seamless entre Neovim splits y Tmux panes sin pensar

### Cómo Funciona

vim-tmux-navigator intercepta `Ctrl+h/j/k/l`:
- Si estás en un **split de Neovim** y hay otro split en esa dirección → navega entre splits de Neovim
- Si estás en el **borde de Neovim** y hay un pane de Tmux → navega a ese pane de Tmux
- Si estás en un **pane de Tmux** normal (sin Neovim) → navega entre panes de Tmux

### Ejemplo Práctico

Imagina este layout:

```
┌──────────────────┬──────────────────┐
│   Neovim         │                  │
│  ┌──────┬──────┐ │   Tmux Pane 2    │
│  │Split1│Split2│ │   (terminal)     │
│  │      │      │ │                  │
│  └──────┴──────┘ │                  │
├──────────────────┴──────────────────┤
│   Tmux Pane 3 (logs)                │
└─────────────────────────────────────┘
```

**Navegación**:
1. Cursor en **Neovim Split1**
2. `Ctrl+l` → Salta a **Neovim Split2** (mismo pane de Tmux)
3. `Ctrl+l` → Salta a **Tmux Pane 2** (porque ya no hay más splits de Neovim a la derecha)
4. `Ctrl+h` → Vuelve a **Neovim Split2**
5. `Ctrl+j` → Salta a **Tmux Pane 3** (abajo)
6. `Ctrl+k` → Vuelve a **Neovim**

### Configuración Avanzada

Si quieres deshabilitar en modo INSERT de Neovim (opcional):
```lua
-- En ~/.config/nvim/lua/config/keymaps.lua
-- Deshabilitar vim-tmux-navigator en modo INSERT
vim.keymap.set('i', '<C-h>', '<C-h>', { noremap = true })
vim.keymap.set('i', '<C-j>', '<C-j>', { noremap = true })
vim.keymap.set('i', '<C-k>', '<C-k>', { noremap = true })
vim.keymap.set('i', '<C-l>', '<C-l>', { noremap = true })
```

---

## Tips Pro para Workflows

### 1. Tmux Copy Mode para Copiar Output

```bash
# Entrar a copy mode
Ctrl+s + [

# Navegar con Vim keys
j/k    # Arriba/abajo
h/l    # Izquierda/derecha

# Buscar
/texto → Enter    # Buscar hacia adelante
?texto → Enter    # Buscar hacia atrás
n    # Siguiente match
N    # Match anterior

# Seleccionar texto
Space    # Comenzar selección
v        # Modo visual
Enter    # Copiar selección

# Pegar
Ctrl+s + ]
```

### 2. Zoom Temporal de Panel

```bash
# Zoom panel actual (pantalla completa temporal)
Ctrl+s + z

# Volver a layout normal
Ctrl+s + z  (de nuevo)

# Útil para:
# - Leer logs complejos
# - Editar código sin distracciones
# - Ver tabla grande en terminal
```

### 3. Sincronizar Paneles

```bash
# Activar sincronización de paneles (escribir en todos a la vez)
Ctrl+s + :
setw synchronize-panes on

# Útil para:
# - Ejecutar mismo comando en múltiples servidores
# - Configurar múltiples contenedores idénticos

# Desactivar
Ctrl+s + :
setw synchronize-panes off
```

### 4. Quick Switch entre Proyectos

```bash
# Desde cualquier sesión Tmux:
Ctrl+s + o    # Abre SessionX

# Fuzzy search de sesiones con preview
# Enter para cambiar
# Ctrl+d para matar sesión
```

### 5. Workflow de "Pomodoro" con Tmux

```bash
# Crear sesión de trabajo
tmux new -s work-sprint

# Crear sesión de break
tmux new -s break
# ... abrir algo relajante (música, news, etc.) ...

# Switch rápido:
Ctrl+s + o → seleccionar "work-sprint"    # Trabajar 25 min
Ctrl+s + o → seleccionar "break"          # Break 5 min
```

---

## Recursos Adicionales

- [Keybindings Reference](keybindings.md) - Atajos completos
- [Customization Guide](customization.md) - Personalizar workflows
- [Service Documentation](../services/) - Docs de cada herramienta
- [Tmux Documentation](../services/tmux.md) - Tmux avanzado
- [Neovim Documentation](../services/nvim.md) - Neovim plugins
- [Git Workflows](../services/git.md) - Git con Delta

---

**Filosofía de Workflows**: Maximizar productividad con navegación Vim-style, layouts consistentes y automatización inteligente.

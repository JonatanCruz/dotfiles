# Tmux Workflows Avanzados

Workflows y técnicas avanzadas para maximizar productividad con Tmux, SessionX, Resurrect y navegación Vim.

## Índice

- [Session Management Avanzado](#session-management-avanzado)
- [Layouts y Organizaciones](#layouts-y-organizaciones)
- [SessionX con Zoxide](#sessionx-con-zoxide)
- [Persistencia con Resurrect + Continuum](#persistencia-con-resurrect--continuum)
- [Integración con Neovim](#integración-con-neovim)
- [Thumbs para Copia Rápida](#thumbs-para-copia-rápida)
- [Automatización con Scripts](#automatización-con-scripts)

## Session Management Avanzado

### SessionX: Gestión Moderna de Sesiones

SessionX combina FZF con Zoxide para gestión inteligente de sesiones.

**Workflow básico:**

```bash
# 1. Abrir SessionX
Prefix + s

# 2. Buscar proyecto
# SessionX muestra:
# - Sesiones existentes de Tmux
# - Directorios frecuentes (vía Zoxide)
# - Busca por nombre o path

# 3. Navegación
# Ctrl+n / Ctrl+p → Siguiente/anterior
# Enter → Crear/cambiar a sesión
# Esc → Cancelar
```

**Ventajas sobre métodos tradicionales:**

| Comando | Limitaciones | SessionX |
|---------|--------------|----------|
| `tmux ls` | Lista texto plana | Preview interactivo |
| `tmux attach -t nombre` | Requiere nombre exacto | Búsqueda fuzzy |
| `Prefix + w` | Solo sesiones existentes | También muestra directorios |
| Scripts custom | Configuración manual | Integra Zoxide automáticamente |

**Indexar proyectos en Zoxide:**

```bash
# Navega a tus proyectos para indexarlos
cd ~/proyectos/dotfiles
cd ~/proyectos/web-app
cd ~/proyectos/backend-api

# Verificar base de datos
zoxide query -ls

# Ahora SessionX encuentra estos proyectos
Prefix + s
# Escribe: "dot" → muestra dotfiles
```

### Estrategias de Naming

**Convenciones recomendadas:**

```bash
# ✅ Nombres descriptivos cortos
web-app
api-backend
dotfiles
testing

# ❌ Nombres genéricos
work
dev
tmp
test123
```

**Por qué importa:**
- SessionX busca por nombre
- FZF hace fuzzy matching
- Nombres claros → encuentras sesiones más rápido

**Renombrar sesión:**

```bash
Prefix + $
# Escribe nuevo nombre
# Enter para confirmar
```

### Multi-Session Workflows

**Escenario: Desarrollo full-stack**

```bash
# Sesión 1: Frontend
Prefix + s → "web-frontend"
# Layout: Editor + Dev server + Tests

# Sesión 2: Backend
Prefix + s → "api-backend"
# Layout: Editor + Server + Database logs

# Sesión 3: DevOps
Prefix + s → "infrastructure"
# Layout: Terraform + Docker + Kubernetes

# Cambiar entre sesiones
Prefix + s → Buscar "web" o "api"
# O usar tmux ls y attach
```

**Ventajas:**
- Contextos separados por proyecto
- No mezclar logs de frontend con backend
- Persistencia individual por sesión
- Más fácil cerrar/abrir proyectos específicos

## Layouts y Organizaciones

### Layouts Predefinidos

Tmux incluye 5 layouts automáticos:

```bash
# Ciclar entre layouts
Prefix + Space

# Layouts disponibles:
# 1. even-horizontal: Panes horizontales iguales
# 2. even-vertical: Panes verticales iguales
# 3. main-horizontal: 1 pane grande arriba
# 4. main-vertical: 1 pane grande a la izquierda
# 5. tiled: Grid balanceado
```

### Layout: Desarrollo Full-Stack

**Organización recomendada:**

```
┌──────────────────────┬──────────────────────┐
│                      │                      │
│    Neovim Editor     │   Dev Server         │
│    (código)          │   (npm run dev)      │
│                      │                      │
│                      │                      │
├──────────────────────┴──────────────────────┤
│                                             │
│    Terminal / Git / Comandos                │
│                                             │
└─────────────────────────────────────────────┘
```

**Comandos para crear:**

```bash
# 1. Abrir Tmux
tmux

# 2. Split vertical
Prefix + v

# 3. Navegar a derecha
Ctrl + l

# 4. Split horizontal en pane derecho
Prefix + h

# 5. Navegar a pane inferior izquierdo
Ctrl + j
Ctrl + h

# Resultado: Layout perfecto para desarrollo
```

**Ajustar tamaños:**

```bash
# Resize con Alt + hjkl (hold para repetir)
Alt + h  # Más estrecho
Alt + l  # Más ancho
Alt + j  # Más alto
Alt + k  # Más bajo

# O con Prefix
Prefix + H  # Resize izquierda (hold)
Prefix + L  # Resize derecha
```

### Layout: Backend + Database

```
┌─────────────────────┬────────────────────┐
│                     │                    │
│   Neovim (API)      │  Database Client   │
│                     │  (psql/mongo)      │
│                     │                    │
├─────────────────────┼────────────────────┤
│                     │                    │
│   Server Logs       │  API Tests         │
│   (npm start)       │  (npm test)        │
│                     │                    │
└─────────────────────┴────────────────────┘
```

**Crear este layout:**

```bash
# 1. Pane inicial → Neovim
nvim

# 2. Split vertical → Database
Prefix + v
psql -U usuario database

# 3. Ir a Neovim
Ctrl + h

# 4. Split horizontal → Server
Prefix + h
npm start

# 5. Ir a Database
Ctrl + l

# 6. Split horizontal → Tests
Prefix + h
npm test

# Layout completo
```

### Layout: DevOps Monitoring

```
┌─────────────────────────────────────────┐
│           System Monitor                │
│           (htop/ctop)                   │
├──────────────┬─────────────┬────────────┤
│              │             │            │
│  Docker      │  Terraform  │  kubectl   │
│  Compose     │  apply      │  logs      │
│              │             │            │
└──────────────┴─────────────┴────────────┘
```

### Zoom Mode (Fullscreen Toggle)

```bash
# Maximizar pane actual (toggle)
Prefix + m

# Casos de uso:
# - Leer logs completos
# - Editar archivo grande en Neovim
# - Ver output de test largo
# - Presentar código sin distracciones
```

## SessionX con Zoxide

### Flujo de Trabajo Inteligente

**Escenario: Empezar el día**

```bash
# 1. Abrir terminal
# 2. Iniciar Tmux
tmux

# 3. Abrir SessionX
Prefix + s

# 4. Buscar proyecto del día
# Escribe: "web"
# SessionX muestra:
# - Sesión "web-frontend" (existente)
# - ~/proyectos/web-app (directorio frecuente)
# - ~/clientes/web-dashboard

# 5. Enter en "web-frontend"
# - Si existe: Cambia a esa sesión
# - Si no existe: Crea sesión nueva en ese directorio
```

**Integración con Zoxide:**

Zoxide registra automáticamente directorios que visitas. SessionX usa esta información.

```bash
# Ejemplo de índice de Zoxide
$ zoxide query -ls

1000  ~/proyectos/dotfiles
800   ~/proyectos/web-app
600   ~/proyectos/api-backend
400   ~/clientes/ecommerce

# Frecuencia basada en uso real
# SessionX prioriza directorios frecuentes
```

### Preview y Navegación

**Features de SessionX:**

- **Preview pane**: Muestra contenido del directorio
- **Syntax highlighting**: Archivos con color
- **Git status**: Indica si es repositorio Git
- **Keybindings FZF**: Ctrl+n/p para navegar

**Crear sesiones rápidas:**

```bash
# Desde SessionX
Prefix + s

# Escribe nombre nuevo
nueva-sesion

# SessionX pregunta directorio
# Enter → crea sesión en directorio actual
# O buscar otro directorio
```

## Persistencia con Resurrect + Continuum

### Resurrect: Guardar/Restaurar Sesiones

**Auto-save configurado:**

Continuum guarda automáticamente cada 15 minutos.

**Guardar manualmente:**

```bash
Prefix + Ctrl+s
# Output: "Tmux environment saved!"
```

**Restaurar sesión:**

```bash
# Al abrir tmux de nuevo
tmux

# Restaurar última sesión
Prefix + Ctrl+r
# Output: "Tmux restore complete!"
```

**Qué se guarda:**

- ✅ Sesiones y sus nombres
- ✅ Ventanas y sus nombres
- ✅ Panes y sus layouts
- ✅ Directorio de trabajo de cada pane
- ✅ Procesos corriendo (vim, menos, man, etc.)
- ❌ Procesos background (npm run, servers)
- ❌ Estado interno de programas

### Continuum: Auto-Save

**Configuración actual:**

```bash
# Auto-save cada 15 minutos
set -g @continuum-save-interval '15'

# Restaurar al iniciar tmux
set -g @continuum-restore 'on'
```

**Verificar estado:**

```bash
# Ver última vez guardado
echo ~/.tmux/resurrect/

# Ver archivos de restore
ls -lh ~/.tmux/resurrect/
```

**Casos de uso:**

1. **Cierre inesperado**: Laptop sin batería, crash del sistema
2. **Reinicio**: Actualización de OS, reboot
3. **Cambio de contexto**: Fin del día → siguiente día retomar

### Workflow de Persistencia

**Fin del día:**

```bash
# 1. Guardar manualmente (opcional)
Prefix + Ctrl+s

# 2. Cerrar terminal normalmente
# Continuum ya guardó en últimos 15 min

# 3. Apagar laptop/desktop
```

**Inicio del siguiente día:**

```bash
# 1. Abrir terminal
# 2. Iniciar tmux
tmux

# 3. Todo restaurado automáticamente:
# - Sesiones con nombres
# - Layouts intactos
# - Directorios de trabajo
# - Neovim reabierto (si estaba corriendo)
```

### Limitaciones y Soluciones

**Procesos no se restauran:**

```bash
# ❌ Dev servers no se reinician
# ❌ npm run dev, python server, etc.

# ✅ Solución: Usar scripts
# Crear script de startup por proyecto
```

**Ejemplo de script de proyecto:**

```bash
# ~/proyectos/web-app/tmux-start.sh
#!/bin/bash

# Ventana 1: Editor
tmux new-window -n "editor" -c ~/proyectos/web-app
tmux send-keys -t "editor" "nvim" Enter

# Ventana 2: Dev server
tmux new-window -n "dev" -c ~/proyectos/web-app
tmux send-keys -t "dev" "npm run dev" Enter

# Ventana 3: Tests
tmux new-window -n "tests" -c ~/proyectos/web-app
tmux send-keys -t "tests" "npm run test:watch" Enter
```

**Uso:**

```bash
chmod +x ~/proyectos/web-app/tmux-start.sh
tmux
bash ~/proyectos/web-app/tmux-start.sh
```

## Integración con Neovim

### Vim-Tmux-Navigator

**Navegación seamless:**

```bash
# Mismo keymap funciona en:
# - Splits de Neovim
# - Panes de Tmux

Ctrl + h  # Izquierda (Neovim split O tmux pane)
Ctrl + j  # Abajo
Ctrl + k  # Arriba
Ctrl + l  # Derecha

# El plugin detecta automáticamente el contexto
```

**Casos de uso:**

1. **Editor + Terminal**: Neovim a la izquierda, terminal a la derecha
   - `Ctrl + l` para ir al terminal
   - `Ctrl + h` para volver a Neovim

2. **Splits de Neovim dentro de Tmux**: Navegación coherente
   - No necesitas recordar atajos diferentes

3. **Workflows complejos**: Editor con múltiples splits + múltiples panes de tmux

### LazyGit Integrado

**Desde Neovim:**

```vim
" Abrir LazyGit en ventana flotante
<leader>gg

" LazyGit se abre:
" - Como pane flotante de tmux
" - Sin perder contexto de Neovim
" - q para cerrar y volver
```

**Workflow Git:**

```bash
# 1. Editando en Neovim
# 2. Modificaste varios archivos
# 3. Presiona <leader>gg
# 4. LazyGit abre:
#    - Ver cambios
#    - Stage files
#    - Commit
#    - Push
# 5. Presiona q
# 6. De vuelta en Neovim
```

### Auto-Hide Tmux Status Bar

**Configuración automática:**

```bash
# Al entrar a Neovim:
# - Status bar de tmux se oculta
# - Más espacio vertical

# Al salir de Neovim:
# - Status bar se restaura
```

**Manual toggle:**

```bash
# Ocultar/mostrar status bar
Prefix + \

# Casos de uso:
# - Presentaciones
# - Screenshots
# - Leer logs largos
# - Más espacio vertical
```

### Yazi Integration

**File manager desde Neovim/Tmux:**

```bash
# En un pane de Tmux
yazi

# Navegación Vim-style:
# h → Directorio padre
# j/k → Arriba/abajo
# l → Abrir carpeta/archivo

# Integra con Neovim:
# Enter en archivo .lua → abre en Neovim
```

## Thumbs para Copia Rápida

### Copiar Texto sin Mouse

**Activación:**

```bash
Prefix + Space
```

**Workflow:**

```bash
# 1. Estás viendo output con URLs o paths
# Ejemplo:
# Error in file: /home/usuario/proyectos/app/src/utils/auth.js:42
# See docs: https://example.com/api/authentication

# 2. Activar Thumbs
Prefix + Space

# 3. Thumbs marca texto:
# [a] /home/usuario/proyectos/app/src/utils/auth.js:42
# [b] https://example.com/api/authentication

# 4. Presionar letra
# Presiona 'a' → path copiado al clipboard
# Presiona 'b' → URL copiada

# 5. Pegar donde necesites
Ctrl + Shift + V  # En terminal
```

**Casos de uso:**

1. **Copiar paths de errores**:
```bash
Error: ENOENT: /var/log/app/error.log
# Thumbs → copiar path → nvim [paste]
```

2. **Copiar URLs de logs**:
```bash
API Response: https://api.example.com/v1/users/123
# Thumbs → copiar → curl [paste]
```

3. **Copiar hashes de Git**:
```bash
commit a3f8d92 (HEAD -> main)
# Thumbs → copiar hash → git show [paste]
```

4. **Copiar comandos largos del historial**:
```bash
docker run -d -p 3000:3000 --name app ...
# Thumbs → copiar comando → editar y ejecutar
```

### Configuración de Hints

**Caracteres de hints:**

```bash
# Configuración actual: alfabeto
a b c d e f g h i j k l m n ...

# Ventajas:
# - Una tecla por hint
# - Rápido para copiar
# - No necesita confirmación
```

## Copy Mode Avanzado

### Navegación y Búsqueda

**Entrar a Copy Mode:**

```bash
Prefix + [
```

**Navegación Vim-style:**

```bash
# Movimiento básico
h j k l        # Izquierda, abajo, arriba, derecha

# Movimiento de palabra
w              # Palabra siguiente
b              # Palabra anterior

# Líneas
0              # Inicio de línea
$              # Fin de línea

# Pantalla
Ctrl + f       # Página siguiente
Ctrl + b       # Página anterior

# Archivo
gg             # Inicio del historial
G              # Final del historial
```

**Búsqueda:**

```bash
# Buscar hacia adelante
/texto
n              # Siguiente match
N              # Match anterior

# Buscar hacia atrás
?texto
```

**Seleccionar y copiar:**

```bash
# 1. Navegar a inicio del texto
# 2. Presionar Space (iniciar selección)
# 3. Mover para seleccionar
# 4. Presionar Enter (copiar)

# Selección de línea
V              # Modo visual de línea
Enter          # Copiar línea(s)

# Copiar directamente al clipboard
y              # Copiar selección al clipboard del sistema
```

**Workflow: Copiar logs**

```bash
# 1. Servidor generó error largo
# 2. Entrar a copy mode
Prefix + [

# 3. Buscar inicio del error
/ERROR

# 4. Seleccionar desde ahí
Space

# 5. Navegar al final del stack trace
10j  # Bajar 10 líneas

# 6. Copiar
y    # Copia al clipboard

# 7. Salir
q

# 8. Pegar en editor o ticket
Ctrl + Shift + V
```

## Automatización con Scripts

### Script: Crear Proyecto

```bash
#!/bin/bash
# ~/scripts/tmux-new-project.sh

PROJECT_NAME=$1
PROJECT_DIR=~/proyectos/$PROJECT_NAME

# Crear directorio
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Crear sesión con layout
tmux new-session -d -s $PROJECT_NAME -c $PROJECT_DIR

# Ventana 1: Editor
tmux rename-window -t $PROJECT_NAME:1 "editor"
tmux send-keys -t $PROJECT_NAME:1 "nvim" Enter

# Ventana 2: Terminal
tmux new-window -t $PROJECT_NAME:2 -n "terminal" -c $PROJECT_DIR

# Ventana 3: Git
tmux new-window -t $PROJECT_NAME:3 -n "git" -c $PROJECT_DIR
tmux send-keys -t $PROJECT_NAME:3 "lazygit" Enter

# Adjuntar a sesión
tmux attach-session -t $PROJECT_NAME
```

**Uso:**

```bash
chmod +x ~/scripts/tmux-new-project.sh
~/scripts/tmux-new-project.sh mi-nuevo-proyecto
```

### Script: Layout Dev Full-Stack

```bash
#!/bin/bash
# ~/scripts/tmux-dev-layout.sh

SESSION_NAME=${1:-dev}

# Crear sesión
tmux new-session -d -s $SESSION_NAME

# Layout complejo
tmux split-window -h -t $SESSION_NAME
tmux split-window -v -t $SESSION_NAME:1.2
tmux select-pane -t $SESSION_NAME:1.1

# Comandos por pane
tmux send-keys -t $SESSION_NAME:1.1 "nvim" Enter
tmux send-keys -t $SESSION_NAME:1.2 "npm run dev" Enter
# Pane 3 queda para comandos manuales

# Adjuntar
tmux attach-session -t $SESSION_NAME
```

### Script: Restaurar Contexto

```bash
#!/bin/bash
# ~/scripts/tmux-restore-context.sh

# Backend API
tmux new-session -d -s backend -c ~/proyectos/api
tmux send-keys -t backend "nvim" Enter
tmux split-window -h -t backend
tmux send-keys -t backend:1.2 "npm run dev" Enter

# Frontend
tmux new-session -d -s frontend -c ~/proyectos/web
tmux send-keys -t frontend "nvim" Enter
tmux split-window -h -t frontend
tmux send-keys -t frontend:1.2 "npm run dev" Enter

# Infrastructure
tmux new-session -d -s infra -c ~/proyectos/terraform
tmux send-keys -t infra "nvim" Enter

echo "Contexto restaurado. Usa 'tmux attach -t [backend|frontend|infra]'"
```

## Alias de Zsh para Tmux

**Agregar a `~/.zshrc`:**

```bash
# Tmux aliases
alias tn='tmux new -s'                    # Nueva sesión con nombre
alias ta='tmux attach -t'                 # Adjuntar a sesión
alias tl='tmux ls'                        # Listar sesiones
alias tk='tmux kill-session -t'           # Matar sesión
alias tka='tmux kill-server'              # Matar todas las sesiones

# SessionX directo
alias tsx='tmux new -s temp && tmux send-keys "Prefix + s" Enter'

# Restaurar contexto
alias trc='~/scripts/tmux-restore-context.sh'
```

**Uso:**

```bash
tn backend          # Crear sesión "backend"
ta frontend         # Adjuntar a "frontend"
tl                  # Ver todas las sesiones
tk infra            # Matar sesión "infra"
tka                 # Matar todo y empezar de nuevo
```

## Tips Pro

1. **Nombra tus sesiones siempre**: Más fácil de encontrar con SessionX
2. **Usa Zoom Mode**: `Prefix + m` para foco total
3. **Copy Mode para logs**: Busca errores con `/`, copia con `y`
4. **Thumbs para URLs**: Copia links sin mouse
5. **Scripts de proyecto**: Automatiza layouts complejos
6. **Confía en Continuum**: Auto-guarda cada 15 min
7. **SessionX + Zoxide**: Indexa tus proyectos navegando a ellos
8. **Status bar minimalista**: `Prefix + \` para más espacio

## Recursos Adicionales

- [Tmux Manual](https://github.com/tmux/tmux/wiki)
- [SessionX GitHub](https://github.com/omerxx/tmux-sessionx)
- [Vim-Tmux-Navigator](https://github.com/christoomey/vim-tmux-navigator)
- [Resurrect GitHub](https://github.com/tmux-plugins/tmux-resurrect)
- [Continuum GitHub](https://github.com/tmux-plugins/tmux-continuum)

## Referencias

- [Configuración Principal de Tmux](../services/tmux.md)
- [Integración de Herramientas](../advanced/integration.md)
- [Workflows de Desarrollo](../guides/workflows.md)

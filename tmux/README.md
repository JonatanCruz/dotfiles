# Configuración de Tmux para Desarrollo

Configuración completa de tmux optimizada para desarrollo con múltiples plugins, gestor de sesiones, y tema Dracula unificado.

## 🎨 Características

- **Prefix key:** `Ctrl+s` (más ergonómico que `Ctrl+b`)
- **Tema:** Dracula con fondo transparente (armonía visual con todo el setup)
- **Navegación:** Estilo Vim (hjkl) integrada con Neovim
- **Historial:** 30,000 líneas (amplio historial de comandos)
- **Persistencia:** Sesiones guardadas automáticamente
- **Gestor de Sesiones:** SessionX con FZF y Zoxide
- **Clipboard:** Integrado con el sistema
- **Copy Mode:** Modo Vi para navegación y selección

## 📦 Plugins Instalados

### Funcionalidades Core
- **tmux-sensible** - Configuraciones sensatas por defecto
- **tmux-yank** - Copiar al clipboard del sistema
- **tmux-resurrect** - Guardar/restaurar sesiones
- **tmux-continuum** - Auto-guardar sesiones cada 15 min
- **vim-tmux-navigator** - Navegación fluida con Neovim
- **tmux.nvim** - Integración mejorada con Neovim

### Utilidades
- **tmux-thumbs** - Copiar texto rápidamente (URLs, paths, hashes)
- **tmux-fzf** - Fuzzy finder para sesiones/ventanas
- **tmux-fzf-url** - Abrir URLs con FZF
- **tmux-sessionx** - Gestor de sesiones con FZF + Zoxide

### Tema
- **dracula/tmux** - Tema Dracula oficial para tmux

## 🚀 Instalación

### 1. Aplicar Configuración con Stow

```bash
cd ~/dotfiles
stow tmux
```

### 2. Instalar TPM (Tmux Plugin Manager)

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### 3. Instalar Plugins

1. Inicia tmux: `tmux`
2. Presiona `Ctrl+s` + `I` (mayúscula i) para instalar plugins
3. Espera a que termine la instalación
4. ¡Listo!

## ⌨️ Atajos de Teclado

### General
| Atajo | Acción |
|-------|--------|
| `Ctrl+s` | Prefix key |
| `Prefix + r` | Recargar configuración |
| `Prefix + ?` | Ver todos los keybindings |

### Gestión de Sesiones
| Atajo | Acción |
|-------|--------|
| `Prefix + s` | **SessionX** - Gestor de sesiones con FZF |
| `Prefix + d` | Detach de la sesión |
| `Prefix + $` | Renombrar sesión actual |
| `Prefix + Ctrl+s` | Guardar sesión manualmente |
| `Prefix + Ctrl+r` | Restaurar sesión guardada |

### Gestión de Ventanas (Tabs)
| Atajo | Acción |
|-------|--------|
| `Prefix + c` | Nueva ventana |
| `Prefix + ,` | Renombrar ventana |
| `Prefix + n` | Siguiente ventana |
| `Prefix + p` | Ventana anterior |
| `Prefix + 0-9` | Ir a ventana específica |
| `Prefix + w` | Lista de ventanas con FZF |
| `Prefix + &` | Cerrar ventana actual |

### Gestión de Panes (Splits)

**Crear splits:**
| Atajo | Acción |
|-------|--------|
| `Prefix + v` | Split vertical (arriba/abajo) |
| `Prefix + h` | Split horizontal (izquierda/derecha) |

**Navegar entre panes:**
| Atajo | Acción |
|-------|--------|
| `Prefix + h/j/k/l` | Mover izquierda/abajo/arriba/derecha |
| `Ctrl + h/j/k/l` | Navegación directa (compartida con Neovim) |

**Redimensionar panes:**
| Atajo | Acción |
|-------|--------|
| `Alt + h` | Reducir ancho (izquierda) |
| `Alt + l` | Aumentar ancho (derecha) |
| `Alt + j` | Reducir altura (abajo) |
| `Alt + k` | Aumentar altura (arriba) |

**Otras acciones:**
| Atajo | Acción |
|-------|--------|
| `Prefix + m` | Zoom/maximizar pane actual |
| `Prefix + x` | Cerrar pane actual |
| `Prefix + z` | Toggle zoom |

### Utilidades Avanzadas
| Atajo | Acción |
|-------|--------|
| `Prefix + Space` | **Tmux Thumbs** - Copiar URLs/paths/hashes |
| `Prefix + u` | **FZF URLs** - Seleccionar y abrir URL |
| `Prefix + F` | **FZF Search** - Buscar en todas las sesiones |
| `Prefix + \` | Toggle mostrar/ocultar status bar |

### Copy Mode (Modo Vi)
| Atajo | Acción |
|-------|--------|
| `Prefix + [` | Entrar en copy mode |
| `/texto` | Buscar texto (en copy mode) |
| `n` / `N` | Siguiente/anterior resultado |
| `v` | Iniciar selección visual |
| `y` | Copiar selección al clipboard |
| `q` | Salir de copy mode |
| `Prefix + ]` | Pegar desde tmux |

## 🔥 Funcionalidades Destacadas

### 1. SessionX - Gestor de Sesiones ⭐

El plugin más útil. Combina tmux + FZF + Zoxide:

```bash
# Presiona: Prefix + s
# Verás una interfaz FZF donde puedes:
# - Buscar sesiones existentes
# - Crear nueva sesión en cualquier directorio
# - Usa zoxide para encontrar proyectos rápidamente
# - Preview de sesiones en tiempo real
# - Filtrar por nombre
```

**Configuración:**
- Ventana de 85% alto x 75% ancho
- Integración con Zoxide activada
- Auto-accept desactivado (puedes editar antes de abrir)
- No filtra la sesión actual

### 2. Tmux Thumbs - Copiar Rápido ⭐

Copia URLs, paths, hashes de git, IPs sin usar el mouse:

```bash
# Presiona: Prefix + Space
# Aparecen letras al lado de:
# - URLs (http://...)
# - Paths (/home/user/...)
# - Git hashes (7a3f2e1)
# - IPs (192.168.1.1)
# - Números de puerto (localhost:3000)

# Presiona la letra para copiar al clipboard
```

### 3. Resurrect + Continuum - Sesiones Persistentes

**Auto-guardado:**
- Sesiones se guardan automáticamente cada 15 minutos
- Al reiniciar tmux, la última sesión se restaura
- Incluye layout de panes, programas corriendo, directorios

**Manual:**
- `Prefix + Ctrl+s` - Guardar ahora
- `Prefix + Ctrl+r` - Restaurar sesión guardada

**Qué se guarda:**
- Layout de todos los panes
- Directorios de trabajo
- Programas en ejecución (bash, vim, etc.)
- Sesiones de Neovim (con estrategia especial)

### 4. FZF-URL - Abrir URLs

```bash
# Presiona: Prefix + u
# Muestra lista de todas las URLs visibles
# Usa FZF para seleccionar
# Enter abre en el navegador
```

### 5. Vim-Tmux-Navigator - Navegación Fluida

Navega entre panes de tmux y splits de Neovim con los mismos atajos:

```bash
# Ctrl + h/j/k/l funciona en:
# - Panes de tmux
# - Splits de Neovim
# - No importa si estás en vim o en terminal
```

### 6. Resize Inteligente

El resize con `Alt+h/j/k/l` detecta si estás en Vim:
- Si estás en Vim: envía el comando a Vim
- Si estás en terminal: redimensiona el pane de tmux

### 7. Toggle Status Bar

```bash
# Presiona: Prefix + \
# Muestra/oculta la barra de estado

# Además:
# - Si solo hay 1 ventana, la barra se oculta automáticamente
# - Útil para maximizar espacio vertical
```

### 8. Copy Mode con Vim

Modo de navegación y copia estilo Vim:

```bash
# Prefix + [ para entrar
# Navega con h/j/k/l
# Busca con /
# Selecciona con v
# Copia con y
# Sale automáticamente al copiar
# Pega con Prefix + ] o Cmd+V
```

## 🎨 Tema Dracula

Configuración del tema oficial de Dracula:

- **Powerline:** Activado para una apariencia más pulida
- **Status bar:** En la parte superior, fondo transparente
- **Plugins en status bar:** CPU usage, RAM usage, y hora
- **Left icon:** Muestra el nombre de la sesión
- **Hora:** Formato militar (24h)
- **Colores:** Esquema Dracula oficial
  - Background: `#282a36`
  - Foreground: `#f8f8f2`
  - Purple: `#bd93f9`
  - Pink: `#ff79c6`
  - Cyan: `#8be9fd`
  - Green: `#50fa7b`
  - Orange: `#ffb86c`
  - Red: `#ff5555`
  - Yellow: `#f1fa8c`

## 🔧 Configuraciones Importantes

### Historial Ampliado
```bash
set -g history-limit 30000
```
Mantiene 30,000 líneas (vs 2,000 por defecto) - muy útil para logs largos.

### No Salir al Cerrar Sesión
```bash
set -g detach-on-destroy off
```
Al cerrar una sesión, tmux cambia a otra en lugar de salir completamente.

### Clipboard del Sistema
```bash
set -g set-clipboard on
```
Lo que copies en tmux va al clipboard del sistema (Cmd+V funciona).

### Sin Delay en ESC
```bash
set -g escape-time 0
```
Crítico para usar Vim dentro de tmux sin delays molestos.

### Mouse Habilitado
```bash
set -g mouse on
```
Permite:
- Click para seleccionar panes
- Scroll para ver historial
- Arrastrar para redimensionar panes
- Doble-click para copiar palabras

### True Color + Undercurl
```bash
set-option -sa terminal-overrides ",xterm*:Tc"
set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
```
Soporte completo de colores de 24-bit y undercurl para Neovim.

## 💡 Workflows Recomendados

### Desarrollo de Proyectos

```bash
# 1. Abre tmux
tmux

# 2. Abre SessionX
Prefix + s

# 3. Busca tu proyecto (usa zoxide)
# Escribe: "dotfiles" o parte del path
# Enter para crear/abrir sesión

# 4. Organiza tu workspace:
Prefix + v    # Split vertical
Prefix + h    # Split horizontal

# Resultado típico:
# ┌─────────────┬─────────────┐
# │             │             │
# │   Neovim    │   Server    │
# │   Editor    │   npm run   │
# │             │             │
# ├─────────────┴─────────────┤
# │      Terminal/Git         │
# └───────────────────────────┘
```

### Copiar URLs/Paths Rápidamente

```bash
# 1. Ejecuta comando que genera output con URLs
git log --oneline

# 2. Activa Thumbs
Prefix + Space

# 3. Presiona la letra que aparece al lado del hash
# ¡Copiado al clipboard!

# 4. Usa en otro lugar
Cmd + V
```

### Cambiar Entre Múltiples Proyectos

```bash
# Tienes varios proyectos abiertos

# Opción 1: SessionX
Prefix + s
# Busca por nombre de proyecto

# Opción 2: Lista de sesiones
Prefix + w
# Usa flechas + Enter

# Opción 3: Direct switch (si sabes el nombre)
tmux switch-client -t proyecto-name
```

### Guardar Trabajo y Apagar

```bash
# Tu trabajo se guarda automáticamente cada 15 min

# Pero si quieres asegurarte:
Prefix + Ctrl+s    # Guardar ahora

# Sal de tmux
Prefix + d    # Detach

# O cierra la terminal directamente
# La próxima vez que abras tmux:
# - Tus sesiones estarán ahí
# - Con el mismo layout
# - En los mismos directorios
```

## 🐛 Solución de Problemas

### Los plugins no se cargan

**Solución:**
```bash
# 1. Verifica TPM
ls ~/.tmux/plugins/tpm

# 2. Reinstala plugins
# Dentro de tmux:
Prefix + I

# 3. Recargar tmux
Prefix + r
```

### Los colores se ven mal

**Solución:**
```bash
# Verifica el TERM
echo $TERM
# Debería mostrar algo con 256color

# En ~/.zshrc, asegura:
export TERM="xterm-256color"

# O en WezTerm usa:
set -g default-terminal "${TERM}"
```

### SessionX no encuentra proyectos

**Solución:**
```bash
# Primero, usa zoxide para indexar:
cd ~/tu-proyecto
cd ~/otro-proyecto

# Zoxide necesita visitar directorios primero
# Verifica la base de datos:
zoxide query -ls

# Ahora Prefix + s debería encontrarlos
```

### Copy al clipboard no funciona

**Solución en macOS:**
```bash
# Asegúrate de tener tmux-yank instalado:
Prefix + I

# En copy mode, usa 'y' no Enter
# Enter solo copia al buffer de tmux
# 'y' copia al clipboard del sistema
```

### Navegación Vim-Tmux no funciona

**Solución:**
```bash
# Verifica el plugin en Neovim:
# En ~/.config/nvim debe estar configurado
# christoomey/vim-tmux-navigator

# Recarga tmux:
Prefix + r

# Recarga Neovim:
:source $MYVIMRC
```

### Alt+hjkl no redimensiona

**En macOS con WezTerm:**
El atajo podría estar siendo capturado por WezTerm.

**Solución alternativa:**
```bash
# Usa el método tradicional:
Prefix + H/J/K/L

# O configura en WezTerm para permitir Alt
```

## 📚 Comandos Útiles de Tmux

### Sesiones
```bash
# Listar sesiones
tmux ls

# Crear sesión con nombre
tmux new -s proyecto

# Adjuntar a sesión existente
tmux attach -t proyecto

# Cambiar de sesión (desde dentro de tmux)
Prefix + s

# Renombrar sesión actual
Prefix + $

# Matar sesión
tmux kill-session -t proyecto

# Matar todas las sesiones
tmux kill-server
```

### Ventanas
```bash
# Nueva ventana
Prefix + c

# Lista de ventanas
Prefix + w

# Siguiente/anterior
Prefix + n/p

# Ir a ventana específica
Prefix + 0-9

# Renombrar ventana
Prefix + ,

# Cerrar ventana
Prefix + &
```

### Panes
```bash
# Split vertical
Prefix + v

# Split horizontal
Prefix + h

# Cerrar pane
Prefix + x

# Zoom pane
Prefix + m

# Rotar panes
Prefix + Ctrl+o

# Mostrar números de panes
Prefix + q
```

## 🔗 Referencias

- [Tmux Documentation](https://github.com/tmux/tmux/wiki)
- [TPM - Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
- [SessionX](https://github.com/omerxx/tmux-sessionx)
- [Tmux Thumbs](https://github.com/fcsonline/tmux-thumbs)
- [Tokyo Night Tmux](https://github.com/nikolovlazar/tokyo-night-tmux)
- [Vim-Tmux-Navigator](https://github.com/christoomey/vim-tmux-navigator)
- [Tmux Resurrect](https://github.com/tmux-plugins/tmux-resurrect)
- [Tmux Continuum](https://github.com/tmux-plugins/tmux-continuum)

## 💪 Tips Pro

1. **Usa SessionX siempre** - Es más rápido que `tmux attach`
2. **Nombra tus sesiones** - Más fácil de encontrar con FZF
3. **Thumbs para copiar** - Olvídate del mouse
4. **Zoom con Prefix+m** - Foco total en un pane
5. **Toggle status bar** - Más espacio vertical cuando lo necesites
6. **Deja que Continuum guarde** - No te preocupes por perder trabajo
7. **Usa Copy Mode** - Busca en el output con `/`
8. **Alt+hjkl para resize** - Ajusta panes sin soltar Neovim

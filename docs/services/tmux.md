# Tmux - Terminal Multiplexer

Configuración moderna de Tmux con TPM, SessionX, Resurrect, Continuum, navegación Vim y tema Catppuccin Mocha transparente.

## Características Principales

- **🎨 Catppuccin Mocha**: Tema morado/cyan con background transparente
- **📋 SessionX**: Gestión avanzada de sesiones con FZF y Zoxide
- **💾 Resurrect + Continuum**: Persistencia automática de sesiones
- **🔄 Vim-Tmux-Navigator**: Navegación seamless entre panes de Tmux y splits de Neovim
- **📝 Thumbs**: Copia rápida de texto/URLs sin mouse
- **⚡ Status Bar Minimalista**: Solo tabs y nombre de sesión
- **🔗 Integración Completa**: Con Neovim, Yazi, LazyGit

## Prefix Key

**Prefix**: `Ctrl+s` (no el tradicional `Ctrl+b`)

## Plugins Instalados

| Plugin | Descripción |
|--------|-------------|
| **TPM** | Tmux Plugin Manager |
| **SessionX** | Gestión de sesiones con FZF + Zoxide |
| **Resurrect** | Guardar/restaurar sesiones |
| **Continuum** | Auto-save cada 15 minutos |
| **vim-tmux-navigator** | Navegación Vim/Tmux |
| **Thumbs** | Copia rápida de texto |
| **Yank** | Copia al clipboard del sistema |
| **Catppuccin** | Tema Mocha transparente |

## Keybindings Esenciales

### Gestión de Sesiones

```bash
# SessionX (recomendado)
Prefix + s          # Abrir SessionX con FZF
                    # Busca por nombre o path
                    # Enter para crear/cambiar

# Tradicional
Prefix + d          # Detach de sesión
Prefix + $          # Renombrar sesión
Prefix + w          # Lista de sesiones tradicional
```

### Panes

```bash
# Splits
Prefix + v          # Split vertical (|)
Prefix + h          # Split horizontal (-)

# Navegación (Vim-style)
Ctrl + h/j/k/l      # Navegar entre panes (¡también funciona en Neovim!)

# Redimensionar
Alt + h/j/k/l       # Resize panes (hold para repetir)
Prefix + H/J/K/L    # Resize alternativo

# Otros
Prefix + x          # Cerrar pane
Prefix + m          # Zoom pane (fullscreen toggle)
Prefix + q          # Mostrar números de panes
```

### Ventanas

```bash
Prefix + c          # Nueva ventana
Prefix + n/p        # Siguiente/anterior ventana
Prefix + 0-9        # Ir a ventana específica
Prefix + ,          # Renombrar ventana
Prefix + &          # Cerrar ventana
```

### Copy Mode

```bash
Prefix + [          # Entrar a copy mode
/                   # Buscar hacia adelante
?                   # Buscar hacia atrás
n/N                 # Siguiente/anterior match
Space               # Iniciar selección
Enter               # Copiar selección
y                   # Copiar al clipboard del sistema
q                   # Salir de copy mode
```

### Thumbs (Copia Rápida)

```bash
Prefix + Space      # Activar Thumbs
[letra]             # Copiar el elemento marcado
```

### Utilidades

```bash
Prefix + r          # Recargar configuración
Prefix + \          # Toggle status bar
Prefix + I          # Instalar plugins
Prefix + U          # Actualizar plugins
Prefix + Ctrl+s     # Guardar sesión manualmente
```

## Workflows Recomendados

### Desarrollo de Proyectos

```bash
# 1. Abrir Tmux
tmux

# 2. Abrir SessionX
Prefix + s

# 3. Buscar proyecto (usa zoxide)
# Escribe: "dotfiles" o parte del path
# Enter para crear/abrir sesión

# 4. Organizar workspace
Prefix + v    # Split vertical
Prefix + h    # Split horizontal

# Resultado típico:
# ┌─────────────┬─────────────┐
# │   Neovim    │   Server    │
# │   Editor    │   npm run   │
# ├─────────────┴─────────────┤
# │      Terminal/Git         │
# └───────────────────────────┘
```

### Persistencia de Sesiones

```bash
# Auto-save cada 15 minutos (Continuum)
# No necesitas hacer nada

# Guardar manualmente
Prefix + Ctrl+s

# Cerrar terminal directamente
# La próxima vez que abras tmux:
# - Tus sesiones estarán ahí
# - Con el mismo layout
# - En los mismos directorios
```

### Navegación Vim-Tmux

```bash
# En Neovim o Tmux:
Ctrl + h    # Ir a la izquierda (pane o split)
Ctrl + j    # Ir abajo
Ctrl + k    # Ir arriba
Ctrl + l    # Ir a la derecha

# ¡Funciona seamlessly entre Neovim y Tmux!
```

## Configuración

### Status Bar Minimalista

El status bar muestra solo:
- Lista de ventanas (tabs)
- Nombre de sesión actual

Se puede ocultar con `Prefix + \` para más espacio vertical.

### Background Transparente

La configuración está optimizada para terminales modernos con soporte de transparencia:
- Catppuccin Mocha con background transparente
- Se integra perfectamente con WezTerm, Alacritty, iTerm2

### Historial

- 30,000 líneas de historial
- Compartido entre panes
- Accesible con Copy Mode

### True Color + Undercurl

```bash
set-option -sa terminal-overrides ",xterm*:Tc"
set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
```

Soporte completo de colores 24-bit y undercurl para Neovim.

## Solución de Problemas

### Los plugins no se cargan

```bash
# 1. Verificar TPM
ls ~/.tmux/plugins/tpm

# 2. Reinstalar plugins
# Dentro de tmux:
Prefix + I

# 3. Recargar tmux
Prefix + r
```

### SessionX no encuentra proyectos

```bash
# Zoxide necesita indexar directorios primero
cd ~/proyecto1
cd ~/proyecto2

# Verificar base de datos
zoxide query -ls

# Ahora Prefix + s debería encontrarlos
```

### Navegación Vim-Tmux no funciona

```bash
# Verificar plugin en Neovim
# En ~/.config/nvim debe estar configurado
# christoomey/vim-tmux-navigator

# Recarga tmux:
Prefix + r

# Recarga Neovim:
:source $MYVIMRC
```

### Alt+hjkl no redimensiona (macOS con WezTerm)

El atajo podría estar siendo capturado por WezTerm.

**Solución alternativa**:
```bash
# Usa el método tradicional:
Prefix + H/J/K/L
```

## Comandos Útiles de Tmux

```bash
# Listar sesiones
tmux ls

# Crear sesión con nombre
tmux new -s proyecto

# Adjuntar a sesión existente
tmux attach -t proyecto

# Renombrar sesión (desde dentro)
Prefix + $

# Matar sesión
tmux kill-session -t proyecto

# Matar todas las sesiones
tmux kill-server
```

## Integración con Otras Herramientas

- **Neovim**: Navegación seamless con `Ctrl+h/j/k/l`
- **Zsh**: Aliases `tn`, `ta`, `tl`, `tk` para gestión rápida
- **LazyGit**: Se abre en pane flotante desde Neovim
- **Yazi**: File manager integrado

## Tips Pro

1. **Usa SessionX siempre** - Más rápido que `tmux attach`
2. **Nombra tus sesiones** - Más fácil de encontrar con FZF
3. **Thumbs para copiar** - Olvídate del mouse
4. **Zoom con Prefix+m** - Foco total en un pane
5. **Status bar minimalista** - El código es el protagonista
6. **Toggle status bar** - `Prefix + \` para más espacio vertical
7. **Deja que Continuum guarde** - No te preocupes por perder trabajo
8. **Copy Mode** - Busca en el output con `/`
9. **Alt+hjkl para resize** - Ajusta panes sin soltar Neovim

## Recursos Adicionales

- [Workflows Avanzados de Tmux](../advanced/tmux-workflows.md)
- [Keybindings Completos](../guides/keybindings.md)
- [Integración con Otras Herramientas](../advanced/integration.md)

## Referencias

- [Tmux Documentation](https://github.com/tmux/tmux/wiki)
- [TPM](https://github.com/tmux-plugins/tpm)
- [SessionX](https://github.com/omerxx/tmux-sessionx)
- [Catppuccin for Tmux](https://github.com/catppuccin/tmux)
- [Vim-Tmux-Navigator](https://github.com/christoomey/vim-tmux-navigator)

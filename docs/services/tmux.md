![Tmux](https://img.shields.io/badge/tmux-%23a6e3a1?style=for-the-badge&logo=tmux&logoColor=white&color=1e1e2e)

# Tmux - Terminal Multiplexer

Configuración moderna de Tmux con TPM, SessionX, Resurrect, Continuum, navegación Vim y status bar minimalista con colores Catppuccin Mocha.

## Caracteristicas Principales

- **Catppuccin Mocha**: Colores aplicados via status bar custom (sin plugin externo de tema)
- **SessionX**: Gestion avanzada de sesiones con FZF y Zoxide
- **Resurrect + Continuum**: Persistencia y restauracion automatica de sesiones
- **vim-tmux-navigator**: Navegacion seamless entre panes de Tmux y splits de Neovim
- **aserowy/tmux.nvim**: Integracion profunda con Neovim para resize vim-aware
- **Thumbs**: Copia rapida de texto y URLs sin mouse
- **Status bar minimalista**: Solo tabs y nombre de sesion, posicionado en la parte superior

## Prefix Key

**Prefix**: `Ctrl+s` (no el tradicional `Ctrl+b`)

La tecla prefix se reenvia a la aplicacion con `Ctrl+s Ctrl+s`.

## Plugins Instalados

| Plugin | Descripcion |
|--------|-------------|
| `tmux-plugins/tpm` | Tmux Plugin Manager |
| `tmux-plugins/tmux-sensible` | Opciones razonables por defecto |
| `tmux-plugins/tmux-yank` | Copia al clipboard del sistema |
| `tmux-plugins/tmux-resurrect` | Guardar y restaurar sesiones manualmente |
| `tmux-plugins/tmux-continuum` | Auto-save de sesiones cada 15 minutos |
| `christoomey/vim-tmux-navigator` | Navegacion Vim/Tmux con Ctrl+hjkl |
| `aserowy/tmux.nvim` | Integracion profunda con Neovim (resize vim-aware) |
| `fcsonline/tmux-thumbs` | Copia rapida de texto visible en pantalla |
| `sainnhe/tmux-fzf` | FZF dentro de Tmux (sesiones, windows, panes) |
| `wfxr/tmux-fzf-url` | Seleccionar y abrir URLs del buffer con FZF |
| `omerxx/tmux-sessionx` | Gestion avanzada de sesiones con FZF + Zoxide |
| `alexwforsythe/tmux-which-key` | Muestra keybindings disponibles (estilo which-key de Vim) |

## Keybindings

### Sesiones

| Keybinding | Accion |
|-----------|--------|
| `Prefix + s` | Abrir SessionX (FZF + Zoxide) |
| `Prefix + d` | Detach de la sesion actual |
| `Prefix + $` | Renombrar sesion |
| `Prefix + w` | Lista de sesiones tradicional |

### Panes

#### Splits

| Keybinding | Accion | Resultado |
|-----------|--------|-----------|
| `Prefix + v` | Split vertical | Divide el pane en dos filas (arriba/abajo) |
| `Prefix + h` | Split horizontal | Divide el pane en dos columnas (izquierda/derecha) |

Ambos splits se abren en el directorio actual del pane.

#### Navegacion

| Keybinding | Accion |
|-----------|--------|
| `Ctrl + h` | Ir al pane de la izquierda |
| `Ctrl + j` | Ir al pane de abajo |
| `Ctrl + k` | Ir al pane de arriba |
| `Ctrl + l` | Ir al pane de la derecha |

La navegacion con `Ctrl+hjkl` funciona sin prefix y es transparente entre Neovim y Tmux.

#### Resize

| Keybinding | Accion |
|-----------|--------|
| `Alt + h` | Reducir pane hacia la izquierda |
| `Alt + j` | Reducir pane hacia abajo |
| `Alt + k` | Expandir pane hacia arriba |
| `Alt + l` | Expandir pane hacia la derecha |

El resize con `Alt+hjkl` es vim-aware: si el foco esta en Neovim, envia el atajo a Neovim en lugar de redimensionar el pane de Tmux.

#### Otros

| Keybinding | Accion |
|-----------|--------|
| `Prefix + m` | Zoom/unzoom del pane actual (fullscreen toggle) |
| `Prefix + x` | Cerrar pane |
| `Prefix + q` | Mostrar numeros de panes |

### Ventanas

| Keybinding | Accion |
|-----------|--------|
| `Prefix + c` | Nueva ventana |
| `Prefix + n` | Siguiente ventana |
| `Prefix + p` | Ventana anterior |
| `Prefix + 1-9` | Ir a ventana por numero |
| `Prefix + ,` | Renombrar ventana |
| `Prefix + &` | Cerrar ventana |

### Copy Mode (Vi)

El modo de copia usa keybindings de Vi (`mode-keys vi`).

| Keybinding | Accion |
|-----------|--------|
| `Prefix + [` | Entrar a copy mode |
| `/` | Buscar hacia adelante |
| `?` | Buscar hacia atras |
| `n` / `N` | Siguiente / anterior coincidencia |
| `Space` | Iniciar seleccion |
| `Enter` | Copiar seleccion |
| `y` | Copiar al clipboard del sistema |
| `q` | Salir de copy mode |

### Thumbs (Copia Rapida)

| Keybinding | Accion |
|-----------|--------|
| `Prefix + Space` | Activar Thumbs |
| `[letra]` | Copiar el elemento marcado |

Thumbs resalta texto, rutas, hashes y URLs visibles en pantalla y permite copiarlos sin usar el mouse.

### Utilidades

| Keybinding | Accion |
|-----------|--------|
| `Prefix + r` | Recargar configuracion |
| `Prefix + \` | Toggle status bar |
| `Prefix + Ctrl+s` | Guardar sesion manualmente (Resurrect) |
| `Prefix + I` | Instalar plugins (TPM) |
| `Prefix + U` | Actualizar plugins (TPM) |

## Configuracion

### Opciones Generales

| Opcion | Valor | Descripcion |
|--------|-------|-------------|
| `prefix` | `Ctrl+s` | Tecla de acceso |
| `base-index` | `1` | Las ventanas empiezan desde 1, no 0 |
| `pane-base-index` | `1` | Los panes empiezan desde 1, no 0 |
| `escape-time` | `0` | Sin delay al presionar Escape (critico para Neovim) |
| `history-limit` | `30000` | Lineas de historial por pane |
| `mouse` | `on` | Soporte de mouse habilitado |
| `set-clipboard` | `on` | Integracion con clipboard del sistema |
| `renumber-windows` | `on` | Renumera ventanas al cerrar alguna |
| `detach-on-destroy` | `off` | No sale de Tmux al cerrar la ultima sesion |
| `mode-keys` | `vi` | Vi keybindings en copy mode |
| `status-position` | `top` | Status bar en la parte superior |

### True Color y Undercurl

```
set-option -sa terminal-overrides ",xterm*:Tc"
set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
set -as terminal-overrides ',*:Setulc=\E[58::2::...'
```

Habilita colores 24-bit (True Color), undercurl y colores de subrayado para Neovim.

### Status Bar

El status bar es minimalista y usa colores Catppuccin Mocha directamente, sin depender del plugin `catppuccin/tmux`:

- **Fondo**: transparente (`bg=default`)
- **Izquierda**: vacia
- **Derecha**: nombre de sesion en azul (`#89b4fa`)
- **Ventanas**: texto en gris (`#6c7086`), ventana activa en azul bold (`#89b4fa`)
- **Posicion**: parte superior de la terminal

El status bar se puede ocultar con `Prefix + \` para ganar espacio vertical. Se oculta automaticamente si solo hay una ventana abierta.

### Configuracion de Plugins

**SessionX**:
```
bind:        Prefix + s
modo zoxide: activado
altura:      85%
ancho:       75%
```

**Resurrect + Continuum**:
```
auto-restore:          on
estrategia para nvim:  session (restaura sesion de Neovim)
```

## Workflows Recomendados

### Workspace de Desarrollo

```bash
# 1. Abrir o crear sesion con SessionX
Prefix + s
# Escribir nombre del proyecto o parte del path
# Enter para abrir/crear

# 2. Organizar el workspace
Prefix + v    # Split arriba/abajo (editor arriba, terminal abajo)
Prefix + h    # Split izquierda/derecha (editor + servidor)

# Layout resultante tipico:
# ┌────────────────┬────────────────┐
# │    Neovim      │  npm run dev   │
# │    Editor      │  (servidor)    │
# ├────────────────┴────────────────┤
# │         Terminal / Git          │
# └─────────────────────────────────┘
```

### Navegacion Vim-Tmux

```bash
# Desde cualquier pane (Neovim o terminal):
Ctrl + h    # Ir a la izquierda
Ctrl + j    # Ir abajo
Ctrl + k    # Ir arriba
Ctrl + l    # Ir a la derecha

# No hace falta soltar Neovim para moverte entre panes
```

### Persistencia de Sesiones

```bash
# Continuum guarda automaticamente cada 15 minutos
# No se requiere accion

# Guardar manualmente antes de apagar:
Prefix + Ctrl+s

# La proxima vez que abras Tmux, las sesiones se restauran
# con el mismo layout, directorios y sesion de Neovim
```

## Comandos de Linea de Comandos

```bash
# Listar sesiones activas
tmux ls

# Crear sesion con nombre
tmux new -s proyecto

# Adjuntar a sesion existente
tmux attach -t proyecto

# Matar una sesion
tmux kill-session -t proyecto

# Matar todas las sesiones
tmux kill-server
```

## Integracion con Otras Herramientas

| Herramienta | Integracion |
|------------|-------------|
| **Neovim** | Navegacion seamless con `Ctrl+hjkl` y resize vim-aware con `Alt+hjkl` |
| **Zsh** | Aliases `tn`, `ta`, `tl`, `tk` para gestion rapida de sesiones |
| **LazyGit** | Se abre en ventana flotante desde Neovim |
| **Yazi** | File manager integrado al flujo de trabajo |
| **Zoxide** | SessionX usa la base de datos de zoxide para encontrar proyectos |

## Solucion de Problemas

### Los plugins no se cargan

```bash
# Verificar que TPM esta instalado
ls ~/.tmux/plugins/tpm

# Si no existe, instalar TPM:
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Dentro de una sesion Tmux, instalar plugins:
Prefix + I

# Recargar configuracion:
Prefix + r
```

### SessionX no encuentra proyectos

SessionX depende de zoxide para sugerir directorios. Zoxide necesita indexar los directorios visitando primero:

```bash
cd ~/proyecto1
cd ~/proyecto2

# Verificar que zoxide los indexo
zoxide query -ls

# Ahora Prefix + s deberia encontrarlos
```

### La navegacion Ctrl+hjkl no funciona

```bash
# Verificar que vim-tmux-navigator esta configurado en Neovim
# El plugin christoomey/vim-tmux-navigator debe estar en lua/plugins/

# Recargar Tmux:
Prefix + r

# Recargar Neovim:
:source $MYVIMRC
```

### Alt+hjkl no redimensiona en macOS

El atajo puede ser interceptado por el emulador de terminal (WezTerm, iTerm2, etc.).

Solucion alternativa: usar `Prefix + hjkl` (con prefix) para navegar panes directamente, o configurar el emulador de terminal para pasar los atajos `Alt+hjkl` a Tmux.

### El status bar no aparece o tiene colores incorrectos

La configuracion de tema esta en la seccion final del `.tmux.conf` (seccion 7). Esa seccion debe cargarse despues de `run '~/.tmux/plugins/tpm/tpm'` para que sobrescriba los estilos de los plugins.

```bash
# Recargar configuracion:
Prefix + r

# Si persiste, reinicar Tmux completamente:
tmux kill-server && tmux
```

## Tips

1. Usa SessionX siempre para cambiar de proyecto, es mas rapido que `tmux attach`.
2. Nombra tus sesiones descriptivamente para encontrarlas con FZF.
3. Usa Thumbs (`Prefix + Space`) para copiar rutas, hashes o URLs sin el mouse.
4. El zoom con `Prefix + m` es util para foco total en un pane sin cerrar los demas.
5. Deja que Continuum guarde automaticamente; solo usa `Prefix + Ctrl+s` antes de apagar.
6. Usa Copy Mode (`Prefix + [`) para buscar en el output del terminal con `/`.
7. El status bar se puede ocultar con `Prefix + \` cuando necesitas mas espacio vertical.

## Recursos Adicionales

- [Workflows Avanzados de Tmux](../advanced/tmux-workflows.md)
- [Keybindings Completos](../guides/keybindings.md)
- [Integracion con Otras Herramientas](../advanced/integration.md)

## Referencias

- [Tmux Documentation](https://github.com/tmux/tmux/wiki)
- [TPM - Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
- [SessionX](https://github.com/omerxx/tmux-sessionx)
- [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)
- [aserowy/tmux.nvim](https://github.com/aserowy/tmux.nvim)
- [tmux-fzf](https://github.com/sainnhe/tmux-fzf)
- [tmux-fzf-url](https://github.com/wfxr/tmux-fzf-url)
- [tmux-which-key](https://github.com/alexwforsythe/tmux-which-key)

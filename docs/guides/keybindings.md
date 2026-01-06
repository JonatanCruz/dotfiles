# Keybindings - Referencia Completa de Atajos

Tabla maestra de todos los atajos de teclado organizados por herramienta.

## Índice

- [Tmux](#tmux)
- [Neovim](#neovim)
- [Yazi](#yazi)
- [WezTerm](#wezterm)
- [Zsh Vi Mode](#zsh-vi-mode)
- [Quick Reference Card](#quick-reference-card)

---

## Tmux

**Prefix**: `Ctrl+s` (NO el tradicional `Ctrl+b`)

### Gestión de Sesiones

| Keybinding | Acción |
|------------|--------|
| `tmux new -s nombre` | Crear sesión con nombre |
| `tmux ls` | Listar sesiones |
| `tmux attach -t nombre` | Adjuntar a sesión |
| `Prefix + d` | Detach de sesión actual |
| `Prefix + o` | SessionX: fuzzy finder de sesiones |
| `Prefix + Ctrl+x` | Matar sesión actual |
| `Prefix + Ctrl+s` | Guardar sesión (Resurrect) |
| `Prefix + Ctrl+r` | Restaurar sesión (Resurrect) |

### Gestión de Ventanas (Tabs)

| Keybinding | Acción |
|------------|--------|
| `Prefix + c` | Crear nueva ventana |
| `Prefix + ,` | Renombrar ventana |
| `Prefix + n` | Siguiente ventana |
| `Prefix + p` | Ventana anterior |
| `Prefix + [0-9]` | Cambiar a ventana N |
| `Prefix + w` | Listar ventanas (navegable) |
| `Prefix + &` | Cerrar ventana (confirma) |

### Gestión de Paneles (Splits)

| Keybinding | Acción |
|------------|--------|
| `Prefix + \|` | Split vertical |
| `Prefix + -` | Split horizontal |
| `Prefix + h` | Mover a panel izquierdo |
| `Prefix + j` | Mover a panel abajo |
| `Prefix + k` | Mover a panel arriba |
| `Prefix + l` | Mover a panel derecho |
| `Prefix + H` | Resize panel izquierda |
| `Prefix + J` | Resize panel abajo |
| `Prefix + K` | Resize panel arriba |
| `Prefix + L` | Resize panel derecha |
| `Prefix + x` | Cerrar panel (confirma) |
| `Prefix + z` | Zoom/unzoom panel |
| `Prefix + Space` | Cambiar layout de paneles |

### Vim-Tmux Navigator (Navegación Seamless)

**IMPORTANTE**: Estos atajos NO requieren Prefix

| Keybinding | Acción |
|------------|--------|
| `Ctrl+h` | Navegar izquierda (Neovim splits + Tmux panes) |
| `Ctrl+j` | Navegar abajo |
| `Ctrl+k` | Navegar arriba |
| `Ctrl+l` | Navegar derecha |

### Copy Mode (Modo Copia)

| Keybinding | Acción |
|------------|--------|
| `Prefix + [` | Entrar a copy mode |
| `Space` (en copy mode) | Comenzar selección |
| `Enter` (en copy mode) | Copiar selección |
| `Prefix + ]` | Pegar |
| `v` (en copy mode) | Selección visual |
| `y` (en copy mode) | Copiar (yank) |
| `q` (en copy mode) | Salir de copy mode |

### Utilidades

| Keybinding | Acción |
|------------|--------|
| `Prefix + r` | Recargar configuración |
| `Prefix + :` | Prompt de comando Tmux |
| `Prefix + t` | Mostrar reloj |
| `Prefix + ?` | Listar keybindings |
| `Prefix + Ctrl+c` | Crear nueva sesión desde prompt |

### Thumbs (Quick Select)

| Keybinding | Acción |
|------------|--------|
| `Prefix + Space` | Activar Thumbs (selección rápida de paths, URLs) |
| `a-z` (en Thumbs) | Copiar elemento marcado con letra |

---

## Neovim

**Leader**: `Space`

### Navegación Básica (Modo NORMAL)

| Keybinding | Acción |
|------------|--------|
| `h / j / k / l` | Izquierda / Abajo / Arriba / Derecha |
| `w` | Siguiente palabra |
| `b` | Palabra anterior |
| `0` | Inicio de línea |
| `$` | Fin de línea |
| `gg` | Primera línea del archivo |
| `G` | Última línea del archivo |
| `Ctrl+d` | Media página abajo |
| `Ctrl+u` | Media página arriba |
| `%` | Ir a pareja de bracket `()`, `{}`, `[]` |

### Gestión de Archivos

| Keybinding | Acción |
|------------|--------|
| `<leader>w` | Guardar archivo |
| `<leader>q` | Cerrar ventana |
| `<leader>e` | Toggle árbol de archivos (nvim-tree) |
| `<leader>ff` | Buscar archivos (Telescope) |
| `<leader>fg` | Buscar texto en proyecto (Telescope grep) |
| `<leader>fb` | Buscar en buffers (Telescope) |
| `<leader>fh` | Buscar en historial de archivos |
| `:e archivo` | Abrir/crear archivo |
| `:w` | Guardar |
| `:q` | Cerrar |
| `:wq` o `ZZ` | Guardar y cerrar |
| `:q!` o `ZQ` | Cerrar sin guardar |

### Gestión de Buffers

| Keybinding | Acción |
|------------|--------|
| `Shift+h` | Buffer anterior |
| `Shift+l` | Buffer siguiente |
| `<leader>bd` | Cerrar buffer actual |
| `<leader>ba` | Cerrar todos los buffers excepto actual |

### Gestión de Splits

| Keybinding | Acción |
|------------|--------|
| `<leader>sv` | Split vertical |
| `<leader>sh` | Split horizontal |
| `<leader>se` | Igualar tamaño de splits |
| `<leader>sx` | Cerrar split actual |
| `Ctrl+h/j/k/l` | Navegar entre splits (seamless con Tmux) |

### Edición (Modo NORMAL)

| Keybinding | Acción |
|------------|--------|
| `i` | INSERT antes del cursor |
| `a` | INSERT después del cursor |
| `I` | INSERT al inicio de línea |
| `A` | INSERT al final de línea |
| `o` | Insertar línea abajo |
| `O` | Insertar línea arriba |
| `ESC` o `jk` | Volver a modo NORMAL |
| `dd` | Borrar línea |
| `yy` | Copiar línea (yank) |
| `p` | Pegar después |
| `P` | Pegar antes |
| `u` | Undo |
| `Ctrl+r` | Redo |
| `.` | Repetir último comando |

### Edición Avanzada

| Keybinding | Acción |
|------------|--------|
| `ciw` | Change inner word |
| `ci"` | Change inside quotes |
| `ci(` | Change inside parentheses |
| `diw` | Delete inner word |
| `di{` | Delete inside braces |
| `viw` | Visual select inner word |
| `vi[` | Visual select inside brackets |
| `>` | Indentar a la derecha |
| `<` | Indentar a la izquierda |
| `==` | Auto-indentar línea |
| `gcc` | Toggle comentario de línea |
| `gc` (visual) | Comentar selección |

### LSP (Language Server Protocol)

| Keybinding | Acción |
|------------|--------|
| `K` | Hover documentation |
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Go to references |
| `gi` | Go to implementation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code actions |
| `<leader>d` | Ver diagnósticos |
| `]d` | Siguiente diagnóstico |
| `[d` | Diagnóstico anterior |
| `<leader>f` | Format documento |

### Telescope (Fuzzy Finder)

| Keybinding | Acción |
|------------|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep (buscar texto) |
| `<leader>fb` | Buffers |
| `<leader>fh` | Help tags |
| `<leader>fo` | Old files (recientes) |
| `<leader>fc` | Git commits |
| `<leader>fs` | Git status |
| `Ctrl+n` (en Telescope) | Siguiente resultado |
| `Ctrl+p` (en Telescope) | Resultado anterior |
| `ESC` (en Telescope) | Cerrar Telescope |

### Completion (nvim-cmp)

En modo INSERT:

| Keybinding | Acción |
|------------|--------|
| `Ctrl+n` | Siguiente sugerencia |
| `Ctrl+p` | Sugerencia anterior |
| `Ctrl+y` | Confirmar selección |
| `Ctrl+e` | Cerrar completion menu |
| `Ctrl+Space` | Trigger completion |
| `Tab` | Siguiente snippet placeholder |
| `Shift+Tab` | Anterior snippet placeholder |

### Git Integration (LazyGit)

| Keybinding | Acción |
|------------|--------|
| `<leader>gg` | Abrir LazyGit en ventana flotante |

**Dentro de LazyGit** (comandos comunes):
- `Space` - Stage/unstage archivo
- `c` - Commit
- `P` - Push
- `p` - Pull
- `x` - Ver menú de comandos
- `q` - Cerrar LazyGit

### Nvim-tree (File Explorer)

| Keybinding | Acción |
|------------|--------|
| `<leader>e` | Toggle nvim-tree |
| `a` (en nvim-tree) | Crear archivo/directorio |
| `r` (en nvim-tree) | Renombrar |
| `d` (en nvim-tree) | Borrar |
| `x` (en nvim-tree) | Cortar |
| `c` (en nvim-tree) | Copiar |
| `p` (en nvim-tree) | Pegar |
| `Enter` (en nvim-tree) | Abrir archivo/directorio |
| `o` (en nvim-tree) | Abrir archivo y permanecer en tree |
| `Ctrl+v` (en nvim-tree) | Abrir en split vertical |
| `Ctrl+x` (en nvim-tree) | Abrir en split horizontal |

### Terminal Integrado

| Keybinding | Acción |
|------------|--------|
| `<leader>tt` | Toggle terminal horizontal |
| `<leader>tv` | Terminal en split vertical |
| `Ctrl+\` `Ctrl+n` | Salir de modo terminal |
| `:terminal` | Abrir terminal |

---

## Yazi

**Filosofía**: Navegación 100% Vim-style

### Navegación Básica

| Keybinding | Acción |
|------------|--------|
| `h` | Directorio padre |
| `j` | Mover cursor abajo |
| `k` | Mover cursor arriba |
| `l` | Entrar a directorio / Abrir archivo |
| `Enter` | Abrir con aplicación por defecto |
| `g` + `g` | Primera entrada |
| `G` | Última entrada |
| `Ctrl+d` | Media página abajo |
| `Ctrl+u` | Media página arriba |

### Selección y Operaciones

| Keybinding | Acción |
|------------|--------|
| `Space` | Seleccionar/deseleccionar archivo |
| `v` | Modo visual (selección múltiple) |
| `Ctrl+a` | Seleccionar todos |
| `Ctrl+r` | Invertir selección |
| `ESC` | Cancelar selección |
| `y` | Copiar archivos seleccionados |
| `x` | Cortar archivos seleccionados |
| `p` | Pegar |
| `d` | Borrar (enviar a papelera) |
| `D` | Borrar permanentemente |

### Gestión de Archivos

| Keybinding | Acción |
|------------|--------|
| `r` | Renombrar archivo |
| `a` | Crear archivo |
| `o` | Abrir con programa específico |
| `.` | Toggle archivos ocultos |
| `/` | Buscar en directorio actual |
| `z` + `h` | Toggle archivos ocultos |
| `z` + `a` | Mostrar todos (incluso .git) |
| `;` | Ejecutar shell command |
| `:` | Ejecutar comando Yazi |

### Tabs y Navegación Rápida

| Keybinding | Acción |
|------------|--------|
| `t` | Crear nueva tab |
| `1-9` | Cambiar a tab N |
| `[` | Tab anterior |
| `]` | Tab siguiente |
| `~` | Ir a home |
| `-` | Ir a directorio anterior |

### Previsualización y Ordenamiento

| Keybinding | Acción |
|------------|--------|
| `z` + `p` | Toggle preview |
| `,` + `m` | Ordenar por modificación |
| `,` + `a` | Ordenar alfabéticamente |
| `,` + `s` | Ordenar por tamaño |
| `,` + `e` | Ordenar por extensión |

### Shell Integration

| Keybinding | Acción |
|------------|--------|
| `q` | Quit (sin cd) |
| `Q` | Quit con cd al directorio actual |

**Nota**: Para que `Q` funcione, necesitas el wrapper en tu `.zshrc`:
```bash
function yz() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}
```

---

## WezTerm

**Filosofía**: Terminal con aceleración GPU y Quick Select inteligente

### Gestión de Tabs

| Keybinding | Acción |
|------------|--------|
| `Cmd+T` | Nueva tab |
| `Cmd+W` | Cerrar tab |
| `Cmd+[1-9]` | Cambiar a tab N |
| `Cmd+Shift+[` | Tab anterior |
| `Cmd+Shift+]` | Tab siguiente |

### Quick Select (Selección Inteligente)

| Keybinding | Acción |
|------------|--------|
| `Cmd+Shift+Space` | Activar Quick Select |
| `a-z` (en Quick Select) | Copiar elemento marcado |

**Patterns Detectados Automáticamente**:
- Git commit hashes (7-40 chars hex)
- UUIDs
- IPs (xxx.xxx.xxx.xxx)
- Kubernetes pods (nombre-hash-hash)
- Container IDs (12 chars hex)
- File paths absolutos y relativos

### Clipboard y Selección

| Keybinding | Acción |
|------------|--------|
| `Cmd+C` | Copiar selección |
| `Cmd+V` | Pegar |
| `Cmd+Click` | Abrir URL/path |
| `Shift+Click` | Seleccionar texto |

### Búsqueda

| Keybinding | Acción |
|------------|--------|
| `Cmd+F` | Buscar en terminal |
| `Enter` (en búsqueda) | Siguiente match |
| `Shift+Enter` (en búsqueda) | Match anterior |
| `ESC` (en búsqueda) | Cerrar búsqueda |

### Ventana y Configuración

| Keybinding | Acción |
|------------|--------|
| `Cmd+N` | Nueva ventana |
| `Cmd+Q` | Cerrar WezTerm |
| `Cmd+,` | Abrir configuración (recargar .lua) |

---

## Zsh Vi Mode

**Filosofía**: Edición de comandos con Vim keybindings

### Modos

| Keybinding | Acción |
|------------|--------|
| `i` (modo NORMAL) | Entrar a modo INSERT |
| `ESC` o `jk` (modo INSERT) | Volver a modo NORMAL |
| `v` (modo NORMAL) | Abrir comando en Neovim para edición compleja |

### Navegación (Modo NORMAL)

| Keybinding | Acción |
|------------|--------|
| `h / j / k / l` | Izquierda / Abajo / Arriba / Derecha |
| `w` | Siguiente palabra |
| `b` | Palabra anterior |
| `0` | Inicio de línea |
| `$` | Fin de línea |
| `^` | Primer carácter no-espacio |

### Edición (Modo NORMAL)

| Keybinding | Acción |
|------------|--------|
| `x` | Borrar carácter bajo cursor |
| `dd` | Borrar línea completa |
| `dw` | Borrar palabra |
| `d$` | Borrar hasta fin de línea |
| `cc` | Cambiar línea completa |
| `cw` | Cambiar palabra |
| `yy` | Copiar línea |
| `yw` | Copiar palabra |
| `p` | Pegar después |
| `P` | Pegar antes |
| `u` | Undo |

### Historial de Comandos

| Keybinding | Acción |
|------------|--------|
| `Ctrl+r` | Buscar en historial (fuzzy con fzf) |
| `j` / `k` (modo NORMAL) | Navegar historial |
| `↑` / `↓` (modo INSERT) | Navegar historial |
| `/` (modo NORMAL) | Buscar hacia adelante en historial |
| `?` (modo NORMAL) | Buscar hacia atrás en historial |
| `n` | Siguiente match de búsqueda |
| `N` | Anterior match de búsqueda |

### Autocompletar

| Keybinding | Acción |
|------------|--------|
| `Tab` | Trigger autocompletar |
| `Shift+Tab` | Autocompletar inverso |
| `→` | Aceptar sugerencia (zsh-autosuggestions) |
| `Ctrl+Space` | Aceptar primera palabra de sugerencia |

---

## Quick Reference Card

**Cheat Sheet Ultra-Rápido**

### Tmux (Prefix: Ctrl+s)
```
Ctrl+s + |     Split vertical
Ctrl+s + -     Split horizontal
Ctrl+s + h/j/k/l    Navegar paneles
Ctrl+s + d     Detach
Ctrl+h/j/k/l   Navegación seamless (sin Prefix)
```

### Neovim (Leader: Space)
```
Space + e      Árbol de archivos
Space + ff     Buscar archivos
Space + fg     Buscar texto
Space + gg     LazyGit
K              Hover docs
gd             Go to definition
```

### Yazi
```
h/j/k/l        Navegar (Vim-style)
Space          Seleccionar
y/x/p          Copiar/Cortar/Pegar
r              Renombrar
q/Q            Quit (sin/con cd)
```

### WezTerm
```
Cmd+T          Nueva tab
Cmd+Shift+Space    Quick Select
Cmd+Click      Abrir URL
```

### Zsh Vi Mode
```
jk (INSERT)    Volver a NORMAL
v (NORMAL)     Editar comando en Neovim
Ctrl+r         Buscar en historial (fzf)
```

## Tips Pro

### Tmux + Neovim Integration
- Usa `Ctrl+h/j/k/l` para navegar sin pensar entre Neovim splits y Tmux panes
- `Prefix + z` para zoom temporal de un panel
- `Prefix + o` (SessionX) para gestión rápida de sesiones

### Neovim Power User
- `.` (punto) repite el último comando → extremadamente poderoso
- `ciw` (change inner word) es más rápido que seleccionar y borrar
- `gcc` para toggle comentarios rápido
- `<leader>ff` y luego empieza a escribir para búsqueda fuzzy instantánea

### Yazi File Management
- `Space` múltiples archivos → `y` → navegar → `p` para copiar batch
- `v` para modo visual tipo Vim en selección de archivos
- `.` para toggle archivos ocultos rápidamente

### WezTerm Quick Select
- `Cmd+Shift+Space` y luego teclea la letra del elemento que quieres copiar
- Útil para paths, IPs, hashes de Git sin mouse

### Zsh Vi Mode + Historial
- `Ctrl+r` → fuzzy search en historial con preview
- `v` en modo NORMAL → edita comandos largos en Neovim
- `jk` es más ergonómico que ESC (dedos siempre en home row)

## Personalización

Para personalizar keybindings:

- **Tmux**: Edita `~/.tmux.conf`
- **Neovim**: Edita `~/.config/nvim/lua/config/keymaps.lua`
- **Yazi**: Edita `~/.config/yazi/keymap.toml`
- **WezTerm**: Edita `~/.config/wezterm/wezterm.lua`
- **Zsh**: Edita `~/.config/zsh/.zshrc` (sección Vi mode)

Después de editar, recarga la configuración:
```bash
# Tmux
tmux source ~/.tmux.conf

# Neovim
:source ~/.config/nvim/lua/config/keymaps.lua

# Yazi
# Cierra y reabre Yazi

# WezTerm
# Cmd+, para recargar config

# Zsh
source ~/.config/zsh/.zshrc
```

---

**Filosofía General**: Todas las herramientas usan navegación Vim-style (`h/j/k/l`) para consistencia y eficiencia.

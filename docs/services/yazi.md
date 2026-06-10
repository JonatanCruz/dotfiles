![Yazi](https://img.shields.io/badge/yazi-%2394e2d5?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0Ij48Y2lyY2xlIGN4PSIxMiIgY3k9IjEyIiByPSIxMCIgZmlsbD0iIzk0ZTJkNSIvPjwvc3ZnPg==&logoColor=white&color=1e1e2e)

# Yazi - Gestor de Archivos de Terminal

Gestor de archivos de terminal rápido y moderno escrito en Rust con navegación Vim-style, tema Catppuccin y fondo transparente.

## Características Principales

- **Catppuccin Mocha**: Rosa/Mauve con transparencia
- **Extremadamente Rápido**: Escrito en Rust, rendimiento excepcional
- **Layout de 3 Paneles**: Directorio padre, actual, y vista previa
- **Keybindings Vim**: Navegación hjkl nativa
- **Preview de Archivos**: Vista previa de texto, imágenes y videos
- **Extensible**: Plugins en Lua
- **Shell Integration**: Cambia directorio al salir
- **Operaciones en Lote**: Selección y manejo de múltiples archivos

## Layout de Paneles

```
┌──────────────┬──────────────┬──────────────┐
│   Parent     │   Current    │   Preview    │
│  Directory   │  Directory   │   Content    │
│              │              │              │
│  ../         │  file1.txt   │  Line 1      │
│  dotfiles/   │  file2.md    │  Line 2      │
│  projects/   │  src/        │  Line 3      │
│              │              │              │
└──────────────┴──────────────┴──────────────┘
```

## Keybindings Esenciales

### Navegación Básica

| Tecla | Descripción |
|-------|-------------|
| `h` | Ir al directorio padre |
| `j` | Mover cursor abajo |
| `k` | Mover cursor arriba |
| `l` | Entrar al directorio |
| `gg` | Saltar al inicio de la lista |
| `G` | Saltar al final de la lista |

### Navegación de Página

| Tecla | Descripción |
|-------|-------------|
| `Ctrl+d` | Subir media página |
| `Ctrl+u` | Bajar media página |
| `Ctrl+f` | Avanzar página completa |
| `Ctrl+b` | Retroceder página completa |

### Selección y Operaciones

| Tecla | Descripción |
|-------|-------------|
| `Space` | Alternar selección del archivo actual |
| `v` | Entrar en modo visual (selección múltiple) |
| `V` | Salir del modo visual |
| `y` | Copiar (yank) archivo seleccionado |
| `x` | Cortar archivo |
| `p` | Pegar archivo |
| `P` | Pegar y sobrescribir |
| `d` | Eliminar (mover a papelera) |
| `D` | Eliminar permanentemente |

### Creación y Renombrado

| Tecla | Descripción |
|-------|-------------|
| `a` | Crear nuevo archivo/directorio |
| `r` | Renombrar archivo |
| `o` | Abrir archivo con aplicación predeterminada |
| `O` | Abrir archivo con selección interactiva |

### Búsqueda

| Tecla | Descripción |
|-------|-------------|
| `/` | Buscar en el directorio actual |
| `n` | Ir al siguiente resultado |
| `N` | Ir al resultado anterior |

### Pestañas

| Tecla | Descripción |
|-------|-------------|
| `t` | Nueva pestaña |
| `[` | Pestaña anterior |
| `]` | Siguiente pestaña |
| `1-5` | Ir a pestaña específica (1 a 5) |

### Ordenamiento

| Tecla | Descripción |
|-------|-------------|
| `sa` | Ordenar alfabéticamente |
| `sm` | Ordenar por fecha de modificación |
| `ss` | Ordenar por tamaño |

### Vista y Opciones

| Tecla | Descripción |
|-------|-------------|
| `zh` | Alternar visualización de archivos ocultos |
| `~` | Mostrar ayuda |
| `q` | Salir de Yazi |
| `Q` | Salir sin cambiar directorio |

## Configuración

### yazi.toml - Comportamiento

```toml
[mgr]
show_hidden = true         # Mostrar archivos ocultos por defecto
sort_by = "alphabetical"   # Orden alfabético
sort_dir_first = true      # Directorios antes que archivos
```

**Modos de ordenamiento disponibles:**
- `alphabetical` - Orden A-Z
- `natural` - Natural (1, 2, 10 en lugar de 1, 10, 2)
- `modified` - Por fecha de modificación
- `created` - Por fecha de creación
- `size` - Por tamaño de archivo

### Abridor de Archivos

```toml
[opener]
text = [
  { run = 'nvim "$@"', block = true },
]
default = [
  { run = 'open "$@"', orphan = true },
]
```

El archivo se abre automáticamente con la aplicación configurada. En esta configuración:
- Archivos de texto: Neovim
- Otros tipos: Aplicación predeterminada del sistema

### theme.toml - Catppuccin Mocha

**Colores del tema:**

| Color | Hex | Uso |
|-------|-----|-----|
| Rosa | `#f5c2e7` | Ruta actual, modo desactivado |
| Mauve | `#cba6f7` | Bordes activos |
| Verde | `#a6e3a1` | Modo normal, barra de progreso |
| Peach | `#fab387` | Modo selección |
| Rojo | `#f38ba8` | Errores de progreso |
| Overlay | `#6c7086` | Bordes inactivos |

**Personalizar color de la ruta actual:**
```toml
[mgr]
cwd = { fg = "#f5c2e7", bold = true }  # Rosa Catppuccin
```

### keymap.toml - Atajos Personalizados

Las secciones principales del archivo de atajos:

- `[mgr]` - Keybindings del gestor de archivos
- `[input]` - Keybindings del modo de entrada (crear, renombrar)
- `[completion]` - Keybindings del menú de completación
- `[help]` - Keybindings en modo ayuda

Ejemplo de personalización:
```toml
[mgr]
keymap = [
  { on = [ "<C-n>" ], run = "arrow 1", desc = "Move down" },
  { on = [ "<C-p>" ], run = "arrow -1", desc = "Move up" },
]
```

## Integración con Otras Herramientas

### Neovim Integration

Los archivos de texto se abren automáticamente con Neovim:

```toml
[opener]
text = [
  { run = 'nvim "$@"', block = true },
]
```

### Shell Integration (Cambiar Directorio al Salir)

**Función para Zsh** (agregar a `.zshrc`):

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

Uso:
```bash
yz              # Abrir Yazi en directorio actual
yz /path        # Abrir en ruta específica
```

Al salir con `q`, cambias al directorio donde estabas navegando.

## Workflows Comunes

### Workflow 1: Navegación y Edición Rápida

```
1. Abrir Yazi
   $ yz

2. Navegar con hjkl
3. Presionar 'l' o Enter en archivo de texto
4. Neovim se abre automáticamente
5. Editar y salir con :wq
6. Vuelves a Yazi en el mismo lugar
```

### Workflow 2: Copiar/Mover Archivos

```
1. Navegar a directorio origen (hjkl)
2. Seleccionar archivos:
   - Space para seleccionar uno
   - v para modo visual (selecciona múltiples)
3. Presionar 'y' (copiar) o 'x' (cortar)
4. Navegar a directorio destino
5. Presionar 'p' (pegar) o 'P' (sobrescribir)
```

### Workflow 3: Búsqueda y Apertura

```
1. Presionar '/' en Yazi
2. Escribir término de búsqueda
3. Navegar resultados con 'n' / 'N'
4. Presionar Enter para abrir
```

### Workflow 4: Batch Rename

```
1. Seleccionar archivos con Space
2. Presionar 'r' para renombrar
3. Se abre editor de texto con lista de nombres
4. Editar nombres y guardar
```

## Input Mode - Atajos para Crear/Renombrar

Cuando se presiona `a` (crear) o `r` (renombrar), se abre el modo input. Los atajos disponibles:

| Tecla | Descripción |
|-------|-------------|
| `Esc` / `Ctrl+c` | Cancelar |
| `Enter` | Confirmar |
| `Ctrl+h` | Mover cursor a la izquierda |
| `Ctrl+l` | Mover cursor a la derecha |
| `Ctrl+a` | Ir al inicio |
| `Ctrl+e` | Ir al final |
| `Backspace` | Borrar carácter anterior |
| `Ctrl+w` | Borrar palabra anterior |

## Help Mode - Navegación de Ayuda

Presiona `~` para abrir la ayuda. Atajos en el modo ayuda:

| Tecla | Descripción |
|-------|-------------|
| `j` | Bajar |
| `k` | Subir |
| `gg` | Ir al inicio |
| `G` | Ir al final |
| `Ctrl+d` | Media página abajo |
| `Ctrl+u` | Media página arriba |
| `q` / `Esc` | Cerrar ayuda |

## Completion Menu - Seleccionar Sugerencias

Cuando aparece el menú de completación (ej: al presionar Tab en modo input):

| Tecla | Descripción |
|-------|-------------|
| `Ctrl+n` / `j` | Siguiente sugerencia |
| `Ctrl+p` / `k` | Sugerencia anterior |
| `Enter` / `Tab` | Seleccionar |
| `Esc` / `Ctrl+c` | Cerrar |

## Solución de Problemas

### Iconos no se muestran

Instalar Nerd Font:

```bash
# macOS
brew tap homebrew/cask-fonts
brew install font-jetbrains-mono-nerd-font

# O descargar manualmente
# https://www.nerdfonts.com/font-downloads
```

Configurar fuente en terminal (WezTerm, iTerm2, etc.)

### Preview de archivos no funciona

```bash
# macOS
brew install ffmpegthumbnailer poppler
```

### Archivos ocultos no se muestran

Presionar `zh` para alternar archivos ocultos, o editar `yazi.toml`:

```toml
[mgr]
show_hidden = true
```

### Tema no se aplica

```bash
# Verificar archivo de tema
cat ~/.config/yazi/theme.toml

# Reiniciar Yazi
q  # Salir
yazi  # Volver a abrir
```

### True Color no funciona

```bash
# Verificar variable de entorno
echo $TERM

# Debería ser: xterm-256color, tmux-256color, o similar
# Configurar en .zshrc si es necesario
export COLORTERM=truecolor
export TERM=xterm-256color
```

## Tips Pro

### 1. Alias de Shell

Agregar a `.zshrc`:

```bash
alias y='yz'
alias yz='function() { local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"; yazi "$@" --cwd-file="$tmp"; if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then cd -- "$cwd"; fi; rm -f -- "$tmp"; }'
```

### 2. Navegación Rápida con Marcadores

```bash
m    # Crear marcador en directorio actual
'    # Volver al marcador después
```

### 3. Batch Operations

- Seleccionar múltiples archivos con `v` (visual mode)
- `y` para copiar, `x` para cortar, `D` para eliminar
- Navegar con `j/k` en modo visual
- Confirmar operación

## Comparación con Alternativas

| Feature | Yazi | Ranger | NNN | lf |
|---------|------|--------|-----|-----|
| Velocidad | ⚡⚡⚡ | ⚡ | ⚡⚡⚡ | ⚡⚡ |
| Preview | Sí | Sí | No | Sí |
| Lenguaje | Rust | Python | C | Go |
| Configuración | TOML | Python | Config | Go |
| Plugins | Lua | Python | No | No |
| Vim Keys | Sí | Sí | Sí | Sí |
| UI | Moderno | Clásico | Minimalista | Minimalista |

## Comandos Rápidos

```bash
# Abrir Yazi
yazi

# Abrir en ruta específica
yazi /path/to/directory

# Usar función shell con cwd
yz
yz /path
```

## Recursos Adicionales

- [Yazi Documentation](https://yazi-rs.github.io/)
- [GitHub Repository](https://github.com/sxyazi/yazi)
- [Catppuccin Theme](https://github.com/catppuccin/catppuccin)
- [Vim Keybindings Reference](https://vim.rtorr.com/)

# Yazi - File Manager de Terminal

Gestor de archivos de terminal rápido y moderno escrito en Rust con navegación Vim-style, tema Catppuccin y fondo transparente.

## Características Principales

- **🎨 Catppuccin Theme**: Rosa/Mauve con transparencia
- **⚡ Extremadamente Rápido**: Escrito en Rust, rendimiento excepcional
- **📂 3-Panel Layout**: Padre, actual, preview
- **⌨️ Vim Keybindings**: Navegación hjkl nativa
- **🔍 Preview**: Vista previa de archivos, imágenes, videos
- **🔌 Extensible**: Plugins en Lua
- **🖼️ Shell Integration**: Cambia directorio al salir
- **📋 Batch Operations**: Operaciones en múltiples archivos

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

**Movimiento Vim-style:**
- `h` - Directorio padre (subir nivel)
- `j` - Mover cursor abajo
- `k` - Mover cursor arriba
- `l` / `Enter` - Entrar a directorio / Abrir archivo

**Saltos rápidos:**
- `gg` - Inicio de la lista
- `G` - Final de la lista
- `gh` - Home directory (~)
- `g/` - Raíz del sistema (/)

### Operaciones de Archivos

**Selección:**
- `Space` - Seleccionar/deseleccionar archivo
- `v` - Modo visual (selección múltiple)
- `V` - Deseleccionar todo

**Operaciones básicas:**
- `y` - Copiar (yank) archivo seleccionado
- `d` - Cortar (delete/cut) archivo
- `p` - Pegar archivo
- `r` - Renombrar archivo
- `D` - Eliminar permanentemente (con confirmación)
- `c` - Crear nuevo archivo/directorio

### Búsqueda

- `/` - Buscar en directorio actual
- `n` - Siguiente resultado
- `N` - Resultado anterior

### Pestañas

- `t` - Nueva pestaña
- `Tab` - Siguiente pestaña
- `Shift+Tab` - Pestaña anterior
- `1-9` - Ir a pestaña específica (1-8), 9 = última

### Vista y Opciones

- `z` - Toggle archivos ocultos
- `s` - Cambiar modo de ordenamiento
- `o` - Abrir con aplicación externa
- `q` - Salir de Yazi
- `Q` - Salir de todas las pestañas

### Marcadores (Bookmarks)

- `m` - Crear marcador en directorio actual
- `'` (comilla simple) - Ir a marcador

## Configuración

### yazi.toml - Comportamiento

**Opciones principales:**
```toml
[mgr]
show_hidden = true         # Mostrar archivos ocultos por defecto
sort_by = "alphabetical"   # Ordenamiento alfabético
sort_dir_first = true      # Directorios primero
```

**Modos de ordenamiento disponibles:**
- `alphabetical` - Alfabético A-Z
- `natural` - Natural (archivos numerados correctamente: 1, 2, 10 vs 1, 10, 2)
- `modified` - Por fecha de modificación (recientes primero)
- `created` - Por fecha de creación
- `size` - Por tamaño de archivo

### theme.toml - Catppuccin Mocha

**Colores clave del tema:**

| Color | Hex | Uso |
|-------|-----|-----|
| Rosa | `#f5c2e7` | Ruta actual, resaltados |
| Mauve | `#cba6f7` | Borde activo, cursor |
| Verde | `#a6e3a1` | Modo normal, éxito |
| Peach | `#fab387` | Modo selección |
| Rojo | `#f38ba8` | Errores, eliminación |
| Overlay | `#6c7086` | Bordes inactivos |

**Personalizar color de la ruta actual:**
```toml
[mgr]
cwd = { fg = "#f5c2e7", bold = true }  # Rosa Catppuccin
```

### keymap.toml - Atajos Personalizados

**Ejemplo de customización:**
```toml
[mgr]
keymap = [
  # Navegación con Ctrl
  { on = [ "<C-n>" ], exec = "arrow 1" },    # Ctrl+N = abajo
  { on = [ "<C-p>" ], exec = "arrow -1" },   # Ctrl+P = arriba

  # Atajos personalizados
  { on = [ "y", "p" ], exec = 'shell "echo $@ | xclip -selection clipboard" --confirm' },
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
# Al salir con 'q', cambias al directorio donde estabas navegando
```

### Abrir con Aplicaciones Externas

Configurar openers para diferentes tipos de archivo:

```toml
[opener]
# Imágenes
image = [
  { run = 'feh "$@"', orphan = true },
]

# Videos
video = [
  { run = 'mpv "$@"', orphan = true },
]

# PDFs
pdf = [
  { run = 'zathura "$@"', orphan = true },
]
```

### Integración con FZF

Buscar archivos y abrir en Yazi:

```bash
# Agregar a .zshrc
yzf() {
  local file=$(fd --type f | fzf)
  [ -n "$file" ] && yazi "$(dirname "$file")"
}
```

## Workflows Comunes

### Workflow 1: Navegación y Edición Rápida

```bash
# 1. Abrir Yazi
yz

# 2. Navegar con hjkl
# 3. Presionar 'Enter' en archivo de texto
# 4. Neovim se abre automáticamente
# 5. Editar y salir con :wq
# 6. Vuelves a Yazi en el mismo lugar
```

### Workflow 2: Copiar/Mover Archivos

```bash
# 1. Navegar a directorio origen
# 2. Seleccionar archivos con Space o modo visual 'v'
# 3. Presionar 'y' (copiar) o 'd' (cortar)
# 4. Navegar a directorio destino con hjkl
# 5. Presionar 'p' (pegar)
```

### Workflow 3: Búsqueda y Apertura

```bash
# 1. Presionar '/' en Yazi
# 2. Escribir término de búsqueda
# 3. Navegar resultados con 'n' / 'N'
# 4. Presionar Enter para abrir
```

### Workflow 4: Operaciones en Lote

```bash
# 1. Modo visual con 'v'
# 2. Seleccionar múltiples archivos con 'j/k'
# 3. Presionar 'y' (copiar), 'd' (cortar), o 'D' (eliminar)
# 4. Confirmar operación
```

## Plugins y Extensiones

### Directorio de Plugins

```
~/.config/yazi/plugins/
```

### Instalar Plugin

```bash
# Crear directorio de plugins
mkdir -p ~/.config/yazi/plugins

# Clonar plugin de ejemplo
git clone https://github.com/usuario/plugin-name.git ~/.config/yazi/plugins/plugin-name
```

**Recursos de plugins**:
- [Yazi Plugins Wiki](https://github.com/sxyazi/yazi/wiki/Plugins)
- Plugins populares: preview mejorado, integración Git, búsqueda avanzada

## Solución de Problemas

### Iconos no se muestran

```bash
# Instalar Nerd Font
# Ubuntu/Debian
sudo apt install fonts-firacode

# macOS
brew tap homebrew/cask-fonts
brew install font-jetbrains-mono-nerd-font

# O descargar manualmente
# https://www.nerdfonts.com/font-downloads

# Configurar fuente en terminal (WezTerm):
# font = wezterm.font("JetBrainsMono Nerd Font")
```

### Preview de archivos no funciona

```bash
# Instalar herramientas de preview
# Ubuntu/Debian
sudo apt install ffmpegthumbnailer poppler-utils

# macOS
brew install ffmpegthumbnailer poppler

# Para imágenes (Linux only, macOS no soporta ueberzug)
pip install ueberzug
```

### Archivos ocultos no se muestran

```bash
# Dentro de Yazi, presionar:
z    # Toggle archivos ocultos

# O editar yazi.toml:
[mgr]
show_hidden = true
```

### Performance lento con muchos archivos

```bash
# Desactivar preview en yazi.toml
[preview]
max_width = 0
max_height = 0
```

### Tema no se aplica

```bash
# Verificar que el archivo existe
cat ~/.config/yazi/theme.toml

# Reiniciar Yazi
q  # Salir
yazi  # Volver a abrir
```

### True Color no funciona

```bash
# Verificar variable de entorno
echo $TERM
# Debería ser: xterm-256color o tmux-256color

# Configurar en .zshrc
export TERM=xterm-256color
```

## Tips Pro

### 1. Copiar Ruta al Clipboard

Agregar a `keymap.toml`:
```toml
{ on = [ "y", "p" ], exec = 'shell "echo $@ | xclip -selection clipboard" --confirm' }
```

### 2. Vista Previa de Imágenes

Requiere Ueberzug:
```bash
pip install ueberzug
```

### 3. Navegación con Marcadores

```bash
# Ir a directorio frecuente
m    # Crear marcador
'    # Volver al marcador después
```

### 4. Batch Rename

```bash
# Seleccionar archivos con Space
# Presionar 'r' para renombrar en batch
# Se abre editor de texto con lista de nombres
```

### 5. Alias de Shell

Agregar a `.zshrc`:
```bash
alias yz='yazi'
alias y='yazi'
```

## Comparación con Alternativas

| Feature | Yazi | Ranger | NNN | lf |
|---------|------|--------|-----|-----|
| Velocidad | ⚡⚡⚡ | ⚡ | ⚡⚡⚡ | ⚡⚡ |
| Preview | ✅ | ✅ | ❌ | ✅ |
| Lenguaje | Rust | Python | C | Go |
| Configuración | TOML | Python | Config | Go |
| Plugins | Lua | Python | ❌ | - |
| Vim Keys | ✅ | ✅ | ✅ | ✅ |
| UI | Moderno | Clásico | Minimalista | Minimalista |

## Comandos Rápidos

```bash
# Abrir Yazi
yazi

# Abrir en ruta específica
yazi /path/to/directory

# Usar alias (si está configurado)
yz
y
```

## Recursos Adicionales

- [Yazi Documentation](https://yazi-rs.github.io/)
- [GitHub Repository](https://github.com/sxyazi/yazi)
- [Plugins Wiki](https://github.com/sxyazi/yazi/wiki/Plugins)
- [Catppuccin Theme](https://github.com/catppuccin/catppuccin)

## Referencias

- [Yazi GitHub](https://github.com/sxyazi/yazi)
- [Vim Keybindings Guide](https://vim.rtorr.com/)
- [Rust Performance](https://www.rust-lang.org/)

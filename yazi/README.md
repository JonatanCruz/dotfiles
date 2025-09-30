# Configuración de Yazi

Gestor de archivos de terminal rápido y moderno con tema Dracula y fondo transparente.

## Características

- **Tema:** Dracula con fondo transparente
- **Navegación:** Estilo Vim (hjkl)
- **Preview:** Vista previa de archivos
- **Performance:** Escrito en Rust, extremadamente rápido
- **Editor:** Integrado con Neovim

## Estructura

```
yazi/
└── .config/yazi/
    ├── yazi.toml      # Configuración general
    ├── theme.toml     # Tema Dracula
    └── keymap.toml    # Atajos de teclado
```

## Instalación

### 1. Instalar Yazi

```bash
# Con cargo (Rust)
cargo install --locked yazi-fm yazi-cli

# O con Homebrew
brew install yazi

# Ubuntu/Debian (desde binarios)
# Descarga desde: https://github.com/sxyazi/yazi/releases
```

### 2. Aplicar con Stow

```bash
cd ~/dotfiles
stow yazi
```

### 3. Alias en Zsh

La configuración `.zshrc` incluye:
```bash
alias yz='yazi'
```

## Uso Básico

### Iniciar Yazi

```bash
yazi           # Abrir en directorio actual
yazi /path     # Abrir en ruta específica
yz             # Alias configurado
```

### Navegación Principal

**Movimiento:**
- `h` - Subir un nivel (directorio padre)
- `j` - Mover abajo
- `k` - Mover arriba
- `l` o `Enter` - Entrar a directorio / Abrir archivo

**Paneles:**
- Panel izquierdo: Directorio padre
- Panel central: Directorio actual
- Panel derecho: Vista previa

### Operaciones de Archivos

**Selección:**
- `Space` - Seleccionar/deseleccionar archivo
- `v` - Modo visual (selección múltiple)
- `V` - Deseleccionar todo

**Operaciones:**
- `y` - Copiar (yank)
- `d` - Cortar (delete/cut)
- `p` - Pegar
- `r` - Renombrar
- `D` - Eliminar permanentemente
- `c` - Crear archivo/directorio

**Búsqueda:**
- `/` - Buscar en directorio actual
- `n` - Siguiente resultado
- `N` - Resultado anterior

### Gestión de Pestañas

- `t` - Nueva pestaña
- `Tab` - Siguiente pestaña
- `Shift+Tab` - Pestaña anterior
- `1-9` - Ir a pestaña específica

### Vistas y Opciones

- `z` - Alternar archivos ocultos
- `s` - Cambiar modo de ordenamiento
- `o` - Abrir con aplicación externa
- `g` - Ir a ubicaciones rápidas:
  - `gg` - Inicio del listado
  - `G` - Final del listado
  - `gh` - Home (~)
  - `g/` - Raíz (/)

### Salir

- `q` - Salir de yazi
- `Q` - Salir de todas las pestañas

## Configuración

### yazi.toml - Comportamiento

```toml
[mgr]
show_hidden = true         # Mostrar archivos ocultos
sort_by = "alphabetical"   # Ordenar alfabéticamente
sort_dir_first = true      # Directorios primero
```

**Opciones de ordenamiento:**
- `alphabetical` - Alfabético
- `natural` - Natural (números ordenados correctamente)
- `modified` - Por fecha de modificación
- `created` - Por fecha de creación
- `size` - Por tamaño

### theme.toml - Tema Dracula

**Colores principales:**
- Rosa (`#ff79c6`) - Ruta actual
- Púrpura (`#bd93f9`) - Borde activo
- Verde (`#50fa7b`) - Modo normal
- Naranja (`#ffb86c`) - Modo selección
- Rojo (`#ff5555`) - Errores
- Gris (`#6272a4`) - Bordes y elementos inactivos

**Personalizar colores:**
Edita `theme.toml`:
```toml
[mgr]
cwd = { fg = "#ff79c6", bold = true }  # Cambia el color aquí
```

### keymap.toml - Atajos de Teclado

Actualmente vacío, usa los atajos predeterminados.

**Personalizar atajos:**
```toml
[mgr]
keymap = [
  { on = [ "<C-n>" ], exec = "arrow 1" },
  { on = [ "<C-p>" ], exec = "arrow -1" },
]
```

## Integración con Otras Herramientas

### Neovim

Los archivos de texto se abren automáticamente con Neovim:
```toml
[opener]
text = [
  { run = 'nvim "$@"', block = true },
]
```

### Abrir con Aplicación Externa

```toml
[opener]
image = [
  { run = 'feh "$@"', orphan = true },
]
video = [
  { run = 'mpv "$@"', orphan = true },
]
```

### Shell Integration

Cambia de directorio al salir:

**En .zshrc:**
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

## Plugins y Extensiones

Yazi soporta plugins escritos en Lua.

**Directorio de plugins:**
```
~/.config/yazi/plugins/
```

**Ejemplo - Plugin de preview mejorado:**
```bash
# Crear directorio de plugins
mkdir -p ~/.config/yazi/plugins

# Clonar plugin
git clone https://github.com/usuario/plugin.git ~/.config/yazi/plugins/plugin
```

Ver plugins disponibles: https://github.com/sxyazi/yazi/wiki/Plugins

## Comandos Avanzados

### Operaciones en Lote

1. Selecciona archivos con `Space` o modo visual `v`
2. Ejecuta operación (copiar, cortar, eliminar)

### Búsqueda Avanzada

```bash
# Dentro de yazi:
/pattern      # Buscar
n            # Siguiente
N            # Anterior
```

### Marcadores (Bookmarks)

- `m` - Crear marcador
- `'` - Ir a marcador

## Tips y Trucos

### Vista Previa de Imágenes

Requiere herramientas adicionales:
```bash
# Ueberzug para preview de imágenes
pip install ueberzug
```

### Integración con FZF

Buscar archivos y abrir en yazi:
```bash
# En .zshrc
yzf() {
  local file=$(fd --type f | fzf)
  [ -n "$file" ] && yazi "$(dirname "$file")"
}
```

### Copiar Ruta al Portapapeles

Requiere `xclip` o `wl-clipboard`:
```bash
# En keymap.toml
[mgr]
keymap = [
  { on = [ "y", "p" ], exec = 'shell "echo $@ | xclip -selection clipboard" --confirm' },
]
```

## Solución de Problemas

### Yazi no se ve bien

**Verifica Nerd Font:**
```bash
# Yazi requiere una Nerd Font para iconos
# Instala FiraCode Nerd Font u otra
```

**Verifica True Color:**
```bash
echo $TERM
# Debería soportar 256 colores o true color
```

### Preview no funciona

```bash
# Instala herramientas de preview
sudo apt install ffmpegthumbnailer poppler-utils

# Para imágenes
pip install ueberzug
```

### Archivos ocultos no se muestran

```bash
# Dentro de yazi, presiona:
z    # Toggle archivos ocultos

# O edita yazi.toml:
show_hidden = true
```

### Performance lento con muchos archivos

```bash
# Desactiva preview en yazi.toml:
[preview]
max_width = 0
max_height = 0
```

### Tema no se aplica

```bash
# Verifica que el archivo existe
cat ~/.config/yazi/theme.toml

# Reinicia yazi
q  # Salir
yazi  # Volver a abrir
```

## Comparación con Otros File Managers

| Feature | Yazi | Ranger | NNN | lf |
|---------|------|--------|-----|-----|
| Velocidad | ⚡⚡⚡ | ⚡ | ⚡⚡⚡ | ⚡⚡ |
| Preview | ✅ | ✅ | ❌ | ✅ |
| Lenguaje | Rust | Python | C | Go |
| Configuración | TOML | Python | - | Go |
| Plugins | Lua | Python | ❌ | - |

## Atajos de Teclado Completos

### Navegación
- `h` - Directorio padre
- `j` - Abajo
- `k` - Arriba
- `l/Enter` - Entrar/abrir
- `gg` - Inicio
- `G` - Final
- `gh` - Home
- `g/` - Raíz

### Archivos
- `Space` - Seleccionar
- `v` - Modo visual
- `V` - Deseleccionar todo
- `y` - Copiar
- `d` - Cortar
- `p` - Pegar
- `r` - Renombrar
- `D` - Eliminar
- `c` - Crear

### Búsqueda
- `/` - Buscar
- `n` - Siguiente
- `N` - Anterior
- `z` - Toggle ocultos
- `s` - Cambiar orden

### Pestañas
- `t` - Nueva pestaña
- `Tab` - Siguiente
- `Shift+Tab` - Anterior
- `1-9` - Ir a pestaña

### Otros
- `o` - Abrir con
- `m` - Marcador
- `'` - Ir a marcador
- `q` - Salir
- `Q` - Salir todo

## Referencias

- [Yazi Documentation](https://yazi-rs.github.io/)
- [GitHub Repository](https://github.com/sxyazi/yazi)
- [Plugins Wiki](https://github.com/sxyazi/yazi/wiki/Plugins)
- [Dracula Theme](https://draculatheme.com/)

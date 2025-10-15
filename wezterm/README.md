# Configuración de WezTerm

WezTerm es un emulador de terminal GPU-acelerado y multiplataforma, escrito en Rust. Esta configuración ofrece un terminal moderno con transparencia, blur y funcionalidades avanzadas.

## Características Principales

### Apariencia
- **Tema:** Catppuccin Frappe (esquema de colores suave y moderno)
- **Transparencia:** Fondo semi-transparente (60% opacidad)
- **Blur:** Efecto de desenfoque en el fondo (macOS)
- **Cursor:** Barra parpadeante
- **Sin barra de pestañas:** Interfaz minimalista
- **Decoraciones:** Solo redimensionable (sin barra de título)

### Tipografía
- **Fuente:** JetBrainsMono Nerd Font (Bold Italic)
- **Tamaño:** 14.5pt
- Incluye soporte para iconos y símbolos especiales

### Funcionalidades Avanzadas

#### Atajos de Teclado
| Atajo | Acción |
|-------|--------|
| `Ctrl + F` | Alternar pantalla completa |

#### Bindings del Mouse
| Acción | Efecto |
|--------|--------|
| `Ctrl + Click` | Abrir enlace bajo el cursor |

#### Modo Zen (Integración con Neovim)
- Soporte para el modo Zen de Neovim
- Ajusta automáticamente el tamaño de fuente
- Oculta/muestra la barra de pestañas
- Se activa mediante la variable de usuario `ZEN_MODE`

### Características Opcionales (Comentadas)

```lua
-- Imagen de fondo personalizada
config.window_background_image = "/ruta/a/tu/imagen.jpg"

-- Ajustes de brillo/saturación para la imagen
config.window_background_image_hsb = {
    brightness = 0.09,
    hue = 1.0,
    saturation = 1.5,
}
```

## Instalación

### 1. Instalar WezTerm

```bash
# macOS
brew install --cask wezterm

# O descarga directamente desde
# https://wezfurlong.org/wezterm/installation.html
```

### 2. Instalar la Fuente

```bash
# macOS
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font

# O descarga manualmente desde
# https://www.nerdfonts.com/font-downloads
```

### 3. Aplicar la Configuración con Stow

```bash
cd ~/dotfiles
stow wezterm
```

Esto creará un enlace simbólico:
```
~/.config/wezterm/wezterm.lua → ~/dotfiles/wezterm/.config/wezterm/wezterm.lua
```

### 4. Reiniciar WezTerm

Cierra y vuelve a abrir WezTerm para que los cambios tomen efecto.

## Personalización

### Cambiar el Tema

WezTerm incluye muchos esquemas de color integrados. Para cambiar el tema:

```lua
-- En wezterm.lua, cambia:
config.color_scheme = "Catppuccin Frappe"

-- Por otro tema, por ejemplo:
config.color_scheme = "Dracula (Official)"
config.color_scheme = "Tokyo Night"
config.color_scheme = "Gruvbox Dark"
```

Lista completa de temas disponibles:
```bash
wezterm ls-fonts --list-color-schemes
```

### Ajustar Transparencia

```lua
-- Valores entre 0.0 (totalmente transparente) y 1.0 (opaco)
config.window_background_opacity = 0.8  -- Menos transparente
config.window_background_opacity = 0.4  -- Más transparente
```

### Cambiar Fuente

```lua
config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 16
```

Ver fuentes disponibles:
```bash
wezterm ls-fonts
```

### Habilitar Barra de Pestañas

```lua
config.enable_tab_bar = true  -- Mostrar pestañas
```

### Agregar Imagen de Fondo

```lua
-- Descomentar y ajustar la ruta
config.window_background_image = "/Users/tu_usuario/Pictures/wallpaper.jpg"
config.window_background_image_hsb = {
    brightness = 0.09,  -- Oscurecer (0.0-1.0+)
    hue = 1.0,          -- Tono de color
    saturation = 1.5,   -- Saturación
}
```

## Comandos Útiles

```bash
# Ver información de WezTerm
wezterm --version

# Listar todas las fuentes instaladas
wezterm ls-fonts

# Listar esquemas de color disponibles
wezterm ls-fonts --list-color-schemes

# Recargar configuración (o simplemente Cmd+Q y reabrir)
# No hay comando específico, reinicia la aplicación
```

## Integración con Neovim

### Modo Zen
Esta configuración incluye soporte para el modo Zen de Neovim mediante la variable de usuario `ZEN_MODE`. Cuando activas el modo Zen en Neovim, WezTerm ajusta automáticamente:

- Tamaño de fuente
- Visibilidad de la barra de pestañas

Para usar esta característica, necesitas un plugin de Neovim como [zen-mode.nvim](https://github.com/folke/zen-mode.nvim) configurado para enviar la variable `ZEN_MODE`.

## Solución de Problemas

### Los iconos no se muestran correctamente
- Asegúrate de tener instalada una Nerd Font
- Verifica que la fuente esté seleccionada en la configuración

### La transparencia no funciona
- El efecto de blur solo funciona en macOS
- Algunos gestores de ventanas en Linux pueden no soportar transparencia
- Prueba ajustando `window_background_opacity`

### WezTerm no lee la configuración
- Verifica que el enlace simbólico esté correcto:
  ```bash
  ls -la ~/.config/wezterm/wezterm.lua
  ```
- Revisa errores en la configuración:
  ```bash
  wezterm check
  ```

### Rendimiento lento
- WezTerm está optimizado con GPU, pero si tienes problemas:
  ```lua
  config.front_end = "OpenGL"  -- o "WebGpu" por defecto
  ```

## Recursos Adicionales

- [Documentación Oficial de WezTerm](https://wezfurlong.org/wezterm/)
- [Galería de Esquemas de Color](https://wezfurlong.org/wezterm/colorschemes/index.html)
- [Nerd Fonts](https://www.nerdfonts.com/)
- [Catppuccin Theme](https://github.com/catppuccin/catppuccin)

## Alternativas de Configuración

Si prefieres otros esquemas visuales:

```lua
-- Estilo más minimalista (sin transparencia)
config.window_background_opacity = 1.0
config.macos_window_background_blur = 0

-- Cursor alternativo
config.default_cursor_style = "SteadyBlock"  -- Bloque sólido
config.default_cursor_style = "BlinkingBlock" -- Bloque parpadeante
config.default_cursor_style = "SteadyBar"     -- Barra sólida
```

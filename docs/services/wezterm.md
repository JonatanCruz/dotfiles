# WezTerm - Terminal Emulator GPU-Accelerated

Emulador de terminal moderno escrito en Rust, GPU-acelerado con configuración Lua, tema Catppuccin Mocha y transparencia.

## Características Principales

- **⚡ GPU-Accelerated**: Renderizado con WebGPU para máxima performance (120 FPS)
- **🎨 Catppuccin Mocha**: Tema púrpura/cyan con 60% transparencia
- **💻 Cross-Platform**: Linux, macOS, Windows con misma configuración
- **🔧 Lua Configuration**: Configuración como código, versionable
- **📋 Multiplexing**: Splits y tabs nativos (aunque se usa Tmux)
- **🔗 Hyperlinks**: Detección automática de URLs, paths, Git refs
- **⚡ Quick Select**: Copia rápida de hashes, UUIDs, IPs, etc.
- **🖼️ Background Blur**: Efecto de desenfoque (macOS)

## Apariencia

### Tipografía
- **Fuente**: JetBrainsMono Nerd Font (Bold Italic)
- **Tamaño**: 14.5pt
- **Iconos**: Soporte completo Nerd Font para símbolos y glyphs

### Visual
- **Transparencia**: 60% opacidad (window_background_opacity = 0.6)
- **Blur**: Efecto de desenfoque en fondo (macOS)
- **Cursor**: Barra parpadeante a 500ms
- **Tab Bar**: Oculta (se usa Tmux para gestión de ventanas)
- **Decoraciones**: Solo redimensionable, sin barra de título
- **Padding**: 8px en lados y arriba

### Performance
- **FPS máximos**: 120 FPS
- **Front-end**: WebGPU con alto rendimiento
- **Scrollback**: 10,000 líneas de historial
- **Animaciones**: 60 FPS suaves

## Keybindings Principales

### Gestión de Panes (Splits)

| Atajo | Acción |
|-------|--------|
| `Cmd + Shift + \|` | Split horizontal |
| `Cmd + Shift + _` | Split vertical |
| `Cmd + W` | Cerrar pane actual (con confirmación) |
| `Cmd + H/J/K/L` | Navegar entre panes (Vim-style) |
| `Cmd + Shift + Flechas` | Redimensionar panes |

### Gestión de Tabs

**Nota**: Los tabs están disponibles pero ocultos. Se recomienda usar Tmux.

| Atajo | Acción |
|-------|--------|
| `Cmd + T` | Nueva tab |
| `Cmd + Shift + W` | Cerrar tab |
| `Cmd + [` / `Cmd + ]` | Navegar entre tabs |
| `Cmd + Shift + [` / `Cmd + Shift + ]` | Mover tab |
| `Cmd + 1-9` | Ir a tab específica (1-8), 9 = última |
| `Cmd + Shift + R` | Renombrar tab |

### Utilidades de Desarrollo

| Atajo | Acción |
|-------|--------|
| `Cmd + K` | Limpiar terminal y scrollback |
| `Cmd + F` | Buscar en terminal |
| `Cmd + Shift + Space` | Quick Select (copiar hashes, URLs, IPs) |
| `Cmd + C` / `Cmd + V` | Copiar/Pegar |
| `Cmd + Shift + P` | Command Palette |
| `Cmd + Enter` | Modo de copia |
| `Ctrl + F` | Toggle pantalla completa |

### Zoom

| Atajo | Acción |
|-------|--------|
| `Cmd + =` | Aumentar tamaño de fuente |
| `Cmd + -` | Disminuir tamaño de fuente |
| `Cmd + 0` | Restablecer tamaño de fuente |

### Mouse Bindings

| Acción | Efecto |
|--------|--------|
| `Ctrl + Click` | Abrir enlace bajo el cursor |
| `Click Derecho` | Pegar desde clipboard |

## Hyperlink Detection

WezTerm detecta automáticamente y hace clickeables:

- **URLs estándar**: http, https, ftp
- **Referencias GitHub/GitLab**: `usuario/repo#123`
- **Paths absolutos**: `/ruta/al/archivo`
- **URLs localhost**: `localhost:3000`, `localhost:8080`, etc.
- **JIRA Tickets** (customizable): `JIRA-1234`

**Ejemplo de personalización**:
```lua
table.insert(config.hyperlink_rules, {
  regex = [[\bJIRA-\d+\b]],
  format = "https://your-company.atlassian.net/browse/$0",
})
```

## Quick Select Patterns

Con `Cmd + Shift + Space` puedes seleccionar rápidamente:

| Pattern | Ejemplo | Uso |
|---------|---------|-----|
| **Git commit hashes** | `7a3f2e1` | 7-40 caracteres hex |
| **UUIDs** | `550e8400-e29b-41d4-a716` | Formato estándar |
| **IPs** | `192.168.1.1` | xxx.xxx.xxx.xxx |
| **Kubernetes Pods** | `app-5f6c7d8-9xfgh` | nombre-hash-hash |
| **Versiones semánticas** | `v1.2.3` o `1.2.3` | SemVer |
| **Colores hex** | `#ff5733` | Códigos de color |
| **Container IDs** | `a1b2c3d4e5f6` | 12 caracteres hex |

**Workflow**:
1. Aparece un hash en el log
2. `Cmd + Shift + Space`
3. El hash se resalta automáticamente
4. Enter para copiar al clipboard

## Filosofía: WezTerm + Tmux

Esta configuración **oculta la tab bar de WezTerm** y delega la gestión a **Tmux**:

**Razones**:
- **Evitar confusión**: No hay tabs duplicados
- **Consistencia**: Todos los atajos son de Tmux
- **Sesiones persistentes**: Tmux permite recuperar sesiones
- **Mejor integración**: Navegación uniforme con vim-tmux-navigator

### Workflow Recomendado

1. **WezTerm**: Emulador de terminal (transparencia, fuente, rendimiento)
2. **Tmux**: Gestión de splits, ventanas y sesiones
3. **Panes de WezTerm**: Disponibles pero opcionales (para splits sin Tmux)

**Ejemplo de workspace**:
```
┌─────────────┬─────────────┐
│             │             │
│   Neovim    │   Servidor  │
│   Editor    │   npm run   │
│             │             │
├─────────────┴─────────────┤
│                           │
│   Terminal / Git          │
│                           │
└───────────────────────────┘
```

**Proceso**:
1. Abre WezTerm
2. Inicia Tmux: `tmux`
3. `Prefix + |`: Split vertical
4. `Prefix + -`: Split horizontal
5. `Ctrl + H/J/K/L`: Navega entre panes (tmux-navigator)

## Integración con Neovim

### Modo Zen

WezTerm incluye soporte para el modo Zen de Neovim mediante la variable `ZEN_MODE`.

Cuando activas el modo Zen en Neovim, WezTerm ajusta automáticamente:
- Tamaño de fuente (incrementa o resetea)
- Visibilidad de la barra de pestañas
- Se activa/desactiva automáticamente

**Requiere**: Plugin [zen-mode.nvim](https://github.com/folke/zen-mode.nvim) configurado para enviar la variable `ZEN_MODE`.

## Personalización

### Cambiar el Tema

WezTerm incluye 200+ esquemas integrados:

```lua
-- En wezterm.lua, cambiar:
config.color_scheme = "Catppuccin Mocha"

-- Otros temas de Catppuccin:
config.color_scheme = "Catppuccin Latte"   -- Claro
config.color_scheme = "Catppuccin Frappe"  -- Oscuro suave
config.color_scheme = "Catppuccin Macchiato" -- Oscuro medio

-- Otros temas populares:
config.color_scheme = "Dracula (Official)"
config.color_scheme = "Tokyo Night"
config.color_scheme = "Gruvbox Dark"
```

**Ver todos los temas disponibles**:
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

**Ver fuentes instaladas**:
```bash
wezterm ls-fonts
```

### Habilitar Tab Bar (Opcional)

Si prefieres no usar Tmux y quieres ver las tabs de WezTerm:

```lua
config.enable_tab_bar = true  -- Mostrar pestañas
config.hide_tab_bar_if_only_one_tab = true  -- Ocultar si solo hay una
```

### Agregar Imagen de Fondo

```lua
config.window_background_image = "/Users/tu_usuario/Pictures/wallpaper.jpg"
config.window_background_image_hsb = {
    brightness = 0.09,  -- Oscurecer (0.0-1.0+)
    hue = 1.0,          -- Tono de color
    saturation = 1.5,   -- Saturación
}
```

## Casos de Uso para Desarrollo

### Workflow 1: Desarrollo con Tmux (Recomendado)

```bash
# 1. Abrir WezTerm
# 2. Iniciar Tmux
tmux

# 3. Crear layout de desarrollo
Prefix + |    # Split vertical
Prefix + -    # Split horizontal

# Layout típico:
# ┌──────────────┬──────────────┐
# │   Neovim     │   Servidor   │
# │   Editor     │   npm run    │
# ├──────────────┴──────────────┤
# │   Terminal / Git             │
# └──────────────────────────────┘
```

### Workflow 2: Proyectos con Tmux Windows

```bash
# Ventana 1: Frontend
nvim .                  # Editor
Prefix + |              # Split
npm run dev             # Servidor

# Ventana 2: Backend
nvim api/               # Editor Backend
Prefix + |
npm run server          # API server

# Ventana 3: Base de datos
docker-compose up       # DB containers

# Cambiar entre ventanas: Prefix + número
```

### Workflow 3: Quick Select en Acción

```bash
# 1. Comando con salida de Git
git log --oneline

# 2. Aparece: 7a3f2e1 feat: add auth

# 3. Presionar: Cmd + Shift + Space
# 4. Hash se resalta automáticamente
# 5. Enter para copiar
# 6. git show 7a3f2e1  # Pegar hash copiado
```

### Workflow 4: Buscar en Output

```bash
# 1. Comando genera mucha salida
npm run build

# 2. Presionar: Cmd + F
# 3. Buscar: "ERROR" o "warning"
# 4. Navegar entre resultados
# 5. Esc para salir
```

## Comandos Útiles

```bash
# Ver versión de WezTerm
wezterm --version

# Listar fuentes instaladas
wezterm ls-fonts

# Listar esquemas de color disponibles
wezterm ls-fonts --list-color-schemes

# Verificar configuración (errores de sintaxis)
wezterm check

# Reiniciar WezTerm
# (No hay comando específico, cerrar y reabrir)
```

## Solución de Problemas

### Iconos no se muestran

```bash
# Instalar Nerd Font
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font

# Verificar que la fuente esté configurada
cat ~/.config/wezterm/wezterm.lua | grep font
```

### Transparencia no funciona

- El efecto de blur solo funciona en macOS
- Algunos gestores de ventanas en Linux pueden no soportar transparencia
- Prueba ajustando `window_background_opacity`

### WezTerm no lee la configuración

```bash
# Verificar enlace simbólico
ls -la ~/.config/wezterm/wezterm.lua

# Debería apuntar a: ~/dotfiles/wezterm/.config/wezterm/wezterm.lua

# Verificar errores en configuración
wezterm check
```

### Performance lento

```bash
# Cambiar front-end en wezterm.lua
config.front_end = "OpenGL"  # o "WebGpu" (por defecto)
```

### Hyperlinks no funcionan

```bash
# Verificar que Ctrl+Click esté configurado
# En wezterm.lua debería haber:
# { mods = 'CTRL', event = { Up = { streak = 1, button = 'Left' } }, action = act.OpenLinkAtMouseCursor }
```

## Tips y Mejores Prácticas

### 1. Renombrar Tabs para Contextos

```bash
# Cmd + Shift + R
# Nombres sugeridos:
- "Frontend" (React/Vue project)
- "API" (backend server)
- "DB" (database management)
- "Monitoring" (logs y monitoreo)
```

### 2. Aprovechar Quick Select

**Casos de uso**:
- **Docker**: Copiar container IDs rápidamente
- **Git**: Copiar commit hashes para cherry-pick o revert
- **Debugging**: Copiar UUIDs o IPs de logs
- **URLs**: Copiar localhost URLs para compartir

### 3. Command Palette para Descubrir Funciones

```bash
# Cmd + Shift + P
# Ver todas las acciones disponibles
# Útil para descubrir comandos y configuraciones
```

### 4. Personalizar Quick Select Patterns

```lua
-- En wezterm.lua
config.quick_select_patterns = {
  -- Patterns existentes...

  -- Ticket IDs (ej: JIRA-1234)
  "[A-Z]+-\\d+",

  -- Branches de Git
  "feature/[a-z0-9-]+",
  "bugfix/[a-z0-9-]+",
}
```

### 5. Custom Cursor Styles

```lua
-- Estilo minimalista (sin transparencia)
config.window_background_opacity = 1.0
config.macos_window_background_blur = 0

-- Cursor alternativo
config.default_cursor_style = "SteadyBlock"  -- Bloque sólido
config.default_cursor_style = "BlinkingBlock" -- Bloque parpadeante
config.default_cursor_style = "SteadyBar"     -- Barra sólida
```

## Comparación: WezTerm vs Alternativas

| Característica | WezTerm | iTerm2 | Alacritty | Kitty |
|----------------|---------|--------|-----------|-------|
| GPU Acelerado | ✅ | ✅ | ✅ | ✅ |
| Multiplexing Nativo | ✅ | ✅ | ❌ | ✅ |
| Hyperlinks | ✅ | ✅ | ✅ | ✅ |
| Lua Config | ✅ | ❌ | ❌ | ❌ |
| Cross-platform | ✅ | ❌ (solo macOS) | ✅ | ✅ |
| Splits/Panes | ✅ | ✅ | ❌ | ✅ |
| Transparencia/Blur | ✅ | ✅ | ✅ | ✅ |

**Por qué WezTerm para Desarrollo**:
- Configuración como código (Lua), versionable
- Multiplexing integrado (aunque usamos Tmux)
- Quick Select para copiar patterns comunes
- Rendimiento GPU-acelerado
- Cross-platform (misma config en macOS, Linux, Windows)

## Recursos Adicionales

- [WezTerm Documentation](https://wezfurlong.org/wezterm/)
- [Color Schemes Gallery](https://wezfurlong.org/wezterm/colorschemes/index.html)
- [Nerd Fonts](https://www.nerdfonts.com/)
- [Catppuccin for WezTerm](https://github.com/catppuccin/wezterm)

## Referencias

- [WezTerm GitHub](https://github.com/wez/wezterm)
- [Lua Programming](https://www.lua.org/)
- [WebGPU Specification](https://www.w3.org/TR/webgpu/)

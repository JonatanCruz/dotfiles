# Configuración de WezTerm para Desarrollo

WezTerm es un emulador de terminal GPU-acelerado y multiplataforma, escrito en Rust. Esta configuración está optimizada para **desarrollo de software** con funcionalidades avanzadas, keybindings intuitivos y herramientas para mejorar la productividad.

## 🎨 Características Principales

### Apariencia
- **Tema:** Catppuccin Frappe (esquema de colores suave y moderno)
- **Transparencia:** Fondo semi-transparente (60% opacidad)
- **Blur:** Efecto de desenfoque en el fondo (macOS)
- **Cursor:** Barra parpadeante (500ms)
- **Tab Bar:** Oculta (se usa tmux para gestión de ventanas/tabs)
- **Decoraciones:** Solo redimensionable (sin barra de título)
- **Padding:** 8px en los lados y arriba para mejor aspecto

### Tipografía
- **Fuente:** JetBrainsMono Nerd Font (Bold Italic)
- **Tamaño:** 14.5pt
- Incluye soporte para iconos y símbolos especiales

### Rendimiento
- **FPS máximos:** 120 FPS
- **Front-end:** WebGPU con alto rendimiento
- **Scrollback:** 10,000 líneas de historial
- **Animaciones:** 60 FPS

## ⌨️ Atajos de Teclado

### Gestión de Panes (Splits)
| Atajo | Acción |
|-------|--------|
| `Cmd + Shift + \|` | Split horizontal |
| `Cmd + Shift + _` | Split vertical |
| `Cmd + W` | Cerrar pane actual (con confirmación) |
| `Cmd + H/J/K/L` | Navegar entre panes (estilo Vim) |
| `Cmd + Shift + Flechas` | Redimensionar panes |

### Gestión de Tabs
**Nota:** Los tabs están disponibles pero ocultos visualmente. Se recomienda usar **tmux** para gestión de ventanas.

| Atajo | Acción |
|-------|--------|
| `Cmd + T` | Nueva tab (WezTerm) |
| `Cmd + Shift + W` | Cerrar tab (con confirmación) |
| `Cmd + [` / `Cmd + ]` | Navegar entre tabs |
| `Cmd + Shift + [` / `Cmd + Shift + ]` | Mover tab |
| `Cmd + 1-9` | Ir a tab específica (1-8), 9 = última |
| `Cmd + Shift + R` | Renombrar tab actual |

### Utilidades de Desarrollo
| Atajo | Acción |
|-------|--------|
| `Cmd + K` | Limpiar terminal y scrollback |
| `Cmd + F` | Buscar en terminal |
| `Cmd + Shift + Space` | Quick Select (copiar hashes, URLs, IPs, etc.) |
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

## 🖱️ Bindings del Mouse
| Acción | Efecto |
|--------|--------|
| `Ctrl + Click` | Abrir enlace bajo el cursor |
| `Click Derecho` | Pegar desde clipboard |

## 🔗 Hyperlink Rules (Detección Automática)

La configuración detecta automáticamente y hace clickeables:
- URLs estándar (http, https)
- Referencias de GitHub/GitLab (`usuario/repo#123`)
- Paths de archivos absolutos (`/ruta/al/archivo`)
- URLs de localhost (`localhost:3000`, `localhost:8080`, etc.)

## 🎯 Quick Select Patterns

Con `Cmd + Shift + Space` puedes seleccionar rápidamente:
- **Git commit hashes** (7-40 caracteres hex)
- **UUIDs** (formato estándar)
- **IPs** (formato xxx.xxx.xxx.xxx)
- **Pods de Kubernetes** (formato nombre-hash-hash)
- **Versiones semánticas** (v1.2.3 o 1.2.3)
- **Colores hex** (#ff5733)
- **Container IDs de Docker** (12 caracteres hex)

## 💼 Filosofía de Uso: WezTerm + Tmux

Esta configuración oculta la tab bar de WezTerm y delega la gestión de ventanas/paneles a **tmux** para:

- **Evitar confusión:** No hay tabs duplicados entre WezTerm y tmux
- **Consistencia:** Todos los atajos de navegación son de tmux
- **Sesiones persistentes:** tmux permite recuperar sesiones después de reiniciar
- **Mejor integración:** Navegación uniforme entre panes con `Ctrl+h/j/k/l` (tmux-navigator)

### Workflow recomendado
1. **WezTerm:** Úsalo como el emulador de terminal base (transparencia, fuente, rendimiento)
2. **Tmux:** Úsalo para splits, ventanas y sesiones
3. **Panes de WezTerm:** Disponibles pero opcionales (si necesitas splits sin tmux)

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

### Habilitar Barra de Pestañas (opcional)

Si prefieres no usar tmux y quieres ver las tabs de WezTerm:

```lua
config.enable_tab_bar = true  -- Mostrar pestañas
config.hide_tab_bar_if_only_one_tab = true  -- Ocultar si solo hay una
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

## 🧘 Integración con Neovim

### Modo Zen
Esta configuración incluye soporte para el modo Zen de Neovim mediante la variable de usuario `ZEN_MODE`. Cuando activas el modo Zen en Neovim, WezTerm ajusta automáticamente:

- Tamaño de fuente (incrementa o resetea)
- Visibilidad de la barra de pestañas
- Se activa/desactiva automáticamente

Para usar esta característica, necesitas un plugin de Neovim como [zen-mode.nvim](https://github.com/folke/zen-mode.nvim) configurado para enviar la variable `ZEN_MODE`.

## 💡 Casos de Uso para Desarrollo

### Workflow con Tmux (Recomendado)
```
┌─────────────┬─────────────┐
│             │             │
│   Neovim    │   Servidor  │
│   Editor    │   (npm run) │
│             │             │
├─────────────┴─────────────┤
│                           │
│   Terminal / Git          │
│                           │
└───────────────────────────┘
```
1. Abre WezTerm
2. Inicia tmux: `tmux`
3. `Prefix + |`: Crea un split vertical
4. `Prefix + -`: Crea un split horizontal
5. `Ctrl + H/J/K/L`: Navega entre panes (tmux-navigator)

### Organización por Proyectos con Tmux
- **Ventana 1:** Proyecto Frontend (Neovim + servidor)
- **Ventana 2:** Proyecto Backend (API + logs)
- **Ventana 3:** Base de datos (cliente DB)
- **Ventana 4:** Monitoreo (docker-compose, htop)

Usa `Prefix + número` para saltar entre ventanas de tmux.

### Quick Select en Acción
1. Aparece un hash de commit en el log: `7a3f2e1`
2. Presiona `Cmd + Shift + Space`
3. El hash se resalta automáticamente
4. Enter para copiar al clipboard
5. Úsalo donde lo necesites

### Buscar en Terminal
1. Ejecutas un comando que genera mucha salida
2. `Cmd + F` para buscar
3. Escribe el término (ej: "ERROR", "localhost", etc.)
4. Navega entre resultados
5. `Esc` para salir

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

## 🎨 Alternativas de Configuración

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

## 🚀 Tips y Mejores Prácticas

### 1. Usar Tabs para Contextos Diferentes
Renombra tus tabs con `Cmd + Shift + R` para identificarlas fácilmente:
- "Frontend" para tu proyecto React/Vue
- "API" para el backend
- "DB" para gestión de base de datos
- "Monitoring" para logs y monitoreo

### 2. Aprovechar Quick Select
Cuando trabajas con:
- **Docker:** Copia rápidamente container IDs
- **Git:** Copia commit hashes para cherry-pick o revert
- **Debugging:** Copia UUIDs o IPs de logs
- **URLs:** Copia localhost URLs para compartir

### 3. Command Palette para Descubrir Funciones
Presiona `Cmd + Shift + P` para ver todas las acciones disponibles. Es útil para:
- Descubrir nuevos comandos
- Ejecutar acciones menos frecuentes
- Explorar configuraciones

### 4. Combinación con Tmux
Esta configuración tiene splits nativos, pero puedes usar Tmux dentro de WezTerm para:
- Sesiones persistentes
- Trabajar en servidores remotos
- Sincronización de panes

### 5. Workflow Recomendado con Tmux
```bash
# Inicia tmux
tmux

# Ventana 0 (tmux): Desarrollo principal
nvim .

# Crea nueva ventana (Prefix + c)
# Ventana 1: Servidor de desarrollo
Prefix + |  # Split vertical
# Izquierda: npm run dev
# Derecha: logs del servidor

# Crea nueva ventana
# Ventana 2: Git y testing
git status
Prefix + -  # Split horizontal para tests watch mode

# Crea nueva ventana
# Ventana 3: Docker/Infra
docker-compose logs -f
```

## 🔧 Personalización Avanzada

### Agregar Más Patterns a Quick Select
Edita `wezterm.lua` y agrega patrones personalizados:

```lua
config.quick_select_patterns = {
  -- Tus patterns existentes...

  -- Ticket IDs (ej: JIRA-1234)
  "[A-Z]+-\\d+",

  -- Branches de Git
  "feature/[a-z0-9-]+",
  "bugfix/[a-z0-9-]+",
}
```

### Crear Hyperlinks Personalizados
Para proyectos específicos o herramientas internas:

```lua
-- Ejemplo: Links a tickets de Jira
table.insert(config.hyperlink_rules, {
  regex = [[\bJIRA-\d+\b]],
  format = "https://your-company.atlassian.net/browse/$0",
})
```

### Configurar Workspaces Predefinidos
Puedes crear keybindings para cambiar entre workspaces:

```lua
{
  key = "1",
  mods = "CTRL|SHIFT",
  action = act.SwitchToWorkspace({
    name = "frontend",
    spawn = { cwd = "~/projects/my-app/frontend" },
  }),
},
```

## 📊 Comparación: WezTerm vs Alternativas

| Característica | WezTerm | iTerm2 | Alacritty | Kitty |
|----------------|---------|--------|-----------|-------|
| GPU Acelerado | ✅ | ✅ | ✅ | ✅ |
| Multiplexing Nativo | ✅ | ✅ | ❌ | ✅ |
| Ligands/Hyperlinks | ✅ | ✅ | ✅ | ✅ |
| Lua Config | ✅ | ❌ | ❌ | ❌ |
| Cross-platform | ✅ | ❌ | ✅ | ✅ |
| Splits/Panes | ✅ | ✅ | ❌ | ✅ |
| Transparencia/Blur | ✅ | ✅ | ✅ | ✅ |

### Por qué WezTerm para Desarrollo
- **Configuración como código:** Todo en Lua, versionable
- **Multiplexing integrado:** No necesitas tmux para splits básicos
- **Quick Select:** Copia patterns comunes sin seleccionar con el mouse
- **Rendimiento:** GPU-acelerado, rápido incluso con mucha salida
- **Cross-platform:** Misma config en macOS, Linux y Windows

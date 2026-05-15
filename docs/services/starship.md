# Starship - Prompt Moderno y Personalizado

Prompt minimalista, rápido y altamente configurable escrito en Rust con tema Catppuccin Mocha.

## Características Principales

- **🎨 Catppuccin Mocha**: Esquema de colores púrpura/cyan unificado
- **⚡ Extremadamente Rápido**: Escrito en Rust, prompt instantáneo
- **🔍 Contextual**: Muestra información relevante según el directorio
- **📦 Módulos**: Git, Node, Python, Rust, Docker, Kubernetes y más
- **🌐 Cross-Platform**: Funciona en Linux, macOS y Windows
- **💻 Multi-Shell**: Compatible con Zsh, Bash, Fish, PowerShell

## Módulos Activos

### Git Integration
- **Branch actual**: Nombre de la rama con ícono
- **Estado de cambios**: Archivos modificados, staged, conflictos
- **Estado de sincronización**: Commits adelante/atrás con respecto al remote
- **Stash count**: Número de stashes guardados

### Lenguajes y Herramientas
- **Node.js**: Versión de Node cuando detecta `package.json`
- **Python**: Versión de Python en proyectos Python
- **Rust**: Versión de Rust en proyectos Cargo
- **Go**: Versión de Go en proyectos Go
- **.NET**: Versión de .NET en proyectos C#
- **Bun** 🍞: Versión de Bun cuando detecta `bun.lockb` (color pink `#f5c2e7`)
- **Docker**: Contexto de Docker activo
- **Kubernetes**: Contexto y namespace actual

### Sistema
- **Username**: Muestra usuario si no es el predeterminado
- **Hostname**: Muestra hostname en conexiones SSH
- **Directory**: Path actual con truncamiento inteligente
- **Command Duration**: Duración de comandos que tardan >2 segundos
- **Exit Code**: Indicador de error cuando el comando falla

### Modo Vi (Zsh)
- Indicador de modo: `NORMAL`, `INSERT`, `VISUAL`
- Cambia de color según el modo activo

## Configuración

### Archivo Principal: starship.toml

```toml
format = """
[┌───────────────────>](bold green)
[│](bold green)$username\
$hostname\
$localip\
$directory\
$git_branch\
$git_state\
$git_status\
$docker_context\
$package\
$c\
$cmake\
...
$line_break\
[└─>](bold green) """

add_newline = true
```

### Colores Catppuccin Mocha

**Colores principales**:
- Rosewater: `#f5e0dc` - Username en SSH
- Flamingo: `#f2cdcd` - Hostname
- Pink: `#f5c2e7` - Usuario y path actual
- Mauve: `#cba6f7` - Git branch, modo Vi normal
- Red: `#f38ba8` - Errores y conflictos
- Maroon: `#eba0ac` - Stashed files
- Peach: `#fab387` - Archivos sin track
- Yellow: `#f9e2af` - Cambios modificados
- Green: `#a6e3a1` - Símbolos de éxito, modo Vi insert
- Teal: `#94e2d5` - Docker, Kubernetes
- Sky: `#89dceb` - Módulos de lenguajes
- Sapphire: `#74c7ec` - Git status
- Blue: `#89b4fa` - Directorio
- Lavender: `#b4befe` - Command duration

### Directory Truncation

```toml
[directory]
truncation_length = 3
truncate_to_repo = true
format = "[$path]($style)[$read_only]($read_only_style) "
style = "bold cyan"
read_only = " 󰌾"
```

Muestra hasta 3 niveles de profundidad, trunca al root del repositorio Git.

### Git Configuration

```toml
[git_branch]
symbol = " "
truncation_length = 30
format = "[$symbol$branch(:$remote_branch)]($style) "

[git_status]
format = '([\[$all_status$ahead_behind\]]($style) )'
conflicted = " 🏳"
ahead = " ⇡${count}"
behind = " ⇣${count}"
diverged = " ⇕⇡${ahead_count}⇣${behind_count}"
up_to_date = " ✓"
untracked = " ?${count}"
stashed = " 📦${count}"
modified = " !${count}"
staged = " +${count}"
renamed = " »${count}"
deleted = " ✘${count}"
```

### Command Duration

```toml
[cmd_duration]
min_time = 2_000
format = "took [$duration](bold yellow) "
```

Solo muestra duración si el comando tardó más de 2 segundos.

### Modo Vi Indicator

```toml
[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
vimcmd_symbol = "[❮](bold green)"

# En modo Vi de Zsh
vicmd_symbol = "[❮](bold green)"
```

## Uso Básico

### Ver Información del Prompt

El prompt se actualiza automáticamente según el contexto:

```bash
# En directorio normal
~/projects ❯

# En repositorio Git
~/dotfiles main ❯

# Con cambios sin commitear
~/dotfiles main [!2 ?1] ❯

# Después de comando largo
~/dotfiles main [✓] took 5.2s ❯

# Con versión de Node
~/app main  v18.17.0 ❯
```

### SSH Hostname Display

Cuando te conectas vía SSH, Starship muestra el hostname:

```bash
user@server ~/projects ❯
```

### Interpretar Símbolos Git

| Símbolo | Significado |
|---------|-------------|
| `✓` | Branch actualizada con remote |
| `!2` | 2 archivos modificados |
| `?3` | 3 archivos sin track |
| `+1` | 1 archivo en staging |
| `⇡2` | 2 commits adelante del remote |
| `⇣1` | 1 commit atrás del remote |
| `📦1` | 1 stash guardado |
| `🏳` | Conflictos de merge |

## Personalización

### Cambiar Tema

Starship soporta múltiples esquemas:

```bash
# Descargar un preset
starship preset gruvbox-rainbow -o ~/.config/starship.toml

# O nerd-font-symbols
starship preset nerd-font-symbols -o ~/.config/starship.toml

# Ver presets disponibles
starship preset --list
```

**Presets populares**:
- `catppuccin-mocha` (actual)
- `gruvbox-rainbow`
- `nerd-font-symbols`
- `pure-preset`
- `tokyo-night`
- `pastel-powerline`

### Agregar Nuevo Módulo

Ejemplo: agregar módulo de AWS:

```toml
[aws]
format = 'on [$symbol($profile )(\($region\) )]($style)'
symbol = "☁️ "
style = "bold yellow"
disabled = false

[aws.region_aliases]
us-east-1 = "virginia"
eu-west-1 = "ireland"
```

### Deshabilitar Módulos

```toml
[nodejs]
disabled = true

[python]
disabled = true
```

### Modificar Formato Global

```toml
# Cambiar el formato del prompt completo
format = """
$username\
$hostname\
$directory\
$git_branch\
$git_status\
$character
"""
```

## Integración con Zsh

### Inicialización

En `.zshrc`:
```bash
eval "$(starship init zsh)"
```

**Importante**: Esta línea DEBE estar al final del archivo, después de todos los plugins de Zsh.

### Modo Vi Integration

Starship detecta automáticamente el modo Vi de Zsh y cambia el indicador:
- `❯` (verde) - Modo insert
- `❮` (verde) - Modo normal

### Variables de Entorno

```bash
# Configurar archivo de configuración personalizado
export STARSHIP_CONFIG=~/custom/starship.toml

# Habilitar logs de debug
export STARSHIP_LOG=trace
```

## Módulos Condicionales

### Mostrar solo en SSH

```toml
[hostname]
ssh_only = true
format = "[$hostname](bold red) "
```

### Mostrar solo en Git repos

```toml
[git_status]
disabled = false
# Solo se muestra si estás en un repositorio Git
```

### Detectar Python Virtual Env

```toml
[python]
symbol = "🐍 "
pyenv_version_name = true
format = 'via [${symbol}${pyenv_prefix}(${version} )(\($virtualenv\) )]($style)'
```

## Performance

### Benchmarking

Starship es extremadamente rápido:

```bash
# Medir tiempo de renderizado
time starship prompt
```

Típicamente: **<10ms** en proyectos normales, **<50ms** en repos Git grandes.

### Optimización

```toml
# Escanear menos directorios para detectar proyectos
[directory]
truncation_length = 8
truncate_to_repo = true

# Reducir escaneo de Git
[git_status]
disabled = false
# Starship cachea automáticamente resultados de Git
```

## Troubleshooting

### Prompt no aparece

```bash
# Verificar que starship está instalado
which starship

# Verificar inicialización en .zshrc
grep starship ~/.zshrc

# Debería mostrar:
# eval "$(starship init zsh)"

# Reiniciar shell
exec zsh
```

### Iconos no se muestran

```bash
# Instalar Nerd Font
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font

# Configurar fuente en terminal
# WezTerm: font = wezterm.font("JetBrainsMono Nerd Font")
```

### Git status lento

```bash
# En repos grandes, considerar deshabilitar algunos campos
[git_status]
disabled = false
ahead = ""
behind = ""
diverged = ""
untracked = ""
```

### Configuración no se aplica

```bash
# Verificar ubicación del archivo
echo $STARSHIP_CONFIG
ls ~/.config/starship.toml

# Verificar sintaxis TOML
starship config

# Ver errores de configuración
starship explain
```

## Tips y Mejores Prácticas

### 1. Modo Compact para Directorios Largos

```toml
[directory]
truncation_length = 1
fish_style_pwd_dir_length = 1
# Muestra: ~/p/m/project en lugar de ~/projects/my-app/project
```

### 2. Resaltar Errores

```toml
[character]
error_symbol = "[✗](bold red)"
success_symbol = "[➜](bold green)"
```

### 3. Agregar Timestamp

```toml
[time]
disabled = false
format = '🕙[\[ $time \]]($style) '
time_format = "%T"
style = "bold white"
```

### 4. Custom Prompt Indicator

```toml
[character]
success_symbol = "[λ](bold green)"
error_symbol = "[λ](bold red)"
```

### 5. Indicador de Battery (Laptop)

```toml
[battery]
full_symbol = "🔋"
charging_symbol = "⚡️"
discharging_symbol = "💀"

[[battery.display]]
threshold = 30
style = "bold red"
```

## Comandos Útiles

```bash
# Ver configuración actual
starship config

# Explicar por qué un módulo no aparece
starship explain

# Generar configuración de ejemplo
starship preset --help

# Ver versión
starship --version

# Limpiar caché
starship cache clear
```

## Comparación con Alternativas

| Feature | Starship | Oh My Zsh | Powerlevel10k |
|---------|----------|-----------|---------------|
| Velocidad | ⚡⚡⚡ | ⚡ | ⚡⚡ |
| Configuración | TOML sencillo | Compleja | Wizard |
| Cross-shell | ✅ | ❌ | ❌ |
| Lenguaje | Rust | Shell | Shell |
| Módulos | 100+ | 250+ | 150+ |
| Personalización | Alta | Media | Alta |

## Recursos Adicionales

- [Starship Documentation](https://starship.rs/)
- [Configuration Examples](https://starship.rs/presets/)
- [Catppuccin for Starship](https://github.com/catppuccin/starship)
- [Advanced Configuration](https://starship.rs/advanced-config/)

## Referencias

- [Starship GitHub](https://github.com/starship/starship)
- [Nerd Fonts](https://www.nerdfonts.com/)
- [TOML Specification](https://toml.io/)

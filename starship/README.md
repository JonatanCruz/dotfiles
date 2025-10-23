# Configuración de Starship

Prompt minimalista y rápido con tema Catppuccin Mocha personalizado.

## Características

- **Tema:** Catppuccin Mocha con colores personalizados
- **Rendimiento:** Ultra rápido, escrito en Rust
- **Información contextual:** Muestra solo lo relevante
- **Modo Vi:** Indicador visual del modo actual
- **Git:** Información completa del repositorio

## Estructura

```
starship/
└── .config/
    └── starship.toml    # Configuración del prompt
```

## Instalación

### 1. Instalar Starship

```bash
curl -sS https://starship.rs/install.sh | sh
```

O con Homebrew:
```bash
brew install starship
```

### 2. Aplicar con Stow

```bash
cd ~/dotfiles
stow starship
```

### 3. Verificar Integración con Zsh

La configuración de `.zshrc` ya incluye:
```bash
eval "$(starship init zsh)"
```

Debería ser la **última línea** del archivo.

## Apariencia del Prompt

**Local (macOS/Linux):**
```
 ~/dotfiles  main M U took 2s
➜
```

**Remoto (SSH):**
```
  servidor-prod ~/proyecto  main
➜
```

**Elementos mostrados:**
1. 💻 **Sistema operativo** (azul) - Siempre visible
2. 🌐 **Hostname** (amarillo) - Solo en SSH (remoto)
3. 📁 **Directorio actual** (rosa)
4. 🌿 **Rama de Git** (púrpura)
5. 📊 **Estado de Git** (púrpura)
6. ⚡ **Node.js version** (verde, solo en proyectos Node)
7. ⏱️ **Duración del comando** (naranja, si >1s)
8. ➜ **Símbolo del prompt** (verde/rojo según estado)

## Colores Catppuccin Mocha

| Elemento | Color | Hex |
|----------|-------|-----|
| Sistema operativo | Azul | `#89b4fa` |
| Hostname (SSH) | Amarillo | `#f9e2af` |
| Directorio | Rosa | `#f5c2e7` |
| Git branch/status | Mauve | `#cba6f7` |
| Node.js | Verde | `#a6e3a1` |
| Duración | Peach | `#fab387` |
| Prompt OK | Verde | `#a6e3a1` |
| Prompt Error | Rojo | `#f38ba8` |
| Modo Vi | Mauve | `#cba6f7` |

## Módulos Configurados

### OS (Sistema Operativo)

Muestra un ícono discreto del sistema operativo actual. **Siempre visible** para identificar rápidamente el entorno.

```toml
[os]
disabled = false
style = "#89b4fa"  # Blue Catppuccin Mocha
format = "[$symbol]($style) "
```

**Íconos por sistema:**
-  macOS
-  Linux
-  Windows
-  Ubuntu
-  Debian
-  Fedora
-  Arch Linux

**Ejemplo:**
```
 ~/dotfiles  # macOS
 ~/dotfiles  # Linux genérico
```

### Hostname (SSH)

Muestra el nombre del servidor **solo cuando estás conectado por SSH**. Útil para distinguir entre sesiones locales y remotas.

```toml
[hostname]
ssh_only = true           # Solo en SSH
ssh_symbol = " "         # Símbolo de conexión remota
style = "#f9e2af"         # Yellow Catppuccin Mocha
format = "[$ssh_symbol$hostname]($style) "
trim_at = "."             # Muestra solo hasta el primer punto
```

**Ejemplos:**

**Local (sin SSH):**
```
 ~/proyecto  # Sin hostname
```

**Remoto (SSH):**
```
  servidor-prod ~/proyecto   # Con hostname visible
  web-01 ~/app              # Hostname truncado en el primer punto
```

**Beneficios:**
- ⚡ **Identificación rápida** - Sabes si estás en local o remoto
- 🎯 **Prevención de errores** - Evita ejecutar comandos peligrosos en el servidor equivocado
- 🔧 **Multi-servidor** - Distingue fácilmente entre diferentes servidores SSH

### Directory
```toml
truncation_length = 4    # Muestra máximo 4 niveles
truncation_symbol = "…/" # Símbolo cuando se trunca
read_only = " 🔒"        # Indica directorios de solo lectura
```

**Ejemplo:**
```
~/dotfiles/nvim/.config/nvim → …/.config/nvim
```

### Git Branch
```toml
symbol = ""  # Ícono de rama
```

**Ejemplo:**
```
 main
```

### Git Status

**Símbolos:**
- `U` - Archivos sin seguimiento (untracked)
- `M` - Archivos modificados (modified)
- `+` - Archivos en staging (staged)
- `R` - Archivos renombrados (renamed)
- `D` - Archivos eliminados (deleted)
- `S` - Cambios en stash
- `⇡` - Commits adelante del remoto
- `⇣` - Commits detrás del remoto
- `⇕` - Divergencia con remoto
- `🏳` - Conflictos

**Ejemplo:**
```
 main M U ⇡2
# 2 archivos modificados, archivos sin seguimiento, 2 commits adelante
```

### Node.js
Solo se muestra en directorios con:
- `package.json`
- `node_modules/`
- Archivos `.js`, `.ts`, `.mjs`

**Ejemplo:**
```
 v20.10.0
```

### Command Duration
Se muestra solo si el comando tardó más de 1 segundo.

**Ejemplo:**
```
took 2.5s
```

### Character (Prompt)

**Estados:**
- `➜` Verde - Comando anterior exitoso
- `➜` Rojo - Comando anterior falló
- `❮` Púrpura - Modo Vi normal (cuando usas ESC)

## Personalización

### Cambiar Colores

Edita `starship.toml`:
```toml
[directory]
style = "#f5c2e7"  # Cambia el color aquí (Rosa Catppuccin)
```

### Añadir Más Lenguajes

```toml
# Python
[python]
symbol = " "
style = "#a6e3a1"  # Verde Catppuccin
format = '[ $symbol ($version) ]($style)'

# Rust
[rust]
symbol = " "
style = "#f38ba8"  # Rojo Catppuccin
format = '[ $symbol ($version) ]($style)'
```

### Modificar Formato del Prompt

En `starship.toml`, edita la variable `format`:
```toml
format = """\
$username\
$hostname\
$directory\
$git_branch\
$git_status\
$python\
$nodejs\
$rust\
$cmd_duration\
$line_break\
$character"""
```

### Prompt de 2 Líneas

Ya está configurado con `$line_break` entre los módulos y el character.

Para una sola línea, elimina `$line_break`:
```toml
format = """\
$directory\
$git_branch\
$git_status\
$nodejs\
$cmd_duration\
$character"""
```

### Mostrar Username Siempre

Por defecto, el hostname ya está configurado para SSH. Si deseas agregar también el username:

```toml
format = """\
$os\
$username\
$hostname\
$directory\
..."""

[username]
show_always = true
format = "[$user]($style) "
style_user = "#89dceb"  # Sky Catppuccin

# Hostname ya está configurado (solo SSH)
# Para mostrarlo siempre, cambia:
[hostname]
ssh_only = false  # Cambia a false para mostrarlo siempre
format = "[@$hostname]($style) "
style = "#f9e2af"  # Yellow Catppuccin
```

## Módulos Disponibles

Starship soporta muchos lenguajes y herramientas:

**Lenguajes:**
- Python, Node.js, Rust, Go, Ruby, PHP, Java, etc.

**Herramientas:**
- Docker, Kubernetes, AWS, Terraform, etc.

**Otros:**
- Battery, Time, Memory usage, etc.

Ver todos: https://starship.rs/config/

## Comandos Útiles

```bash
# Ver configuración actual
starship config

# Ver preset de ejemplo
starship preset nerd-font-symbols

# Aplicar preset
starship preset nerd-font-symbols -o ~/.config/starship.toml

# Explicar el prompt actual
starship explain
```

## Presets Oficiales

Starship incluye presets predefinidos:

```bash
# Listar presets
starship preset

# Ver preset específico
starship preset catppuccin-mocha
starship preset gruvbox-rainbow
starship preset pure-preset
```

**Nota:** El preset actual es una versión personalizada de Catppuccin Mocha.

## Performance

Starship es extremadamente rápido (~10ms):
- Escrito en Rust
- Ejecución paralela de módulos
- Caché inteligente
- Solo muestra módulos relevantes

## Solución de Problemas

### Prompt no se ve bien

**Instala una Nerd Font:**
```bash
# Ubuntu/Debian
sudo apt install fonts-firacode

# O descarga desde:
https://www.nerdfonts.com/
```

Configura tu terminal para usar la fuente.

### Starship no se carga

**Verifica la integración en .zshrc:**
```bash
grep starship ~/.zshrc
# Debería mostrar: eval "$(starship init zsh)"
```

**Verifica que esté instalado:**
```bash
which starship
starship --version
```

### Configuración no se aplica

```bash
# Verifica la ruta del config
echo $STARSHIP_CONFIG
# Debería estar vacío o apuntar a ~/.config/starship.toml

# Verifica el archivo
cat ~/.config/starship.toml
```

### Módulos de lenguajes no aparecen

Starship detecta el lenguaje por archivos específicos:
- Node.js: `package.json`, `node_modules/`
- Python: `requirements.txt`, `*.py`
- Rust: `Cargo.toml`

Asegúrate de estar en un directorio relevante.

### Prompt es muy lento

```bash
# Medir tiempo de carga
time starship prompt

# Desactivar módulos innecesarios en starship.toml:
[cmd_duration]
disabled = true
```

## Testing de Configuración

Prueba cambios sin editar el archivo:

```bash
# Usar configuración temporal
STARSHIP_CONFIG=~/test-starship.toml zsh
```

## Restaurar Configuración

Si algo sale mal:

```bash
# Eliminar config
rm ~/.config/starship.toml

# Aplicar de nuevo con stow
cd ~/dotfiles
stow -R starship
```

## Referencias

- [Starship Documentation](https://starship.rs/)
- [Configuration Guide](https://starship.rs/config/)
- [Presets](https://starship.rs/presets/)
- [Catppuccin Theme](https://github.com/catppuccin/catppuccin)
- [Nerd Fonts](https://www.nerdfonts.com/)

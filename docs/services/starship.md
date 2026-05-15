![Starship](https://img.shields.io/badge/starship-%23f9e2af?style=for-the-badge&logo=starship&logoColor=white&color=1e1e2e)

# Starship

Prompt minimalista, rápido y altamente configurable escrito en Rust con tema Catppuccin Mocha.

## Formato del Prompt

El prompt usa una sola linea con los modulos en este orden exacto:

```toml
format = """\
$os\
$hostname\
$directory\
$git_branch\
$git_status\
$nodejs\
$python\
$rust\
$golang\
$dotnet\
$bun\
$docker_context\
$status\
$cmd_duration\
$line_break$character"""
```

## Modulos Activos

Todos los modulos presentes en `starship.toml`:

| Modulo | Simbolo | Color Catppuccin Mocha | Cuando aparece |
|--------|---------|------------------------|----------------|
| `os` | `` / `` / `` | Blue `#89b4fa` | Siempre |
| `hostname` | ` ` | Yellow `#f9e2af` | Solo en SSH |
| `directory` | ruta actual | Pink `#f5c2e7` | Siempre |
| `git_branch` | `` | Mauve `#cba6f7` | En repos Git |
| `git_status` | ver tabla abajo | Mauve `#cba6f7` | En repos Git con cambios |
| `nodejs` | `` | Green `#a6e3a1` | Con `package.json` |
| `python` | `` | Yellow `#f9e2af` | En proyectos Python |
| `rust` | `` | Peach `#fab387` | Con `Cargo.toml` |
| `golang` | `` | Teal `#89dceb` | Con `go.mod` |
| `dotnet` | `` | Mauve `#cba6f7` | En proyectos .NET/C# |
| `bun` | `🍞` | Pink `#f5c2e7` | Con `bun.lockb` |
| `docker_context` | ` ` | Blue `#89b4fa` | Con archivos Docker presentes |
| `status` | `✘` | Red `#f38ba8` | Solo cuando falla un comando |
| `cmd_duration` | `took` | Peach `#fab387` | Comandos que tardan >1 segundo |
| `character` | `➜` | Green / Red | Siempre (verde = exito, rojo = error) |

### Simbolos de Git Status

| Simbolo | Significado |
|---------|-------------|
| `M` | Archivos modificados |
| `U` | Archivos sin track (untracked) |
| `S` | Stash guardado |
| `+` | Archivos en staging |
| `R` | Archivos renombrados |
| `D` | Archivos eliminados |
| `` | Conflictos de merge |
| `⇡N` | N commits adelante del remote |
| `⇣N` | N commits atras del remote |
| `⇕` | Divergido del remote |

## Configuracion del Directorio

```toml
[directory]
style = "#f5c2e7"
format = "[$path]($style)[$read_only]($read_only_style) "
truncation_length = 4
truncation_symbol = "…/"
read_only = " "
read_only_style = "#fab387"
```

Muestra hasta 4 niveles de profundidad. Cuando el path es mas largo, trunca con `…/` al inicio.

## Configuracion de Git

```toml
[git_branch]
symbol = ""
style = "#cba6f7"
format = "[$symbol $branch]($style) "

[git_status]
style = "#cba6f7"
format = '([$all_status$ahead_behind]($style)) '
conflicted = ""
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕"
untracked = "U"
stashed = "S"
modified = "M"
staged = "+"
renamed = "R"
deleted = "D"
```

## Duracion de Comandos

```toml
[cmd_duration]
min_time = 1000
format = "took [$duration]($style) "
style = "#fab387"
```

Muestra la duracion solo si el comando tardo mas de 1 segundo (no 2 como indica el preset por defecto).

## Modo Vi

```toml
[character]
success_symbol = "[➜](#a6e3a1)"
error_symbol = "[➜](#f38ba8)"
vimcmd_symbol = "[❮](#cba6f7)"
```

- `➜` verde: ultimo comando exitoso
- `➜` rojo: ultimo comando fallo
- `❮` mauve: modo normal de Vi

## Integracion con Zsh

En `.zshrc`, la inicializacion de Starship debe ser la ultima linea, despues de todos los plugins:

```bash
eval "$(starship init zsh)"
```

Variables de entorno utiles:

```bash
# Apuntar a un archivo de configuracion alternativo
export STARSHIP_CONFIG=~/custom/starship.toml

# Habilitar logs de debug
export STARSHIP_LOG=trace
```

## Troubleshooting

**Prompt no aparece:**
```bash
which starship
grep starship ~/.zshrc   # Debe mostrar: eval "$(starship init zsh)"
exec zsh
```

**Iconos no se muestran:**
```bash
brew install --cask font-jetbrains-mono-nerd-font
# Luego configurar la Nerd Font en el emulador de terminal
```

**Git status lento en repos grandes:**
```toml
[git_status]
untracked = ""
ahead = ""
behind = ""
```

**Configuracion no se aplica:**
```bash
echo $STARSHIP_CONFIG
starship config    # Ver configuracion activa
starship explain   # Ver por que un modulo no aparece
```

## Comandos Utiles

```bash
starship config          # Ver configuracion activa
starship explain         # Explicar por que un modulo aparece o no
starship --version       # Ver version instalada
time starship prompt     # Medir tiempo de renderizado del prompt
```

## Tips

**1. Deshabilitar modulos que no usas** para reducir el tiempo de renderizado:
```toml
[dotnet]
disabled = true
```

**2. Diagnosticar modulos ausentes** con `starship explain` en el directorio donde el modulo deberia aparecer.

**3. Explorar presets oficiales** como punto de partida:
```bash
starship preset --list
starship preset gruvbox-rainbow -o ~/.config/starship.toml
```

**4. Verificar soporte de truecolor** para que los colores Catppuccin se rendericen correctamente:
```bash
echo $COLORTERM   # Debe mostrar: truecolor o 24bit
```

## Recursos

- [Starship Documentation](https://starship.rs/)
- [Configuration Reference](https://starship.rs/config/)
- [Presets oficiales](https://starship.rs/presets/)
- [Catppuccin para Starship](https://github.com/catppuccin/starship)

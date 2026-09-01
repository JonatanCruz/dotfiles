# ==============================================================================
# GENERADO POR theme/apply.sh — NO EDITAR A MANO
# ==============================================================================
# Fuente: theme/palette.sh + theme/templates/starship.tpl
# Para cambiar colores: edita la paleta y corre `theme/apply.sh`.

# Esquema para autocompletado en editores.
"$schema" = 'https://starship.rs/config-schema.json'

# Mantiene la línea en blanco entre prompts para que no se sienta apretado.
add_newline = true

# Define un prompt de una sola línea, conciso y elegante.
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

# --- MÓDULOS ESENCIALES ---

# Sistema operativo: Ícono discreto para identificar el entorno.
[os]
disabled = false
style = "{{ BLUE }}" # Blue Catppuccin Mocha
format = "[$symbol]($style) "

[os.symbols]
Macos = ""
Linux = ""
Windows = ""
Ubuntu = ""
Debian = ""
Fedora = ""
Arch = ""

# Hostname: Muestra solo cuando estás en SSH (conexión remota).
[hostname]
ssh_only = true
ssh_symbol = " "
style = "{{ YELLOW }}" # Yellow Catppuccin Mocha
format = "[$ssh_symbol$hostname]($style) "
trim_at = "."

# Directorio actual: Color rosa, truncado para no ocupar espacio.
[directory]
style = "{{ PINK }}" # Rosa Catppuccin Mocha
format = "[$path]($style)[$read_only]($read_only_style) "
truncation_length = 4
truncation_symbol = "…/"
read_only = " "
read_only_style = "{{ PEACH }}" # Peach Catppuccin Mocha

# Rama de Git: Color púrpura y un ícono simple.
[git_branch]
symbol = ""
style = "{{ MAUVE }}" # Mauve Catppuccin Mocha
format = "[$symbol $branch]($style) "

# Estado de Git: Muestra cambios de forma compacta.
[git_status]
style = "{{ MAUVE }}" # Mauve Catppuccin Mocha
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

# Versión de Node.js: Se muestra solo en proyectos de Node. Color verde.
[nodejs]
symbol = ""
style = "{{ GREEN }}" # Green Catppuccin Mocha
format = '[$symbol ($version) ]($style)'

# Python: Se muestra en proyectos Python
[python]
symbol = ""
style = "{{ YELLOW }}" # Yellow Catppuccin Mocha
format = '[$symbol ($version) ]($style)'

# Rust: Se muestra en proyectos Rust
[rust]
symbol = ""
style = "{{ PEACH }}" # Peach Catppuccin Mocha
format = '[$symbol ($version) ]($style)'

# Go: Se muestra en proyectos Go
[golang]
symbol = ""
style = "{{ SKY }}" # Teal Catppuccin Mocha
format = '[$symbol ($version) ]($style)'

# .NET: Se muestra en proyectos C#/.NET
[dotnet]
symbol = ""
style = "{{ MAUVE }}" # Mauve Catppuccin Mocha
format = '[$symbol ($version) ]($style)'

# Bun: Runtime JavaScript alternativo
[bun]
format = '[$symbol($version) ]($style)'
symbol = "🍞 "
style = "{{ PINK }}" # Pink Catppuccin Mocha

# Docker: Muestra el contexto activo de Docker
[docker_context]
symbol = " "
style = "{{ BLUE }}" # Blue Catppuccin Mocha
format = '[$symbol$context ]($style)'
only_with_files = true

# Status: Muestra código de error solo cuando falla un comando.
[status]
disabled = false
style = "{{ RED }}" # Red Catppuccin Mocha
format = '[$symbol$status ]($style)'
symbol = "✘"
# Solo aparece en errores, invisible cuando todo va bien

# Duración del comando: Útil y discreto. Color naranja.
[cmd_duration]
min_time = 1000 # Muestra solo si tarda más de 1 segundo
format = "took [$duration]($style) "
style = "{{ PEACH }}" # Peach Catppuccin Mocha

# Símbolo del prompt: El clásico ➜ con los colores de Catppuccin Mocha.
[character]
success_symbol = "[➜]({{ GREEN }})" # Green Catppuccin Mocha
error_symbol = "[➜]({{ RED }})" # Red Catppuccin Mocha
vimcmd_symbol = "[❮]({{ MAUVE }})" # Mauve Catppuccin Mocha


# Plugins de Zsh

Colección de plugins esenciales para Zsh configurados como git submodules.

## Plugins Incluidos

### 1. zsh-autosuggestions
Sugiere comandos mientras escribes basándose en tu historial.

**Características:**
- Sugerencias en tiempo real
- Basado en historial de comandos
- Aprende de tus patrones de uso

**Uso:**
- `→` - Aceptar sugerencia completa
- `Ctrl+→` - Aceptar palabra por palabra
- `Ctrl+F` - Aceptar sugerencia (alternativa)

### 2. zsh-syntax-highlighting
Resalta la sintaxis de comandos mientras escribes.

**Colores:**
- 🟢 **Verde** - Comando válido
- 🔴 **Rojo** - Comando inválido o no encontrado
- 🔵 **Azul** - Path existente
- 🟡 **Amarillo** - Alias
- 🟣 **Magenta** - String/texto

**Características:**
- Validación en tiempo real
- Resalta argumentos, opciones y rutas
- Detecta errores antes de ejecutar

### 3. zsh-history-substring-search
Búsqueda mejorada en el historial.

**Uso:**
- `↑` - Buscar hacia atrás comandos que coincidan con lo escrito
- `↓` - Buscar hacia adelante
- En modo Vi: `k` y `j` también funcionan

**Características:**
- Filtra historial por substring
- Búsqueda incremental
- Integración con modo Vi

## Estructura

```
zsh-plugins/
└── .zsh/
    ├── zsh-autosuggestions/        (git submodule)
    ├── zsh-syntax-highlighting/     (git submodule)
    └── zsh-history-substring-search/ (git submodule)
```

## Instalación

### 1. Aplicar con Stow

```bash
cd ~/dotfiles
stow zsh-plugins
```

Esto creará el enlace simbólico:
```
~/.zsh → ~/dotfiles/zsh-plugins/.zsh
```

### 2. Verificar Instalación

```bash
ls -la ~/.zsh/
# Deberías ver los tres directorios de plugins
```

Los plugins se cargan automáticamente desde `.zshrc`.

## Actualización de Plugins

Como son git submodules, puedes actualizarlos fácilmente:

### Actualizar Todos los Plugins

```bash
cd ~/dotfiles
git submodule update --remote
git add zsh-plugins/
git commit -m "Update zsh plugins"
git push
```

### Actualizar un Plugin Específico

```bash
cd ~/dotfiles/zsh-plugins/.zsh/zsh-autosuggestions
git pull origin master
cd ~/dotfiles
git add zsh-plugins/.zsh/zsh-autosuggestions
git commit -m "Update zsh-autosuggestions"
git push
```

### Ver Versiones Actuales

```bash
git submodule status
```

## Configuración en .zshrc

Los plugins se cargan en este orden en `.zshrc`:

```bash
# Carga de plugins (el orden importa)
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh  # ÚLTIMO
```

⚠️ **Importante:** `zsh-syntax-highlighting` **DEBE** ser el último plugin cargado.

## Personalización

### Autosuggestions

Cambiar el color de las sugerencias en `.zshrc`:

```bash
# Color de las sugerencias (antes de cargar el plugin)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'  # Gris oscuro
```

Cambiar estrategia de sugerencias:

```bash
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
```

### Syntax Highlighting

Personalizar colores en `.zshrc`:

```bash
# Después de cargar el plugin
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[path]='fg=blue'
```

### History Substring Search

Configurar colores en `.zshrc`:

```bash
# Antes de los keybindings
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=green,fg=black,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=red,fg=black,bold'
```

## Clonar en una Nueva Máquina

Si clonas el repositorio de dotfiles en una nueva máquina:

```bash
# Clonar con submodules
git clone --recurse-submodules https://github.com/TU_USUARIO/dotfiles.git ~/dotfiles

# O si ya clonaste sin --recurse-submodules:
cd ~/dotfiles
git submodule init
git submodule update
```

## Solución de Problemas

### Los plugins no se cargan

**Verificar que existen:**
```bash
ls -la ~/.zsh/
```

**Verificar que .zshrc los carga:**
```bash
grep "source ~/.zsh" ~/.zshrc
```

**Recargar configuración:**
```bash
source ~/.zshrc
```

### Autosuggestions no aparecen

```bash
# Verifica que tienes historial
echo $HISTFILE
cat $HISTFILE | wc -l

# Las sugerencias se basan en el historial
# Ejecuta algunos comandos y prueba de nuevo
```

### Syntax highlighting no funciona

**Verifica que sea el último plugin cargado en .zshrc:**
```bash
tail ~/.zshrc
# Debería mostrar la línea de zsh-syntax-highlighting al final
```

### Errores de submodules

```bash
# Reinicializar submodules
cd ~/dotfiles
git submodule deinit -f .
git submodule update --init --recursive
```

### Rendimiento lento

Si notas que el shell es lento:

```bash
# Deshabilita temporalmente syntax highlighting
# Comenta esta línea en .zshrc:
# source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
```

## Añadir Nuevos Plugins

Para añadir un nuevo plugin como submodule:

```bash
cd ~/dotfiles
git submodule add https://github.com/autor/plugin.git zsh-plugins/.zsh/nombre-plugin

# Edita .zshrc para cargarlo
echo "source ~/.zsh/nombre-plugin/nombre-plugin.zsh" >> ~/.zshrc

# Commit
git add .gitmodules zsh-plugins/
git commit -m "Add nombre-plugin"
git push
```

## Eliminar un Plugin

```bash
cd ~/dotfiles

# Eliminar del git
git submodule deinit -f zsh-plugins/.zsh/nombre-plugin
git rm -f zsh-plugins/.zsh/nombre-plugin
rm -rf .git/modules/zsh-plugins/.zsh/nombre-plugin

# Eliminar la línea de source en .zshrc
# Edita manualmente ~/.zshrc

# Commit
git commit -m "Remove nombre-plugin"
git push
```

## Referencias

- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search)
- [Git Submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)

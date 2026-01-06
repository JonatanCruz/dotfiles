# Configuración de Serena MCP para Dotfiles

Este archivo contiene configuraciones y comandos útiles de Serena MCP específicos para este proyecto.

## 🎯 Comandos Rápidos

### Análisis de Neovim

```bash
# Ver estructura de plugins
serena_list_dir(relative_path="nvim/.config/nvim/lua/plugins", recursive=true)

# Analizar un plugin específico
serena_get_symbols_overview(relative_path="nvim/.config/nvim/lua/plugins/lsp.lua", depth=1)

# Encontrar todos los keymaps
serena_search_for_pattern(
  substring_pattern="keymap\\.set|vim\\.keymap\\.set",
  relative_path="nvim/.config/nvim/lua",
  restrict_search_to_code_files=true
)
```

### Análisis de Zsh

```bash
# Ver aliases definidos
serena_search_for_pattern(
  substring_pattern="^alias ",
  relative_path="zsh/.config/zsh/aliases"
)

# Analizar funciones de zsh
serena_search_for_pattern(
  substring_pattern="^function |^[a-z_]+\\(\\)",
  relative_path="zsh/.config/zsh"
)
```

### Análisis de Scripts

```bash
# Ver funciones en scripts
serena_search_for_pattern(
  substring_pattern="^[a-z_]+\\(\\) \\{",
  relative_path="scripts",
  context_lines_after=3
)
```

## 📋 Patrones del Proyecto

### Convenciones de Neovim

**Estructura de Plugin**:

- Siempre usar lazy loading (`event`, `cmd`, `keys`)
- Configuración en función `config`
- Transparencia delegada a `utils/transparency.lua`
- Keymaps con descripción (`desc`)

**Prefijos de Keymaps**:

- `<leader>f` → Find (Telescope)
- `<leader>g` → Git
- `<leader>x` → Diagnostics
- `<leader>d` → Debug
- `<leader>q` → Quit/Session
- `g*` → LSP Navigation

### Convenciones de Zsh

**Estructura de Aliases**:

- Archivos por categoría en `zsh/.config/zsh/aliases/`
- Formato: `alias nombre='comando'`
- Comentarios descriptivos antes de cada alias

### Convenciones de Git

**Mensajes de Commit**:

- `feat:` → Nueva funcionalidad
- `fix:` → Corrección de bug
- `docs:` → Documentación
- `chore:` → Tareas de mantenimiento
- `refactor:` → Refactorización
- `merge:` → Merge de ramas

## 🔍 Búsquedas Útiles

### Encontrar TODOs

```bash
serena_search_for_pattern(
  substring_pattern="TODO|FIXME|HACK|XXX",
  relative_path=".",
  context_lines_after=2
)
```

### Encontrar Funciones Sin Documentación

```bash
# En Lua (Neovim)
serena_search_for_pattern(
  substring_pattern="^function [^-]",
  relative_path="nvim/.config/nvim/lua",
  restrict_search_to_code_files=true
)
```

### Encontrar Configuraciones Hardcoded

```bash
serena_search_for_pattern(
  substring_pattern="/home/[a-z]+|/Users/[a-z]+",
  relative_path="."
)
```

## 🛠️ Refactoring Común

### Renombrar Función Utility

```bash
# 1. Encontrar
serena_find_symbol(
  name_path_pattern="M.old_name",
  relative_path="nvim/.config/nvim/lua/utils/init.lua",
  include_body=true
)

# 2. Ver referencias
serena_find_referencing_symbols(
  name_path="M.old_name",
  relative_path="nvim/.config/nvim/lua/utils/init.lua"
)

# 3. Renombrar
serena_rename_symbol(
  name_path="M.old_name",
  relative_path="nvim/.config/nvim/lua/utils/init.lua",
  new_name="new_name"
)
```

### Actualizar Patrón en Múltiples Archivos

```bash
# Buscar patrón antiguo
serena_search_for_pattern(
  substring_pattern="old_pattern",
  relative_path="nvim/.config/nvim/lua/plugins"
)

# Reemplazar en archivo específico
serena_replace_content(
  relative_path="nvim/.config/nvim/lua/plugins/file.lua",
  needle="old_pattern",
  repl="new_pattern",
  mode="literal"
)
```

## 📊 Análisis de Proyecto

### Contar Plugins de Neovim

```bash
serena_list_dir(
  relative_path="nvim/.config/nvim/lua/plugins",
  recursive=true
)
```

### Analizar Complejidad de Configuración

```bash
# Contar funciones en utils
serena_find_symbol(
  name_path_pattern="M.*",
  relative_path="nvim/.config/nvim/lua/utils",
  include_kinds=[12]  # Functions
)
```

### Verificar Consistencia de Keymaps

```bash
# Buscar keymaps duplicados
serena_search_for_pattern(
  substring_pattern='<leader>[a-z]{2}',
  relative_path="nvim/.config/nvim/lua"
)
```

## 🎨 Workflows Específicos

### Workflow: Agregar Nuevo Plugin

1. Crear archivo en `lua/plugins/categoria/`
2. Verificar que no exista ya:
   ```bash
   serena_search_for_pattern(
     substring_pattern="nombre-del-plugin",
     relative_path="nvim/.config/nvim/lua/plugins"
   )
   ```
3. Seguir estructura estándar
4. Agregar a memoria si es patrón nuevo

### Workflow: Migrar Configuración

1. Analizar configuración actual
2. Buscar referencias
3. Crear nueva estructura
4. Actualizar referencias
5. Verificar con tests
6. Documentar en memoria

### Workflow: Auditoría de Seguridad

```bash
# Buscar credenciales hardcoded
serena_search_for_pattern(
  substring_pattern="password|token|secret|api_key",
  relative_path="."
)

# Buscar rutas absolutas
serena_search_for_pattern(
  substring_pattern="/home/jonatan|/Users/jonatan",
  relative_path="."
)
```

## 💾 Gestión de Memoria

### Memorias Recomendadas

- `nvim_plugin_patterns` → Patrones de plugins
- `zsh_configuration` → Configuración de Zsh
- `git_workflow` → Workflow de Git
- `serena_mcp_best_practices` → Mejores prácticas (ya creada)
- `session_YYYY-MM-DD` → Sesiones diarias

### Actualizar Memoria

```bash
# Leer memoria existente
serena_read_memory(memory_file_name="nvim_plugin_patterns")

# Editar memoria
serena_edit_memory(
  memory_file_name="nvim_plugin_patterns",
  needle="## Patrón Antiguo",
  repl="## Patrón Nuevo",
  mode="literal"
)
```

## 🚨 Alertas y Validaciones

### Pre-Commit Checks

```bash
# 1. Verificar TODOs
serena_search_for_pattern(substring_pattern="TODO", relative_path=".")

# 2. Verificar rutas hardcoded
serena_search_for_pattern(substring_pattern="/home/|/Users/", relative_path=".")

# 3. Verificar credenciales
serena_search_for_pattern(substring_pattern="password|token", relative_path=".")
```

### Post-Refactor Validation

```bash
# 1. Verificar símbolos rotos
serena_find_symbol(name_path_pattern="*", relative_path=".")

# 2. Verificar referencias
serena_find_referencing_symbols(name_path="symbol", relative_path="file.lua")
```

## 📚 Recursos

- Memoria de mejores prácticas: `serena_mcp_best_practices`
- Documentación de proyecto: `docs/`
- CLAUDE.md: Guía para asistentes de IA

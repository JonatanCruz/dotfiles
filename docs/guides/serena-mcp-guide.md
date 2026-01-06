# Guía Completa de Serena MCP

> Análisis semántico de código y gestión de memoria para OpenCode

## 📚 Tabla de Contenidos

1. [Introducción](#introducción)
2. [Configuración](#configuración)
3. [Comandos Esenciales](#comandos-esenciales)
4. [Casos de Uso Prácticos](#casos-de-uso-prácticos)
5. [Mejores Prácticas](#mejores-prácticas)
6. [Workflows Avanzados](#workflows-avanzados)

---

## Introducción

Serena MCP es un servidor MCP (Model Context Protocol) que proporciona **análisis semántico de código** a nivel de símbolos. A diferencia de herramientas como `grep` o `ripgrep` que buscan texto, Serena entiende la estructura del código.

### ¿Qué Puede Hacer?

- ✅ Buscar clases, funciones, métodos por nombre
- ✅ Encontrar todas las referencias a un símbolo
- ✅ Renombrar símbolos en todo el proyecto (refactoring seguro)
- ✅ Analizar estructura de archivos
- ✅ Buscar patrones con regex
- ✅ Guardar conocimiento entre sesiones (memoria)

### ¿Cuándo Usar Serena vs grep?

| Tarea                  | Herramienta    | Por qué                      |
| ---------------------- | -------------- | ---------------------------- |
| Buscar texto literal   | `grep/ripgrep` | Más rápido para texto simple |
| Buscar función/clase   | **Serena**     | Entiende símbolos            |
| Renombrar variable     | **Serena**     | Actualiza referencias        |
| Encontrar referencias  | **Serena**     | Análisis semántico           |
| Buscar patrón complejo | **Serena**     | Regex + contexto             |

---

## Configuración

### Verificar Instalación

Serena MCP ya está configurado en tu OpenCode. Verifica en:

```bash
cat opencode/.config/opencode/opencode.json
```

Deberías ver:

```json
{
  "mcpServers": {
    "serena": {
      "command": "npx",
      "args": ["-y", "@serenaai/serena-mcp"]
    }
  }
}
```

### Archivos de Configuración

- **Mejores Prácticas**: `.serena/memories/serena_mcp_best_practices.md`
- **Comandos Rápidos**: `.serena-config.md`
- **Memoria de Sesión**: `.serena/memories/session_YYYY-MM-DD.md`

---

## Comandos Esenciales

### 1. Exploración de Código

#### Listar Directorios

```bash
serena_list_dir(
  relative_path="nvim/.config/nvim/lua/plugins",
  recursive=true
)
```

**Resultado**: Lista de archivos y carpetas

#### Vista General de Símbolos

```bash
serena_get_symbols_overview(
  relative_path="nvim/.config/nvim/lua/utils/init.lua",
  depth=1  # 0=solo top-level, 1=incluye hijos
)
```

**Resultado**: JSON con clases, funciones, variables

### 2. Búsqueda de Símbolos

#### Buscar por Nombre

```bash
# Buscar función "map"
serena_find_symbol(
  name_path_pattern="map",
  relative_path="nvim/.config/nvim/lua",
  include_body=true  # Incluir código
)

# Buscar con substring
serena_find_symbol(
  name_path_pattern="calculate",
  substring_matching=true  # Encuentra calculateTotal, calculateSum, etc.
)
```

#### Filtrar por Tipo

```bash
# Solo clases
serena_find_symbol(
  name_path_pattern="*",
  include_kinds=[5],  # 5 = Class
  relative_path="src"
)

# Solo funciones
serena_find_symbol(
  name_path_pattern="*",
  include_kinds=[12],  # 12 = Function
  relative_path="src"
)
```

**Tipos de Símbolos (LSP)**:

- `5` = Class
- `6` = Method
- `12` = Function
- `13` = Variable
- `14` = Constant

### 3. Encontrar Referencias

```bash
serena_find_referencing_symbols(
  name_path="map",
  relative_path="nvim/.config/nvim/lua/utils/init.lua"
)
```

**Resultado**: Todos los lugares donde se usa `map`

### 4. Búsqueda de Patrones (Regex)

```bash
# Buscar TODOs
serena_search_for_pattern(
  substring_pattern="TODO|FIXME|HACK",
  relative_path="nvim/.config/nvim/lua",
  restrict_search_to_code_files=true,
  context_lines_after=2
)

# Buscar hooks de React
serena_search_for_pattern(
  substring_pattern="use[A-Z]\\w+",
  paths_include_glob="**/*.tsx",
  restrict_search_to_code_files=true
)
```

### 5. Edición de Código

#### Reemplazar Cuerpo de Función

```bash
serena_replace_symbol_body(
  name_path="M.map",
  relative_path="nvim/.config/nvim/lua/utils/init.lua",
  body="""
function M.map(mode, lhs, rhs, opts)
  -- Nueva implementación
  vim.keymap.set(mode, lhs, rhs, opts)
end
"""
)
```

#### Insertar Código

```bash
# Insertar después de un símbolo
serena_insert_after_symbol(
  name_path="M.map",
  relative_path="nvim/.config/nvim/lua/utils/init.lua",
  body="""

-- Nueva función
function M.new_function()
  -- código
end
"""
)
```

#### Renombrar Símbolo (Refactoring Seguro)

```bash
serena_rename_symbol(
  name_path="old_name",
  relative_path="src/utils.ts",
  new_name="new_name"
)
```

**Importante**: Esto actualiza TODAS las referencias en el proyecto.

### 6. Gestión de Memoria

#### Guardar Conocimiento

```bash
serena_write_memory(
  memory_file_name="nvim_patterns",
  content="""
# Patrones de Neovim

## Lazy Loading
Todos los plugins deben usar `event`, `cmd`, o `keys`.

## Keymaps
- <leader>f → Find
- <leader>g → Git
"""
)
```

#### Leer Memoria

```bash
serena_read_memory(memory_file_name="nvim_patterns")
```

#### Listar Memorias

```bash
serena_list_memories()
```

---

## Casos de Uso Prácticos

### Caso 1: Auditar Keymaps de Neovim

**Objetivo**: Encontrar todos los keymaps definidos y verificar duplicados.

```bash
# 1. Buscar todos los keymaps
serena_search_for_pattern(
  substring_pattern="keymap\\.set|vim\\.keymap\\.set",
  relative_path="nvim/.config/nvim/lua",
  restrict_search_to_code_files=true,
  context_lines_after=2
)

# 2. Guardar en memoria
serena_write_memory(
  memory_file_name="nvim_keymaps_audit",
  content="# Auditoría de Keymaps\n\n[Pegar resultados aquí]"
)
```

### Caso 2: Refactorizar Función Utility

**Objetivo**: Renombrar `M.map` a `M.create_keymap` en todo el proyecto.

```bash
# 1. Ver la función actual
serena_find_symbol(
  name_path_pattern="M.map",
  relative_path="nvim/.config/nvim/lua/utils/init.lua",
  include_body=true
)

# 2. Ver dónde se usa
serena_find_referencing_symbols(
  name_path="M.map",
  relative_path="nvim/.config/nvim/lua/utils/init.lua"
)

# 3. Renombrar (actualiza todas las referencias)
serena_rename_symbol(
  name_path="M.map",
  relative_path="nvim/.config/nvim/lua/utils/init.lua",
  new_name="create_keymap"
)
```

### Caso 3: Encontrar Plugins Sin Lazy Loading

**Objetivo**: Identificar plugins que cargan inmediatamente.

```bash
# Buscar plugins sin event/cmd/keys
serena_search_for_pattern(
  substring_pattern='return\\s*\\{\\s*"[^"]+/[^"]+"[^}]*\\}',
  relative_path="nvim/.config/nvim/lua/plugins",
  restrict_search_to_code_files=true
)

# Analizar manualmente los resultados
# Los que NO tengan 'event', 'cmd', o 'keys' necesitan optimización
```

### Caso 4: Buscar Rutas Hardcoded

**Objetivo**: Encontrar rutas absolutas que deben ser relativas.

```bash
serena_search_for_pattern(
  substring_pattern="/home/jonatan|/Users/jonatan",
  relative_path=".",
  context_lines_after=2
)
```

### Caso 5: Analizar Estructura de Proyecto

**Objetivo**: Entender la organización de plugins.

```bash
# 1. Listar estructura
serena_list_dir(
  relative_path="nvim/.config/nvim/lua/plugins",
  recursive=true
)

# 2. Analizar cada categoría
serena_get_symbols_overview(
  relative_path="nvim/.config/nvim/lua/plugins/ui",
  depth=0
)

# 3. Guardar en memoria
serena_write_memory(
  memory_file_name="nvim_architecture",
  content="""
# Arquitectura de Neovim

## Estructura de Plugins
- ui/ → 11 archivos (interfaz)
- editor/ → 4 archivos (edición)
- coding/ → 2 archivos (autocompletado)
- lsp/ → Herramientas LSP
- git/ → 3 archivos (Git)
- debug/ → 2 archivos (DAP)
- test/ → 1 archivo (Neotest)
- tools/ → 6 archivos (utilidades)
"""
)
```

---

## Mejores Prácticas

### 1. Usa Símbolos Cuando Sea Posible

❌ **MAL**:

```bash
serena_search_for_pattern(substring_pattern="function calculateTotal")
```

✅ **BIEN**:

```bash
serena_find_symbol(name_path_pattern="calculateTotal", include_body=true)
```

### 2. Limita el Scope con `relative_path`

❌ **MAL**:

```bash
serena_find_symbol(name_path_pattern="map")  # Busca en TODO el proyecto
```

✅ **BIEN**:

```bash
serena_find_symbol(
  name_path_pattern="map",
  relative_path="nvim/.config/nvim/lua/utils"  # Solo en utils
)
```

### 3. Usa Filtros de Tipo

❌ **MAL**:

```bash
serena_find_symbol(name_path_pattern="User")  # Encuentra variables, clases, etc.
```

✅ **BIEN**:

```bash
serena_find_symbol(
  name_path_pattern="User",
  include_kinds=[5]  # Solo clases
)
```

### 4. Guarda Patrones en Memoria

Cuando descubras un patrón importante, guárdalo:

```bash
serena_write_memory(
  memory_file_name="project_patterns",
  content="# Patrón descubierto: [descripción]"
)
```

### 5. Workflow: Explora → Analiza → Edita

```bash
# 1. Explorar
serena_get_symbols_overview(relative_path="file.lua", depth=1)

# 2. Analizar
serena_find_referencing_symbols(name_path="symbol", relative_path="file.lua")

# 3. Editar
serena_replace_symbol_body(name_path="symbol", ...)
```

---

## Workflows Avanzados

### Workflow 1: Pre-Commit Validation

```bash
# 1. Buscar TODOs
serena_search_for_pattern(
  substring_pattern="TODO|FIXME",
  relative_path="."
)

# 2. Buscar credenciales
serena_search_for_pattern(
  substring_pattern="password|token|api_key",
  relative_path="."
)

# 3. Buscar rutas hardcoded
serena_search_for_pattern(
  substring_pattern="/home/|/Users/",
  relative_path="."
)
```

### Workflow 2: Migración de Patrón

```bash
# 1. Encontrar patrón antiguo
serena_search_for_pattern(
  substring_pattern="vim\\.cmd\\(",
  relative_path="nvim/.config/nvim/lua"
)

# 2. Reemplazar en cada archivo
serena_replace_content(
  relative_path="nvim/.config/nvim/lua/file.lua",
  needle="vim\\.cmd\\(",
  repl="vim.api.nvim_command(",
  mode="regex"
)

# 3. Verificar cambios
serena_search_for_pattern(
  substring_pattern="vim\\.cmd\\(",
  relative_path="nvim/.config/nvim/lua"
)
```

### Workflow 3: Documentación Automática

```bash
# 1. Encontrar funciones públicas
serena_find_symbol(
  name_path_pattern="M.*",
  relative_path="nvim/.config/nvim/lua/utils",
  include_kinds=[12],  # Functions
  include_body=true
)

# 2. Generar documentación
# (Usar resultados para crear docs/)

# 3. Guardar en memoria
serena_write_memory(
  memory_file_name="api_documentation",
  content="# API Documentation\n\n[Funciones documentadas]"
)
```

---

## Comandos Rápidos de Referencia

### Exploración

```bash
serena_list_dir(relative_path=".", recursive=true)
serena_get_symbols_overview(relative_path="file.lua", depth=1)
```

### Búsqueda

```bash
serena_find_symbol(name_path_pattern="name", include_body=true)
serena_find_referencing_symbols(name_path="name", relative_path="file.lua")
serena_search_for_pattern(substring_pattern="regex", relative_path=".")
```

### Edición

```bash
serena_replace_symbol_body(name_path="name", body="code")
serena_insert_after_symbol(name_path="name", body="code")
serena_rename_symbol(name_path="old", new_name="new")
serena_replace_content(needle="old", repl="new", mode="literal")
```

### Memoria

```bash
serena_write_memory(memory_file_name="name", content="text")
serena_read_memory(memory_file_name="name")
serena_list_memories()
serena_edit_memory(memory_file_name="name", needle="old", repl="new")
```

---

## Recursos Adicionales

- **Memoria de Mejores Prácticas**: `.serena/memories/serena_mcp_best_practices.md`
- **Configuración del Proyecto**: `.serena-config.md`
- **LSP Symbol Kinds**: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind
- **Documentación de OpenCode**: `docs/guides/opencode.md`

---

## Tips Finales

1. **Usa `relative_path`** siempre que puedas para búsquedas más rápidas
2. **Guarda patrones** importantes en memoria para futuras sesiones
3. **Prefiere símbolos** sobre búsqueda de texto cuando sea posible
4. **Verifica referencias** antes de renombrar o eliminar código
5. **Usa `depth=0`** para vistas generales rápidas

---

**Última actualización**: 2026-01-06

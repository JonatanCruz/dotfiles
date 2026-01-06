# Configuración Automática de Serena MCP

Este documento configura Serena MCP para ejecutarse automáticamente y sacar el máximo provecho.

## 🎯 Configuración Actual

Serena MCP está habilitado en:

- **OpenCode**: `opencode.json` → `mcp.serena.enabled: true`
- **Claude Code**: `settings.json` → `serena@claude-plugins-official: true`

## 🚀 Configuración Avanzada para Uso Automático

### 1. Reglas de Instrucción Global

Agrega estas reglas a `CLAUDE.md` o `opencode/.config/opencode/AGENTS.md`:

```markdown
## Serena MCP - Uso Automático

### Cuándo Usar Serena (SIEMPRE)

**REGLA CRÍTICA**: Usa Serena MCP en lugar de grep/glob para:

1. **Búsqueda de Símbolos** (Funciones, Clases, Métodos)
   - ❌ NO: `grep -r "function name"`
   - ✅ SÍ: `serena_find_symbol(name_path_pattern="name")`

2. **Análisis de Estructura**
   - ❌ NO: `ls -la` + lectura manual
   - ✅ SÍ: `serena_get_symbols_overview(relative_path="dir")`

3. **Encontrar Referencias**
   - ❌ NO: `grep -r "functionName"`
   - ✅ SÍ: `serena_find_referencing_symbols(name_path="functionName")`

4. **Refactoring**
   - ❌ NO: Buscar y reemplazar con edit
   - ✅ SÍ: `serena_rename_symbol(name_path="old", new_name="new")`

### Workflow Obligatorio

**ANTES de editar código**:

1. `serena_get_symbols_overview()` → Entender estructura
2. `serena_find_symbol()` → Encontrar símbolo específico
3. `serena_find_referencing_symbols()` → Ver dónde se usa
4. Editar con confianza

**DESPUÉS de cambios importantes**:

1. `serena_write_memory()` → Guardar patrones descubiertos
2. Actualizar memoria de sesión

### Triggers Automáticos

Usa Serena automáticamente cuando el usuario:

- Pregunta "dónde está X"
- Pide "buscar X"
- Quiere "renombrar X"
- Necesita "ver referencias de X"
- Dice "analizar estructura"
- Pide "refactorizar X"
```

### 2. Configuración de Agentes Personalizados

Crea agentes que usen Serena por defecto:

```markdown
# En opencode/.config/opencode/agent/code-analyzer.md

---

name: code-analyzer
description: Analiza código usando Serena MCP automáticamente
mode: subagent
temperature: 0.1

---

# Code Analyzer Agent

Especialista en análisis de código usando Serena MCP.

## Comportamiento Automático

**SIEMPRE** usa Serena MCP para:

1. Análisis de estructura de archivos
2. Búsqueda de símbolos
3. Análisis de dependencias
4. Generación de reportes

## Workflow Estándar

1. **Exploración**:
```

serena_list_dir(relative_path=".", recursive=true)
serena_get_symbols_overview(relative_path="file", depth=1)

```

2. **Análisis**:
```

serena_find_symbol(name_path_pattern="\*", include_kinds=[5,12])
serena_search_for_pattern(substring_pattern="pattern")

```

3. **Reporte**:
```

serena_write_memory(memory_file_name="analysis_YYYY-MM-DD")

```

## Triggers

- "analizar código"
- "estructura del proyecto"
- "buscar función/clase"
- "ver dependencias"
```

### 3. Comandos Personalizados con Serena

Agrega a `opencode.json`:

```json
{
  "command": {
    "analyze": {
      "template": "Analiza $ARGUMENTS usando Serena MCP:\n1. serena_get_symbols_overview() para estructura\n2. serena_find_symbol() para símbolos clave\n3. serena_search_for_pattern() para patrones\n4. Genera reporte y guarda en memoria",
      "description": "Análisis profundo con Serena MCP",
      "agent": "code-analyzer"
    },
    "refactor": {
      "template": "Refactoriza $ARGUMENTS usando Serena:\n1. serena_find_symbol() para encontrar\n2. serena_find_referencing_symbols() para referencias\n3. serena_rename_symbol() o serena_replace_symbol_body()\n4. Verifica cambios",
      "description": "Refactoring seguro con Serena",
      "agent": "build"
    },
    "audit": {
      "template": "Audita el código en $ARGUMENTS:\n1. Buscar TODOs/FIXMEs\n2. Buscar rutas hardcoded\n3. Buscar credenciales\n4. Verificar patrones inconsistentes\n5. Guardar reporte en memoria",
      "description": "Auditoría de código con Serena",
      "agent": "code-analyzer"
    }
  }
}
```

### 4. Hooks Automáticos (Pre/Post Operaciones)

Crea reglas en `CLAUDE.md`:

```markdown
## Hooks Automáticos de Serena

### Pre-Edit Hook

ANTES de editar cualquier archivo:

1. `serena_get_symbols_overview()` del archivo
2. Si vas a modificar función/clase: `serena_find_referencing_symbols()`

### Post-Refactor Hook

DESPUÉS de refactorizar:

1. `serena_search_for_pattern()` para verificar que no quedaron referencias rotas
2. `serena_write_memory()` para documentar el cambio

### Pre-Commit Hook

ANTES de commit:

1. `serena_search_for_pattern(substring_pattern="TODO|FIXME")`
2. `serena_search_for_pattern(substring_pattern="/home/|/Users/")`
3. `serena_search_for_pattern(substring_pattern="password|token|api_key")`

### Session Start Hook

AL INICIO de sesión:

1. `serena_check_onboarding_performed()`
2. `serena_list_memories()`
3. `serena_read_memory(memory_file_name="project_patterns")`

### Session End Hook

AL FINAL de sesión:

1. `serena_write_memory(memory_file_name="session_YYYY-MM-DD")`
2. Guardar descubrimientos importantes
```

### 5. Aliases de Comandos Rápidos

Crea shortcuts en `opencode.json`:

```json
{
  "command": {
    "s:find": {
      "template": "serena_find_symbol(name_path_pattern=\"$ARGUMENTS\", include_body=true)",
      "description": "Buscar símbolo rápido"
    },
    "s:refs": {
      "template": "serena_find_referencing_symbols(name_path=\"$ARGUMENTS\")",
      "description": "Ver referencias rápido"
    },
    "s:overview": {
      "template": "serena_get_symbols_overview(relative_path=\"$ARGUMENTS\", depth=1)",
      "description": "Vista general rápida"
    },
    "s:search": {
      "template": "serena_search_for_pattern(substring_pattern=\"$ARGUMENTS\", relative_path=\".\")",
      "description": "Búsqueda de patrón rápida"
    },
    "s:todos": {
      "template": "serena_search_for_pattern(substring_pattern=\"TODO|FIXME|HACK\", relative_path=\".\", context_lines_after=2)",
      "description": "Buscar TODOs"
    },
    "s:save": {
      "template": "serena_write_memory(memory_file_name=\"discovery_$(date +%Y%m%d_%H%M%S)\", content=\"$ARGUMENTS\")",
      "description": "Guardar descubrimiento rápido"
    }
  }
}
```

### 6. Configuración de Memoria Automática

Crea estructura de memoria en `.serena/`:

```bash
# Estructura recomendada
.serena/
├── memories/
│   ├── project_architecture.md      # Auto-actualizado
│   ├── code_patterns.md             # Auto-actualizado
│   ├── session_YYYY-MM-DD.md        # Diario
│   └── discoveries/
│       ├── nvim_*.md
│       ├── zsh_*.md
│       └── git_*.md
└── config/
    ├── auto_save_rules.md
    └── memory_templates.md
```

### 7. Reglas de Auto-Save

````markdown
## Auto-Save de Memoria

### Triggers para Auto-Save

Guarda automáticamente en memoria cuando:

1. **Descubres un patrón nuevo**:
   - Convención de naming
   - Estructura de código
   - Patrón arquitectónico

2. **Refactorizas código importante**:
   - Renombras símbolos públicos
   - Cambias estructura de módulos
   - Migras patrones

3. **Resuelves un problema complejo**:
   - Bug difícil
   - Configuración compleja
   - Integración de herramientas

4. **Sesión > 30 minutos**:
   - Auto-checkpoint cada 30 min
   - Guardar contexto de trabajo

### Formato de Memoria

```markdown
# [Tipo] - [Tema] - [Fecha]

## Contexto

[Por qué es importante]

## Descubrimiento

[Qué encontraste]

## Implementación

[Cómo se usa]

## Ejemplos

[Código de ejemplo]

## Referencias

[Archivos relacionados]
```
````

````

### 8. Integración con Git Workflow

```markdown
## Serena + Git Integration

### Pre-Commit
```bash
# Ejecutar automáticamente antes de commit
serena_search_for_pattern(substring_pattern="TODO|FIXME", relative_path=".")
serena_search_for_pattern(substring_pattern="/home/|/Users/", relative_path=".")
serena_search_for_pattern(substring_pattern="console\\.log|debugger", relative_path=".")
````

### Post-Merge

```bash
# Después de merge, analizar cambios
serena_search_for_pattern(substring_pattern="<<<<<<<|>>>>>>>|=======", relative_path=".")
serena_get_symbols_overview(relative_path=".", depth=0)
```

### Pre-Push

```bash
# Antes de push, verificar calidad
serena_find_symbol(name_path_pattern="test", include_kinds=[12])
serena_search_for_pattern(substring_pattern="skip|only", relative_path=".")
```

````

## 📊 Métricas de Uso

### Tracking Automático

Configura logging de uso de Serena:

```markdown
## Serena Usage Metrics

Trackea automáticamente:
- Número de búsquedas por sesión
- Símbolos más buscados
- Patrones más comunes
- Tiempo ahorrado vs grep/manual

Guarda en: `.serena/metrics/usage_YYYY-MM.json`
````

## 🎯 Configuración Final Recomendada

### En `CLAUDE.md` (Raíz del proyecto)

Agrega esta sección:

```markdown
## Serena MCP - Configuración Automática

### Uso Obligatorio

**SIEMPRE** usa Serena MCP para:

1. Búsqueda de símbolos (funciones, clases, métodos)
2. Análisis de estructura de archivos
3. Encontrar referencias de código
4. Refactoring seguro (renombrar símbolos)
5. Búsqueda de patrones complejos

### Workflow Estándar

1. **Explorar**: `serena_get_symbols_overview()`
2. **Buscar**: `serena_find_symbol()`
3. **Analizar**: `serena_find_referencing_symbols()`
4. **Editar**: Con confianza
5. **Guardar**: `serena_write_memory()`

### Memoria Automática

- Guarda descubrimientos importantes
- Actualiza patrones del proyecto
- Mantén contexto entre sesiones
- Usa memoria para onboarding rápido

### Comandos Rápidos

- `/analyze` → Análisis profundo con Serena
- `/refactor` → Refactoring seguro
- `/audit` → Auditoría de código
- `s:find` → Buscar símbolo
- `s:refs` → Ver referencias
- `s:todos` → Buscar TODOs
```

## 🚀 Activación

Para activar esta configuración:

1. **Copia reglas a CLAUDE.md**:

   ```bash
   cat opencode/.config/opencode/SERENA_AUTO_CONFIG.md >> CLAUDE.md
   ```

2. **Actualiza opencode.json** con comandos personalizados

3. **Crea agente code-analyzer**:

   ```bash
   # Ya existe en opencode/.config/opencode/agent/
   ```

4. **Reinicia OpenCode**:
   ```bash
   # Cierra y abre OpenCode para cargar configuración
   ```

## 📚 Recursos

- **Guía Completa**: `docs/guides/serena-mcp-guide.md`
- **Comandos Rápidos**: `.serena-config.md`
- **Mejores Prácticas**: Memoria `serena_mcp_best_practices`
- **Ejemplos**: `docs/guides/serena-mcp-guide.md#casos-de-uso-prácticos`

---

**Última actualización**: 2026-01-06

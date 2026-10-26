# Guía Completa de Diagnósticos en Neovim

Sistema completo para detectar, visualizar, navegar y solucionar errores y warnings en tu código.

**Nota sobre Keybindings**: Esta configuración sigue la convención de la comunidad Neovim (LazyVim, NvChad, AstroNvim):
- `<leader>x` para diagnósticos y Trouble
- `<leader>d` está reservado para Debug (DAP)

## 🎨 Visualización de Errores

### Signos en el Gutter (Columna Izquierda)

| Icono | Tipo | Color | Significado |
|-------|------|-------|-------------|
|  | Error | Rojo | Error crítico que impide compilación |
|  | Warning | Amarillo | Advertencia que puede causar problemas |
|  | Hint | Cyan | Sugerencia de mejora |
|  | Info | Azul | Información adicional |

### Inline Diagnostics

Los errores aparecen:
- **En la línea**: Texto virtual al final de la línea con el error
- **Underline**: Subrayado del código problemático
- **Lightbulb (💡)**: Aparece cuando hay soluciones automáticas disponibles

## 🧭 Navegación Entre Errores

### Comandos Básicos

| Comando | Acción | Descripción |
|---------|--------|-------------|
| `]d` | Siguiente diagnóstico | Va al próximo error/warning |
| `[d` | Diagnóstico anterior | Va al error/warning previo |
| `]e` | Siguiente error | Solo errores críticos (ignora warnings) |
| `[e` | Error anterior | Solo errores críticos |

### Ver Detalles del Error

| Comando | Acción | Descripción |
|---------|--------|-------------|
| `<leader>xe` | Ver diagnóstico flotante | Ventana con detalles completos (examine) |
| `gl` | Ver diagnóstico inline | Alternativa rápida |
| `K` | Hover documentation | Ver documentación del símbolo |

### Listas de Errores (Trouble - Mejor UI)

| Comando | Acción | Descripción |
|---------|--------|-------------|
| `<leader>xx` | Toggle Trouble | Abrir/cerrar ventana Trouble |
| `<leader>xd` | Document diagnostics | Errores del archivo actual |
| `<leader>xw` | Workspace diagnostics | Errores de todo el proyecto |
| `<leader>xq` | Quickfix | Lista quickfix |
| `<leader>xl` | Location list | Lista de ubicaciones |
| `<leader>xr` | LSP References | Referencias con Trouble |
| `<leader>xL` | Location list nativa | Lista nativa de Vim |

## 💡 Soluciones Automáticas (Code Actions)

### Identificar Soluciones Disponibles

**Lightbulb (💡)**: Cuando ves este icono en el gutter, hay soluciones automáticas disponibles.

### Acceder a Soluciones

| Comando | Modo | Acción |
|---------|------|--------|
| `<leader>ca` | Normal/Visual | Mostrar code actions disponibles |
| Enter | En menu | Aplicar la solución seleccionada |

### Tipos de Code Actions Comunes

1. **Quick Fix**: Arreglar error automáticamente
   ```
   Ejemplo: Variable no usada → Eliminar variable
   ```

2. **Import Missing**: Agregar imports faltantes
   ```
   Ejemplo: 'useState' no definido → Agregar import de React
   ```

3. **Organize Imports**: Ordenar y limpiar imports
   ```
   Ejemplo: Imports desordenados → Organizar alfabéticamente
   ```

4. **Extract Function**: Extraer código a función
   ```
   Ejemplo: Código duplicado → Crear función reutilizable
   ```

5. **Convert to Template String**: Modernizar sintaxis
   ```
   Ejemplo: "Hello " + name → `Hello ${name}`
   ```

## 🔥 Flujos de Trabajo

### Escenario 1: Arreglar Errores de Compilación

```
1. Abrir archivo con errores
2. ]e              → Ir al primer error
3. <leader>xe      → Ver detalles del error
4. <leader>ca      → Ver si hay fix automático
5. Enter           → Aplicar fix
6. ]e              → Repetir para siguiente error
```

### Escenario 2: Code Review de Warnings

```
1. <leader>xd      → Ver todos los warnings del archivo
2. j/k             → Navegar en lista
3. Enter           → Saltar al warning
4. <leader>ca      → Ver soluciones
5. <leader>cr      → Renombrar si es necesario
```

### Escenario 3: Limpieza de Código

```
1. <leader>xw      → Ver problemas del proyecto
2. Filtrar por tipo (errors, warnings, hints)
3. Para cada item:
   - Enter         → Ir al problema
   - <leader>ca    → Aplicar fix si existe
   - <leader>f     → Formatear archivo
```

### Escenario 4: Debugging Rápido

```
1. ]d              → Navegar entre problemas
2. gl o <leader>xe → Ver error sin abrir ventana
3. Si necesitas más contexto:
   - K             → Ver documentación
   - gd            → Ir a definición
   - <leader>ca    → Ver fixes
```

## 🎯 Comandos Especiales

### Toggle de Visualización

| Comando | Acción | Uso |
|---------|--------|-----|
| `<leader>ul` | Toggle LSP Lines | Alternar vista de diagnósticos como líneas |

### Trouble.nvim (UI Mejorada)

| Comando | Ventana | Descripción |
|---------|---------|-------------|
| `<leader>xx` | Trouble general | Toggle ventana principal |
| `<leader>xw` | Workspace | Problemas de todo el proyecto |
| `<leader>xd` | Document | Problemas del archivo actual |
| `<leader>xq` | Quickfix | Lista quickfix de Vim |
| `<leader>xl` | Location list | Lista de ubicaciones |
| `<leader>xr` | LSP References | Referencias con UI mejorada |
| `gR` | LSP References | Alias de <leader>xr |

### Navegación en Trouble

Cuando estás en ventana Trouble:

| Tecla | Acción |
|-------|--------|
| `j/k` | Navegar arriba/abajo |
| `Enter` | Ir al error |
| `o` | Ir y cerrar Trouble |
| `q` | Cerrar Trouble |
| `m` | Toggle entre modos |
| `P` | Toggle preview |
| `r` | Refresh |

## 📊 Prioridad de Severidad

Los errores se muestran en orden de importancia:

1. **ERROR** ()  - Crítico, bloquea compilación
2. **WARN** ()   - Importante, puede causar bugs
3. **INFO** ()   - Informativo
4. **HINT** ()   - Sugerencia de mejora

## 🎨 Personalización Visual

### Configuración Actual

- **Virtual Text**: Mensajes inline al final de línea
- **Underline**: Subrayado en código problemático
- **Signs**: Iconos en gutter con colores
- **Float**: Ventanas flotantes con bordes redondeados
- **Lightbulb**: Indicador visual de code actions disponibles

### Características Especiales

- **Update on Insert**: Desactivado - No molesta mientras escribes
- **Severity Sort**: Activado - Errores primero, luego warnings
- **Source Always**: Muestra qué herramienta detectó el problema (ESLint, TypeScript, etc.)

## 🚀 Atajos Rápidos por Tarea

### "Solo quiero..."

**"Arreglar este error"**
→ `<leader>ca` → Enter

**"Ver qué está mal aquí"**
→ `<leader>xe` o `gl`

**"Ir al próximo error"**
→ `]d` (todos) o `]e` (solo errors)

**"Ver todos los errores del archivo"**
→ `<leader>xd`

**"Ver todos los errores del proyecto"**
→ `<leader>xw`

**"Arreglar imports"**
→ `<leader>ca` → Buscar "Organize imports"

**"Renombrar variable problemática"**
→ `<leader>cr`

**"Formatear después de arreglar"**
→ `<leader>f`

## 💡 Tips Pro

### 1. Usa Telescope para búsqueda global de errores
```vim
:Telescope diagnostics
```

### 2. Combina con Git para ver errores nuevos
```vim
]d → <leader>ca → :w → :Git diff
```

### 3. Workflow de refactoring
```vim
gR → Ver todas las referencias
<leader>ca → Code actions
<leader>cr → Renombrar si es necesario
<leader>f → Formatear
]d → Verificar que no hay nuevos errores
```

### 4. Depuración eficiente
```vim
]e → Solo ir a errors críticos
<leader>xe → Ver detalles
gd → Ir a definición para entender contexto
K → Ver documentación
<leader>ca → Aplicar fix
```

### 5. Code review antes de commit
```vim
<leader>xw → Ver todos los problemas
Filtrar por severidad
Arreglar uno por uno con <leader>ca
<leader>f en cada archivo modificado
:w → Guardar todo
```

## 🔧 Herramientas Integradas

El sistema de diagnósticos trabaja con:

- **LSP Servers**: TypeScript, Python, Go, Rust, etc.
- **Linters**: ESLint, Pylint, golangci-lint, etc.
- **Formatters**: Prettier, Black, gofmt, etc.
- **Trouble.nvim**: UI mejorada para listas
- **nvim-lightbulb**: Indicador visual de code actions
- **tiny-inline-diagnostic**: Diagnósticos minimalistas

## 📚 Referencias

- `:h diagnostic` - Documentación de diagnósticos
- `:h lsp` - Language Server Protocol
- `:h vim.diagnostic` - API de diagnósticos
- `:h trouble` - Plugin Trouble.nvim

---

**Nota**: Todos estos comandos y visualizaciones funcionan automáticamente cuando hay un LSP activo en el buffer (archivos de código con servidor LSP configurado).

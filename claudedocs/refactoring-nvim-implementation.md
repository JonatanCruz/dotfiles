# Refactoring.nvim Implementation

## Archivos Creados/Modificados

### Nuevo archivo
- `/Users/jonatan/dotfiles/nvim/.config/nvim/lua/plugins/tools/refactoring.lua`

### Archivos modificados
- `/Users/jonatan/dotfiles/nvim/.config/nvim/lua/plugins/ui/whichkey.lua`
  - Actualizado grupo `<leader>r` de "Reload/Rename" a "Refactor/Rename"

## Configuración Implementada

### Plugin
- **ThePrimeagen/refactoring.nvim**
- Dependencies: plenary.nvim, nvim-treesitter (ya instalados)
- Lazy loading con `keys` trigger (carga solo cuando se usa)

### Keybindings

#### Extract Operations (Visual Mode)
| Keybinding | Operación | Descripción |
|------------|-----------|-------------|
| `<leader>re` | Extract Function | Extrae selección a función |
| `<leader>rf` | Extract Function To File | Extrae función a archivo separado |
| `<leader>rv` | Extract Variable | Extrae selección a variable |

#### Inline Operations (Normal/Visual Mode)
| Keybinding | Operación | Descripción |
|------------|-----------|-------------|
| `<leader>ri` | Inline Variable | Inline variable bajo cursor/selección |
| `<leader>rI` | Inline Function | Inline función bajo cursor |

#### Extract Block Operations (Normal Mode)
| Keybinding | Operación | Descripción |
|------------|-----------|-------------|
| `<leader>rb` | Extract Block | Extrae bloque a función |
| `<leader>rbf` | Extract Block To File | Extrae bloque a archivo |

#### Debug Helpers
| Keybinding | Operación | Descripción |
|------------|-----------|-------------|
| `<leader>rd` | Debug Print Variable | Inserta print statement |
| `<leader>rc` | Debug Cleanup Prints | Limpia todos los prints |

#### Telescope Integration
| Keybinding | Operación | Descripción |
|------------|-----------|-------------|
| `<leader>rs` | Select Refactor | Selector Telescope de operaciones |

### Características

1. **Success Messages**: Habilitado para notificaciones de operaciones exitosas
2. **Type Prompts**: Deshabilitados para la mayoría de lenguajes (Go, Java, C/C++)
3. **Telescope Integration**: Selector visual de operaciones de refactoring
4. **Language Support**:
   - TypeScript/JavaScript
   - Python
   - Lua
   - Go
   - C/C++
   - Rust
   - Java

## Testing Manual

### 1. Extract Function (Visual Mode)
```typescript
// Seleccionar este bloque en visual mode:
const result = data.map(item => item.value)
  .filter(val => val > 0)
  .reduce((acc, val) => acc + val, 0);

// Presionar: <leader>re
// Resultado esperado: Prompt para nombre de función
// Output: función extraída con la selección
```

### 2. Extract Variable (Visual Mode)
```python
# Seleccionar esta expresión:
items.filter(lambda x: x.price > 100 and x.available)

# Presionar: <leader>rv
# Resultado esperado: Prompt para nombre de variable
# Output: variable extraída con la expresión
```

### 3. Inline Variable (Normal Mode)
```javascript
// Cursor sobre 'maxValue':
const maxValue = 100;
const result = data.filter(x => x.value < maxValue);

// Presionar: <leader>ri
// Resultado esperado: maxValue es inlineado
// Output: data.filter(x => x.value < 100)
```

### 4. Telescope Selector (Visual Mode)
```lua
-- Seleccionar código en visual mode
-- Presionar: <leader>rs
-- Resultado esperado: Telescope picker con opciones:
--   - Extract Function
--   - Extract Variable
--   - Inline Variable
```

### 5. Debug Print (Visual/Normal Mode)
```python
# Seleccionar variable o poner cursor sobre ella:
user_data = get_user()

# Presionar: <leader>rd
# Resultado esperado: print statement insertado
# Output: print(f"user_data: {user_data}")
```

## Verificación de Instalación

1. **Abrir Neovim**: `nvim`
2. **Lazy.nvim auto-sync**: El plugin se instalará automáticamente
3. **Manual sync**: `:Lazy sync`
4. **Verificar plugin**: `:Lazy` → Buscar "refactoring.nvim"
5. **Verificar keybindings**: `<leader>` → Ver grupo "Refactor/Rename"

## Integración con Workflow Existente

### Conflictos Evitados
- `<leader>rn` (LSP Rename) se mantiene sin cambios
- Nuevo grupo `<leader>r` incluye tanto refactoring como rename

### WhichKey Integration
- Grupo actualizado a "Refactor/Rename"
- Íconos y descripciones para todas las operaciones
- Submenu visual de operaciones disponibles

## Lenguajes Soportados

✅ **Completamente Soportados:**
- TypeScript/JavaScript (React, Node.js)
- Python
- Lua
- Go
- Rust

⚠️ **Soporte Parcial:**
- C/C++ (requiere configuración adicional para tipos)
- Java (requiere configuración adicional para tipos)

## Notas de Uso

1. **Visual Mode**: La mayoría de operaciones funcionan en visual mode
2. **Treesitter Required**: Requiere parser de Treesitter para el lenguaje
3. **Success Notifications**: Las operaciones exitosas muestran notificación
4. **Undo Support**: Todas las operaciones son reversibles con `u`

## Siguiente Paso

**Testing en Neovim:**
1. Abrir archivo de código: `nvim test.ts`
2. Seleccionar código en visual mode: `v` o `V`
3. Presionar `<leader>re` para extract function
4. Verificar prompt y resultado

**Troubleshooting:**
- Si el plugin no carga: `:Lazy sync`
- Si los keybindings no funcionan: `:checkhealth which-key`
- Si Treesitter falla: `:TSUpdate`

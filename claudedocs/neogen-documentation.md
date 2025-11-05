# Neogen - Generación Automática de Documentación

## Descripción

Neogen es un generador automático de documentación (docstrings, JSDoc, TSDoc, etc.) integrado con Treesitter. Analiza el código y genera templates de documentación apropiados para cada lenguaje.

## Instalación

**Archivo:** `/Users/jonatan/dotfiles/nvim/.config/nvim/lua/plugins/tools/neogen.lua`

**Dependencias:**
- `nvim-treesitter` (ya instalado)
- `LuaSnip` (para navegación entre placeholders)

## Keybindings

Todos bajo el prefijo `<leader>n` (New/Generate Docs):

| Keybinding | Acción | Descripción |
|------------|--------|-------------|
| `<leader>nf` | Generate Function Docs | Documenta función bajo el cursor |
| `<leader>nc` | Generate Class Docs | Documenta clase bajo el cursor |
| `<leader>nt` | Generate Type Docs | Documenta tipo/interface bajo el cursor |
| `<leader>nF` | Generate File Docs | Documenta el archivo completo |
| `<leader>ng` | Generate Docs (auto) | Auto-detecta el tipo y genera |

## Uso Básico

### Documentar Función

1. Coloca el cursor en la línea de definición de la función
2. Presiona `<leader>nf`
3. Neogen generará el template de documentación
4. Usa `Tab` para navegar entre los placeholders `[TODO: ...]`
5. Completa la información

**Ejemplo JavaScript:**

```javascript
// Cursor aquí ↓
function calculateTotal(price, tax, discount) {
  return price * (1 + tax) - discount;
}
```

**Presiona `<leader>nf` →**

```javascript
/**
 * [TODO: description]
 * @param {*} price - [TODO: parameter]
 * @param {*} tax - [TODO: parameter]
 * @param {*} discount - [TODO: parameter]
 * @returns {*} [TODO: return value]
 */
function calculateTotal(price, tax, discount) {
  return price * (1 + tax) - discount;
}
```

**Después de completar:**

```javascript
/**
 * Calculate the total price with tax and discount applied
 * @param {number} price - Base price of the item
 * @param {number} tax - Tax rate (e.g., 0.21 for 21%)
 * @param {number} discount - Discount amount to subtract
 * @returns {number} Final price after tax and discount
 */
function calculateTotal(price, tax, discount) {
  return price * (1 + tax) - discount;
}
```

### Documentar Clase

**Ejemplo TypeScript:**

```typescript
// Cursor aquí ↓
class UserService {
  constructor(private apiUrl: string) {}

  async getUser(id: string): Promise<User> {
    // ...
  }
}
```

**Presiona `<leader>nc` →**

```typescript
/**
 * [TODO: class description]
 */
class UserService {
  constructor(private apiUrl: string) {}

  async getUser(id: string): Promise<User> {
    // ...
  }
}
```

### Documentar Type/Interface

**Ejemplo TypeScript:**

```typescript
// Cursor aquí ↓
interface UserConfig {
  name: string;
  email: string;
  role: 'admin' | 'user';
}
```

**Presiona `<leader>nt` →**

```typescript
/**
 * [TODO: type description]
 */
interface UserConfig {
  name: string;
  email: string;
  role: 'admin' | 'user';
}
```

### Auto-Detección

Si no estás seguro del tipo, usa `<leader>ng`:

- Neogen detectará automáticamente si estás en función, clase, tipo, etc.
- Generará el template apropiado

## Soporte por Lenguaje

| Lenguaje | Convención | Ejemplo |
|----------|------------|---------|
| **JavaScript** | JSDoc | `/** @param {type} name */` |
| **TypeScript** | TSDoc | `/** @param name - Description */` |
| **React (JS/TS)** | JSDoc/TSDoc | Same as above |
| **Lua** | LDoc | `--- Description` |
| **Python** | Google Docstrings | `"""Description\n\nArgs:\n..."""` |
| **Rust** | Rustdoc | `/// Description` |
| **Go** | Godoc | `// Description` |
| **C/C++** | Doxygen | `/** @brief Description */` |
| **Java** | Javadoc | `/** @param name Description */` |
| **PHP** | PHPDoc | `/** @param type $name */` |
| **Ruby** | RDoc | `# Description` |
| **Shell** | Google Bash | `# Description` |

## Navegación con LuaSnip

Neogen integra con LuaSnip para navegación eficiente:

1. Después de generar documentación, el cursor se posiciona en el primer placeholder
2. **Tab** → Salta al siguiente placeholder
3. **Shift+Tab** → Regresa al placeholder anterior
4. **Enter** → Acepta y sale del snippet

**Placeholders disponibles:**
- `[TODO: description]` → Descripción general
- `[TODO: parameter]` → Descripción de parámetro
- `[TODO: return value]` → Descripción del valor de retorno
- `[TODO: throws]` → Excepciones lanzadas
- `[TODO: class description]` → Descripción de clase
- `[TODO: type]` → Descripción de tipo

## Workflow Recomendado

### 1. Desarrollo TDD (Test-Driven Documentation)

```
Escribir función → <leader>nf → Documentar → Implementar
```

Documentar primero clarifica la interfaz pública antes de implementar.

### 2. Documentación Retroactiva

```
Código legacy → <leader>ng → Completar docs → Refactor si es necesario
```

### 3. Revisión de Código

Antes de commit/PR:
1. Buscar funciones sin documentar: `/function.*{` sin `/**` arriba
2. Documentar con `<leader>nf`
3. Completar placeholders con información significativa

## Casos de Uso Avanzados

### Documentar Archivo Completo

Para agregar header de archivo (copyright, license, etc.):

```typescript
// Presiona <leader>nF en la primera línea
```

**Genera:**

```typescript
/**
 * [TODO: file description]
 * @file
 */

// ... resto del código
```

### TypeScript con Tipos Complejos

```typescript
// Cursor aquí ↓
function processData<T extends User>(
  data: T[],
  filter: (item: T) => boolean
): T[] {
  return data.filter(filter);
}
```

**Presiona `<leader>nf` →**

```typescript
/**
 * [TODO: description]
 * @template T
 * @param {T[]} data - [TODO: parameter]
 * @param {(item: T) => boolean} filter - [TODO: parameter]
 * @returns {T[]} [TODO: return value]
 */
function processData<T extends User>(
  data: T[],
  filter: (item: T) => boolean
): T[] {
  return data.filter(filter);
}
```

### Python con Google Docstrings

```python
# Cursor aquí ↓
def calculate_statistics(data, method='mean', weights=None):
    pass
```

**Presiona `<leader>nf` →**

```python
def calculate_statistics(data, method='mean', weights=None):
    """[TODO: description]

    Args:
        data: [TODO: parameter]
        method: [TODO: parameter]
        weights: [TODO: parameter]

    Returns:
        [TODO: return value]
    """
    pass
```

## Integración con WhichKey

Si tienes `which-key.nvim` instalado, Neogen automáticamente registra el grupo:

**Presiona `<leader>n` → Ver menú:**
```
New/Generate Docs 󰏫
  f → Generate Function Docs
  c → Generate Class Docs
  t → Generate Type Docs
  F → Generate File Docs
  g → Generate Docs (auto)
```

## Configuración Personalizada

### Cambiar Placeholders

Edita `neogen.lua`:

```lua
placeholders_text = {
  ["description"] = "[Describe aquí]",  -- Cambiar texto
  ["parameter"] = "[Param: ]",
  -- ...
}
```

### Agregar Nuevo Lenguaje

```lua
languages = {
  kotlin = {
    template = {
      annotation_convention = "kdoc",
    },
  },
}
```

### Cambiar Highlight de Placeholders

```lua
placeholders_hl = "Comment",  -- Cambiar de DiagnosticHint a Comment
```

## Troubleshooting

### "No documentation found"

**Causa:** Cursor no está en línea de definición

**Solución:** Coloca el cursor en la línea `function`, `class`, `interface`, etc.

### "Treesitter parser not found"

**Causa:** Falta parser de Treesitter para el lenguaje

**Solución:**
```vim
:TSInstall <language>
```

### Placeholders no navegables

**Causa:** LuaSnip no está configurado correctamente

**Solución:** Verifica que `cmp.lua` tiene integración con LuaSnip:
```lua
snippet = {
  expand = function(args)
    require('luasnip').lsp_expand(args.body)
  end,
}
```

### Documentación incorrecta generada

**Causa:** Convención incorrecta para el lenguaje

**Solución:** Ajusta `annotation_convention` en `languages` config

## Comandos Útiles

### Verificar Configuración

```vim
:lua print(vim.inspect(require('neogen').get_config()))
```

### Verificar Soporte de Lenguaje

```vim
:lua print(vim.inspect(require('neogen').get_languages()))
```

### Regenerar Documentación

Si ya existe documentación:
1. Elimina el bloque de comentario existente
2. Presiona `<leader>nf` para regenerar

## Comparación con Alternativas

| Feature | Neogen | Copilot | Manual |
|---------|--------|---------|--------|
| **Estructura correcta** | ✅ Siempre | ⚠️ A veces | ⚠️ Depende |
| **Detecta parámetros** | ✅ Automático | ✅ Automático | ❌ Manual |
| **Navegación placeholders** | ✅ LuaSnip | ❌ No | ❌ No |
| **Multi-lenguaje** | ✅ 15+ lenguajes | ✅ Muchos | ❌ Manual |
| **Offline** | ✅ Local | ❌ Requiere internet | ✅ Local |
| **Consistencia** | ✅ 100% | ⚠️ Variable | ⚠️ Variable |

## Tips y Mejores Prácticas

1. **Documenta durante desarrollo:** Usa `<leader>nf` inmediatamente después de escribir la firma de la función
2. **Completa siempre placeholders:** No dejes `[TODO: ...]` en código commiteado
3. **Usa auto-detect:** `<leader>ng` es más rápido cuando no estás seguro del tipo
4. **Integra con pre-commit:** Agrega hook para verificar TODOs en documentación
5. **Hotkey muscle memory:** Practica `<leader>nf` hasta que sea automático

## Performance

- **Lazy loading:** Solo carga cuando usas `<leader>n`
- **Treesitter nativo:** No requiere parsing adicional
- **Sin latencia:** Generación instantánea (local)

## Recursos

- **Documentación oficial:** https://github.com/danymat/neogen
- **Templates disponibles:** https://github.com/danymat/neogen/tree/main/lua/neogen/templates
- **Convenciones soportadas:** Ver tabla "Soporte por Lenguaje" arriba

## Changelog

- **2024-11-04:** Implementación inicial con 15+ lenguajes soportados

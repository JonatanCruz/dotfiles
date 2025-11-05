# Neogen Quick Start Guide

## Installation (Already Done ✅)

El plugin ya está instalado en:
```
/Users/jonatan/dotfiles/nvim/.config/nvim/lua/plugins/tools/neogen.lua
```

## First Time Setup

### Step 1: Sync Plugins

Abre Neovim y sincroniza plugins:

```bash
nvim
```

Dentro de Neovim:
```vim
:Lazy sync
```

**Verificar:** Neogen debe aparecer en la lista y descargarse automáticamente.

### Step 2: Verify Treesitter Parsers

Verifica que tienes los parsers necesarios:

```vim
:TSInstallInfo
```

**Instalar parsers comunes:**
```vim
:TSInstall javascript typescript python lua rust go
```

### Step 3: Check Keybindings

Verifica que los keybindings estén cargados:

```vim
:map <leader>n
```

**Deberías ver:**
```
n  <leader>nf    Generate Function Docs
n  <leader>nc    Generate Class Docs
n  <leader>nt    Generate Type Docs
n  <leader>nF    Generate File Docs
n  <leader>ng    Generate Docs (auto-detect)
```

## Your First Documentation

### Example 1: JavaScript Function

1. **Crea un archivo de prueba:**
   ```bash
   nvim ~/test-neogen.js
   ```

2. **Escribe una función:**
   ```javascript
   function calculateTotal(price, tax, discount) {
     return price * (1 + tax) - discount;
   }
   ```

3. **Coloca el cursor en la línea `function calculateTotal`**

4. **Presiona:** `<Space>nf` (Space es tu leader key)

5. **Resultado:**
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

6. **Completa la documentación:**
   - El cursor está en el primer `[TODO: description]`
   - Escribe la descripción
   - Presiona **Tab** para ir al siguiente placeholder
   - Completa cada parámetro
   - Presiona **Enter** cuando termines

7. **Resultado final:**
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

### Example 2: TypeScript Class

1. **Crea un archivo TypeScript:**
   ```bash
   nvim ~/test-neogen.ts
   ```

2. **Escribe una clase:**
   ```typescript
   class UserService {
     constructor(private apiUrl: string) {}

     async getUser(id: string): Promise<User> {
       const response = await fetch(`${this.apiUrl}/users/${id}`);
       return response.json();
     }
   }
   ```

3. **Coloca el cursor en `class UserService`**

4. **Presiona:** `<Space>nc` (c = class)

5. **Completa la documentación de la clase**

6. **Luego documenta el método:**
   - Coloca cursor en `async getUser`
   - Presiona `<Space>nf`
   - Completa parámetros y return

## Keybindings Reference Card

```
┌─────────────────────────────────────────┐
│         NEOGEN KEYBINDINGS              │
├─────────────┬───────────────────────────┤
│ <leader>nf  │ Function Documentation    │
│ <leader>nc  │ Class Documentation       │
│ <leader>nt  │ Type/Interface Docs       │
│ <leader>nF  │ File Documentation        │
│ <leader>ng  │ Auto-detect Type          │
├─────────────┴───────────────────────────┤
│ Navigation (after generation):          │
│   Tab         → Next placeholder        │
│   Shift+Tab   → Previous placeholder    │
│   Enter       → Exit snippet mode       │
└─────────────────────────────────────────┘

Memory Tip: "n" = "New" documentation
```

## Common Use Cases

### Use Case 1: New Function (Development Flow)

```
Write function signature → <leader>nf → Complete docs → Implement
```

**Why:** Documenting first clarifies the interface and expected behavior.

### Use Case 2: Existing Code (Documentation Sprint)

```
Open file → Find undocumented function → <leader>nf → Complete → Next
```

**Why:** Quick way to add documentation to legacy code.

### Use Case 3: Code Review (Pre-commit)

```
Before git add → Check for [TODO: ...] → Complete all → Commit
```

**Why:** Ensure no incomplete documentation is committed.

### Use Case 4: API Development (TypeScript)

```
Define interface → <leader>nt → Document fields → Implement class
```

**Why:** Clear API contracts before implementation.

## Language-Specific Tips

### JavaScript
- Use `<leader>nf` for functions
- JSDoc format: `@param {type} name - description`
- Complete type annotations manually if TypeScript not available

### TypeScript
- Use `<leader>nt` for interfaces/types first
- TSDoc format: `@param name - description` (types already in signature)
- Document public API methods

### Python
- Google Docstrings format
- Use `<leader>nf` for functions
- Complete Args, Returns, Raises sections

### React Components
```tsx
// Cursor here ↓
export function Button({ label, onClick, disabled = false }: ButtonProps) {
  return <button onClick={onClick} disabled={disabled}>{label}</button>;
}

// Press <leader>nf →

/**
 * [TODO: description]
 * @param props - [TODO: parameter]
 * @returns [TODO: return value]
 */
export function Button({ label, onClick, disabled = false }: ButtonProps) {
  return <button onClick={onClick} disabled={disabled}>{label}</button>;
}

// Complete to:

/**
 * Reusable button component with click handling
 * @param props - Button configuration and handlers
 * @param props.label - Text to display in button
 * @param props.onClick - Click event handler
 * @param props.disabled - Whether button is disabled
 * @returns Rendered button element
 */
export function Button({ label, onClick, disabled = false }: ButtonProps) {
  return <button onClick={onClick} disabled={disabled}>{label}</button>;
}
```

## Troubleshooting

### Problem: Nothing happens when I press `<leader>nf`

**Solutions:**
1. Check you're in Normal mode (press `Esc`)
2. Verify cursor is on function definition line
3. Check keybinding: `:map <leader>nf`
4. Manually load plugin: `:Lazy load neogen`

### Problem: "No documentation found"

**Solutions:**
1. Move cursor to exact line of `function`, `class`, etc.
2. Check Treesitter parser installed: `:TSInstallInfo`
3. Install missing parser: `:TSInstall <language>`

### Problem: Placeholders not highlighted

**Solutions:**
1. Check colorscheme supports `DiagnosticHint`
2. Test with: `:highlight DiagnosticHint`
3. If needed, change in config to: `placeholders_hl = "Comment"`

### Problem: Can't navigate with Tab

**Solutions:**
1. Check LuaSnip loaded: `:lua print(require('luasnip'))`
2. Verify cmp.lua has LuaSnip integration
3. Try `Ctrl+j` / `Ctrl+k` as alternative navigation

## Practice Exercises

### Exercise 1: JavaScript Functions (5 min)

Document these 3 functions:

```javascript
function add(a, b) {
  return a + b;
}

function fetchUserData(userId) {
  return fetch(`/api/users/${userId}`).then(r => r.json());
}

function processItems(items, callback) {
  return items.map(callback);
}
```

**Goal:** Practice `<leader>nf` and Tab navigation.

### Exercise 2: TypeScript Types (5 min)

Document these types:

```typescript
interface User {
  id: string;
  name: string;
  email: string;
}

type ApiResponse<T> = {
  data: T;
  error: Error | null;
};
```

**Goal:** Practice `<leader>nt` for types.

### Exercise 3: Classes (10 min)

Document this class and its methods:

```typescript
class DataCache<T> {
  constructor(private ttl: number = 60000) {}

  set(key: string, value: T): void {
    // ...
  }

  get(key: string): T | undefined {
    // ...
  }
}
```

**Goal:** Practice `<leader>nc` for class, `<leader>nf` for methods.

## Daily Workflow Integration

### Morning Routine
```bash
# Before starting work, quick review:
nvim project/src/
# Press <leader>ff (find files)
# Look for undocumented functions
# Document 2-3 before coding
```

### During Development
```
Write function → <leader>nf → Document → Implement
```

### Before Commit
```bash
# Search for incomplete docs:
git diff | grep -i "TODO:"

# If found, complete them before commit
```

### Code Review
```
Review PR → Check for [TODO: ...] → Request completion if found
```

## Advanced Usage

### Custom Placeholder Text

Edit `neogen.lua` to customize placeholders:

```lua
placeholders_text = {
  ["description"] = "Describe the purpose here",
  ["parameter"] = "Parameter details",
  -- ... your preferences
}
```

### Project-Specific Templates

Create `.neogen.lua` in project root for custom templates (check Neogen docs).

### Integration with Git Hooks

Add pre-commit hook to check for incomplete docs:

```bash
# .git/hooks/pre-commit
#!/bin/bash
if git diff --cached | grep -q '\[TODO:'; then
  echo "Error: Incomplete documentation found (contains [TODO:])"
  exit 1
fi
```

## Resources

- **Full Documentation:** `~/dotfiles/claudedocs/neogen-documentation.md`
- **Test Examples:** `~/dotfiles/claudedocs/neogen-test-examples.{js,ts}`
- **Official Docs:** https://github.com/danymat/neogen

## Next Steps

1. ✅ Complete this quick start guide
2. ⏳ Practice with test files (15 minutes)
3. ⏳ Document 5 functions in your current project
4. ⏳ Add to daily workflow (new function → document → implement)
5. ⏳ Share with team for consistent documentation standards

---

**You're ready to go!** Open a file and try `<leader>nf` on a function. 🚀

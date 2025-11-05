# Aerial.nvim Implementation - Symbol Outline Navigation

**Date**: 2025-11-04
**Plugin**: stevearc/aerial.nvim
**Location**: `/Users/jonatan/dotfiles/nvim/.config/nvim/lua/plugins/tools/aerial.lua`

## Overview

Implementación de aerial.nvim para navegación rápida mediante outline de símbolos (funciones, clases, métodos, etc.) en archivos grandes. El plugin usa LSP como fuente primaria y Treesitter como fallback.

## Architecture

### Backend Priority
1. **LSP** (Primary): Mejor precisión y contexto semántico
2. **Treesitter** (Fallback): Parsing sintáctico cuando LSP no disponible
3. **Markdown**: Headers y estructura de documentos MD
4. **Man**: Páginas de manual

### Layout Configuration
- **Position**: Panel lateral derecho
- **Width**: Adaptativo (25-40 caracteres, max 20% del ancho)
- **Behavior**: Auto-resize según contenido
- **Placement**: Edge (borde de la ventana)

## Keybindings

### Global Keymaps (fuera del panel)

| Keymap | Comando | Descripción |
|--------|---------|-------------|
| `<leader>o` | `AerialToggle!` | Toggle outline (con refresh forzado) |
| `<leader>ot` | `AerialToggle` | Toggle outline (sin refresh) |
| `<leader>on` | `AerialNext` | Siguiente símbolo |
| `<leader>op` | `AerialPrev` | Símbolo anterior |

### Internal Keymaps (dentro del panel Aerial)

#### Navigation
- `<CR>`, `o`: Jump al símbolo
- `<C-v>`: Jump en vsplit
- `<C-s>`: Jump en split horizontal
- `{`, `}`: Previous/Next symbol
- `[[`, `]]`: Previous/Next symbol (up level)

#### Scrolling
- `p`: Scroll to symbol
- `<C-j>`, `<C-k>`: Down/Up and scroll

#### Tree Folding (Vim-style)
- `za`: Toggle fold
- `zA`: Toggle fold recursively
- `zo`, `zc`: Open/Close fold
- `zO`, `zC`: Open/Close recursively
- `zr`, `zm`: Increase/Decrease fold level
- `zR`, `zM`: Open/Close all folds
- `zx`, `zX`: Sync folds

#### Utilities
- `?`, `g?`: Show help
- `q`: Close panel

### Alternative Tree Navigation
- `l`, `h`: Open/Close (alternativo a zo/zc)
- `L`, `H`: Open/Close recursively

## Symbol Filtering

Solo se muestran símbolos principales para reducir ruido:
- Class
- Constructor
- Enum
- Function
- Interface
- Module
- Method
- Struct

## Features

### Auto-Detection
- **Nerd Font Icons**: Auto-detect desde nvim-web-devicons
- **Backend Selection**: Auto-selección según disponibilidad
- **Content Adaptation**: Ajuste dinámico a tipo de archivo

### Highlighting
- **Current Symbol**: Highlight automático del símbolo bajo cursor
- **On Jump**: Highlight temporal (300ms) al saltar
- **On Hover**: Highlight al hacer hover

### LSP Integration
- **Diagnostic Trigger**: Actualización al recibir diagnósticos
- **Error Handling**: Actualiza incluso con errores LSP
- **Update Delay**: 300ms para evitar actualizaciones excesivas
- **Priority System**: Method > Function > Class > Interface

### Treesitter Integration
- **Fallback Mode**: Cuando LSP no disponible
- **Update Delay**: 300ms
- **Syntax-based**: Parsing sintáctico puro

## Color Theme (Dracula)

### Panel Colors
- **Background**: Transparente (hereda terminal)
- **Border**: Primary color (Dracula purple)
- **Selection**: Surface0 (highlight subtle)
- **Guides**: Overlay0 (líneas de indentación)

### Symbol Colors
- **Class/Struct**: Secondary (cyan)
- **Function/Method**: Green
- **Interface**: Mauve
- **Enum**: Peach
- **Constructor**: Yellow
- **Module**: Primary (purple)

## WhichKey Integration

Grupo registrado en WhichKey:
```lua
{ "<leader>o", group = "Outline/Symbols", icon = "󰘦" }
```

Comandos visibles en WhichKey al presionar `<leader>o`:
- Toggle Outline
- Toggle Outline (Treesitter)
- Next Symbol
- Previous Symbol

## Lazy Loading

Plugin se carga SOLO cuando:
- Se presiona cualquier keybinding `<leader>o*`
- Se ejecuta manualmente `:AerialToggle`

Esto mejora startup time de Neovim.

## Usage Examples

### Basic Workflow
1. Abrir archivo grande (ej. `main.ts` con 500+ líneas)
2. Presionar `<leader>o` → Panel outline aparece a la derecha
3. Navegar con `j/k` por los símbolos
4. Presionar `<CR>` para saltar al símbolo
5. Panel permanece abierto para navegación continua

### Advanced Navigation
1. Abrir outline: `<leader>o`
2. Collapse todos los niveles: `zM` (dentro del panel)
3. Expand top-level: `zR`
4. Navigate con `{` y `}` entre símbolos del mismo nivel
5. Jump con `o` o `<CR>`

### Split Workflow
1. Panel outline abierto
2. Seleccionar símbolo
3. `<C-v>` → Abre símbolo en vsplit vertical
4. Continuar navegando en outline para otros splits

## Implementation Details

### File Location
```
nvim/.config/nvim/lua/plugins/tools/aerial.lua
```

### Dependencies
- nvim-treesitter (already installed)
- nvim-web-devicons (already installed)

### Configuration Pattern
```lua
return {
  "stevearc/aerial.nvim",
  dependencies = { ... },
  keys = { ... },  -- Lazy loading trigger
  opts = { ... },  -- Configuration
  config = function(_, opts)
    require("aerial").setup(opts)
    -- Custom highlights with Dracula colors
  end,
}
```

## Testing Plan

### Manual Tests
1. **Basic Toggle**
   - Open any `.ts` or `.lua` file
   - Press `<leader>o`
   - Verify panel opens on right side

2. **LSP Backend**
   - Open TypeScript file with LSP active
   - Verify symbols appear (functions, classes, interfaces)
   - Check icons are properly rendered

3. **Treesitter Fallback**
   - Open file without LSP (e.g., unknown language)
   - Verify Treesitter backend activates
   - Check symbols still appear

4. **Navigation**
   - Select symbol with `j/k`
   - Press `<CR>` → Verify jump works
   - Press `<C-v>` → Verify vsplit works

5. **Folding**
   - Press `zM` → All folds closed
   - Press `zR` → All folds open
   - Press `za` on item → Toggle individual fold

6. **WhichKey Integration**
   - Press `<leader>` → Wait for WhichKey popup
   - Verify `o` group appears with icon `󰘦`
   - Press `o` → Verify sub-commands visible

### Edge Cases
- Empty file → No symbols, panel empty
- Very large file (1000+ symbols) → Performance check
- File without functions → Should show available symbols (variables, etc.)
- Split windows → Aerial attaches per-window correctly

## Best Practices

### When to Use
✅ Large files (>200 lines)
✅ Complex class hierarchies
✅ Unfamiliar codebases
✅ Refactoring sessions
✅ Code reviews

### When NOT to Use
❌ Small files (<50 lines)
❌ Simple scripts
❌ Configuration files

### Workflow Tips
1. Keep outline open during refactoring
2. Use `{` and `}` for quick navigation between methods
3. Fold classes/modules to see high-level structure
4. Use vsplit (`<C-v>`) to compare symbols side-by-side

## Comparison with Alternatives

### vs Telescope Symbols
- **Aerial**: Persistent panel, tree view, real-time updates
- **Telescope**: Fuzzy search, one-time selection, modal interface

### vs nvim-tree
- **Aerial**: Code symbols, semantic navigation
- **nvim-tree**: File system, directory navigation

### vs Tagbar
- **Aerial**: Modern, LSP-first, Lua-based, Treesitter fallback
- **Tagbar**: Legacy, ctags-based, Vimscript, slower

## Known Limitations

1. **LSP Required**: Best experience requires LSP server running
2. **Symbol Types**: Limited to filter_kind symbols (by design)
3. **Update Delay**: 300ms delay for performance (configurable)
4. **No Preview**: No hover preview (intentional for simplicity)

## Future Enhancements (Optional)

- [ ] Custom symbol priorities per language
- [ ] Symbol search within outline
- [ ] Collapse on file type (e.g., always collapse imports)
- [ ] Integration with Telescope for fuzzy symbol search
- [ ] Auto-open outline for large files (>X lines)

## Resources

- **Official Docs**: https://github.com/stevearc/aerial.nvim
- **LSP Spec**: https://microsoft.github.io/language-server-protocol/
- **Treesitter**: https://tree-sitter.github.io/tree-sitter/
- **Nerd Fonts**: https://www.nerdfonts.com/cheat-sheet

## Conclusion

Aerial.nvim proporciona navegación eficiente en archivos grandes mediante un panel de símbolos persistente y actualizado en tiempo real. La integración con LSP garantiza precisión semántica, mientras que el fallback a Treesitter asegura funcionalidad básica sin LSP.

La configuración sigue los estándares del dotfiles:
- ✅ Lazy loading para startup rápido
- ✅ Colores Dracula con transparencia
- ✅ Keybindings Vim-style
- ✅ Integración WhichKey
- ✅ Documentación inline exhaustiva

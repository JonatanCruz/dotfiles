# Testing Guide - Custom Snippets

Guía de testing para verificar que todos los snippets funcionan correctamente.

## Pre-requisitos

1. Reinicia Neovim o ejecuta:
   ```vim
   :Lazy sync
   :source ~/.config/nvim/init.lua
   ```

2. Verifica que LuaSnip esté cargado:
   ```vim
   :lua print(vim.inspect(require("luasnip")))
   ```

## Test TypeScript (.ts)

1. Crea archivo de prueba: `nvim test.ts`
2. Entra en modo INSERT: `i`
3. Prueba cada snippet:

```typescript
// Test 1: interface
interface
// Presiona Tab → Debe expandir a interface completa

// Test 2: arrow
arrow
// Presiona Tab → Debe crear arrow function con tipos

// Test 3: async
async
// Presiona Tab → Debe crear función async con Promise

// Test 4: log
log
// Presiona Tab → Debe crear console.log con variable repetida
```

**Resultado esperado:** Todos los snippets se expanden correctamente y la navegación con Tab funciona.

## Test React TypeScript (.tsx)

1. Crea archivo de prueba: `nvim test.tsx`
2. Entra en modo INSERT: `i`
3. Prueba snippets clave:

```typescript
// Test 1: fc (Functional Component)
fc
// Presiona Tab → Componente completo con interface

// Test 2: state
state
// Presiona Tab → useState con tipos

// Test 3: effect
effect
// Presiona Tab → useEffect con deps

// Test 4: hook
hook
// Presiona Tab → Custom hook template completo
```

**Resultado esperado:** Componentes React se crean con TypeScript completo y navegación funciona.

## Test Lua (.lua)

1. Crea archivo de prueba: `nvim test.lua`
2. Entra en modo INSERT: `i`
3. Prueba snippets:

```lua
-- Test 1: plugin
plugin
-- Presiona Tab → Lazy.nvim plugin spec

-- Test 2: keymap
keymap
-- Presiona Tab → vim.keymap.set completo

-- Test 3: autocmd
autocmd
-- Presiona Tab → autocommand completo

-- Test 4: func
func
-- Presiona Tab → función con anotaciones
```

**Resultado esperado:** Snippets de Neovim se expanden con sintaxis correcta.

## Test JavaScript (.js)

1. Crea archivo de prueba: `nvim test.js`
2. Entra en modo INSERT: `i`
3. Prueba snippets:

```javascript
// Test 1: arrow
arrow
// Presiona Tab → arrow function

// Test 2: map
map
// Presiona Tab → array.map completo

// Test 3: asynctry
asynctry
// Presiona Tab → async/await con try-catch

// Test 4: class
class
// Presiona Tab → class con constructor
```

**Resultado esperado:** Snippets JavaScript modernos funcionan correctamente.

## Verificación de Navegación

Para cada snippet, verifica:

1. **Tab forward:** Navega al siguiente punto de inserción
2. **Shift+Tab backward:** Vuelve al punto anterior
3. **Placeholders:** El texto por defecto aparece seleccionado
4. **Repetición:** Los nodos `rep()` se actualizan automáticamente

## Verificación de Completion Menu

1. En modo INSERT, presiona `Ctrl+Space`
2. Deberías ver snippets en el menú con `[Snippet]` como fuente
3. Los iconos kind deberían mostrarse correctamente
4. La documentación preview debería funcionar (`Ctrl+f`, `Ctrl+b`)

## Troubleshooting

### Snippet no se expande
```vim
" Verifica el filetype
:set filetype?

" Verifica que LuaSnip tenga snippets cargados
:lua print(vim.inspect(require("luasnip").get_snippets()))

" Recarga snippets manualmente
:lua require("snippets").load()
```

### No aparecen en completion menu
```vim
" Verifica que cmp-luasnip esté activo
:lua print(vim.inspect(require("cmp").get_config()))

" Reinicia completion
:lua require("cmp").setup.buffer()
```

### Navegación con Tab no funciona
```vim
" Verifica keymaps de LuaSnip (puede estar configurado diferente en cmp.lua)
:verbose imap <Tab>
```

## Testing Avanzado

### Test de repetición (rep nodes)

En TypeScript, prueba:
```typescript
log
// Escribe "myVariable" en el primer punto
// El segundo punto debería actualizarse automáticamente
```

### Test de choice nodes (si se implementan)

Verifica que múltiples opciones funcionen correctamente.

### Test de function nodes (si se implementan)

Verifica que generación dinámica funcione correctamente.

## Checklist de Funcionalidad

- [ ] Snippets TypeScript se expanden correctamente
- [ ] Snippets React TypeScript funcionan con imports
- [ ] Snippets Lua funcionan para configuración Neovim
- [ ] Snippets JavaScript funcionan con sintaxis moderna
- [ ] Navegación Tab/Shift+Tab funciona en todos
- [ ] Placeholders con texto por defecto aparecen
- [ ] Nodos rep() se actualizan automáticamente
- [ ] Snippets aparecen en completion menu
- [ ] Documentación preview funciona
- [ ] No hay conflictos con friendly-snippets

## Performance

Los snippets deberían:
- Cargarse en < 100ms al inicio de Neovim
- Expandirse instantáneamente (< 10ms)
- No afectar el tiempo de autocompletado

Para verificar performance:
```vim
:lua vim.cmd('profile start /tmp/profile.log')
:lua vim.cmd('profile func *')
:lua require("snippets").load()
:lua vim.cmd('profile pause')
:lua vim.cmd('noautocmd qall!')
" Luego revisa /tmp/profile.log
```

## Reporte de Issues

Si encuentras problemas, verifica:
1. Versión de Neovim (`:version`)
2. Versión de LuaSnip (`:Lazy`)
3. Configuración de nvim-cmp (`:lua print(vim.inspect(require("cmp").get_config()))`)
4. Logs de error (`:messages`)

# Custom Snippets System

Sistema de snippets personalizados para Neovim usando LuaSnip. Los snippets están organizados por lenguaje y proporcionan plantillas rápidas para código común.

## Estructura

```
snippets/
├── init.lua                # Loader y funciones helper
├── typescript.lua          # Snippets para TypeScript
├── typescriptreact.lua     # Snippets para React con TypeScript
├── lua.lua                 # Snippets para Lua y Neovim
└── javascript.lua          # Snippets para JavaScript
```

## Uso

### Modo de Operación

1. Entra en modo INSERT (`i`, `a`, `o`, etc.)
2. Escribe el trigger del snippet (ej: `fc`, `state`, `func`)
3. Presiona `Tab` o `Ctrl+Space` para expandir
4. Usa `Tab` para navegar entre los puntos de inserción
5. Usa `Shift+Tab` para volver atrás

### Ejemplos por Lenguaje

#### TypeScript (`.ts`)

**Snippets disponibles:**
- `interface` - Interfaz TypeScript
- `type` - Type alias
- `enum` - Enumeración
- `func` - Función con tipos
- `arrow` - Arrow function con tipos
- `async` - Función asíncrona
- `asyncarrow` - Arrow function asíncrona
- `try` - Try-catch simple
- `tryguard` - Try-catch con type guard
- `log` - Console.log con variable
- `error` - Console.error
- `warn` - Console.warn
- `export` - Export const
- `import` - Import statement
- `importd` - Default import

**Ejemplo:**
```typescript
// Escribe: interface <Tab>
interface Name {
  property: type;
}

// Escribe: arrow <Tab>
const name = (param: type): void => {
  // TODO
};
```

#### React TypeScript (`.tsx`)

**Snippets disponibles:**
- `fc` - Functional Component
- `fcc` - Functional Component con children
- `state` - useState hook
- `effect` - useEffect hook
- `effectclean` - useEffect con cleanup
- `callback` - useCallback hook
- `callbackp` - useCallback con parámetros
- `memo` - useMemo hook
- `ref` - useRef hook
- `context` - useContext hook
- `hook` - Custom hook template
- `provider` - Context Provider completo
- `imr` - Import React hooks
- `imrd` - Import React default
- `props` - Component Props interface

**Ejemplo:**
```typescript
// Escribe: fc <Tab>
import { FC } from 'react';

interface ComponentProps {
  // props
}

export const Component: FC<ComponentProps> = ({ props }) => {
  return (
    <div>
      {/* TODO */}
    </div>
  );
};

// Escribe: state <Tab>
const [value, setValue] = useState<string>("");

// Escribe: effect <Tab>
useEffect(() => {
  // TODO
}, [deps]);
```

#### Lua (`.lua`)

**Snippets disponibles:**
- `plugin` - Lazy.nvim plugin spec
- `pluginsimple` - Simple plugin spec
- `func` - Función con anotaciones
- `lfunc` - Función local
- `autocmd` - Autocomando
- `augroup` - Autocomando con grupo
- `keymap` - Keybinding
- `keymapf` - Keybinding con función
- `bkeymap` - Buffer keymap
- `opt` - Vim option
- `g` - Vim global
- `module` - Module table
- `req` - Require statement
- `preq` - Protected require
- `print` - Print con vim.inspect
- `notify` - Vim notify
- `if` - If statement
- `ifelse` - If-else statement
- `for` - For loop
- `fori` - For numeric loop

**Ejemplo:**
```lua
-- Escribe: plugin <Tab>
{
  "author/plugin",
  dependencies = { "dependency" },
  event = "VeryLazy",
  config = function()
    require("plugin").setup({
      -- opts
    })
  end,
}

-- Escribe: keymap <Tab>
vim.keymap.set("n", "<leader>", "<cmd><cr>", { desc = "Description" })

-- Escribe: autocmd <Tab>
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    -- TODO
  end,
})
```

#### JavaScript (`.js`)

**Snippets disponibles:**
- `func` - Function declaration
- `arrow` - Arrow function
- `arrowl` - Arrow function one-liner
- `async` - Async function
- `asyncarrow` - Async arrow function
- `try` - Try-catch
- `promise` - Promise
- `asynctry` - Async/await con try-catch
- `log` - Console.log
- `error` - Console.error
- `warn` - Console.warn
- `table` - Console.table
- `for` - For loop
- `forof` - For-of loop
- `forin` - For-in loop
- `foreach` - ForEach
- `map` - Map
- `filter` - Filter
- `reduce` - Reduce
- `class` - Class
- `export` - Export const
- `exportd` - Export default
- `import` - Import statement
- `importd` - Default import
- `dest` - Destructuring
- `desta` - Array destructuring
- `temp` - Template literal
- `method` - Object method shorthand

**Ejemplo:**
```javascript
// Escribe: arrow <Tab>
const name = (params) => {
  // TODO
};

// Escribe: map <Tab>
const result = array.map((item) => {
  return item
});

// Escribe: asynctry <Tab>
try {
  const result = await asyncFunction();
  // TODO
} catch (error) {
  console.error("Error:", error);
}
```

## Navegación en Snippets

Todos los snippets tienen puntos de inserción numerados que puedes navegar:

- **Tab**: Ir al siguiente punto de inserción
- **Shift+Tab**: Ir al punto de inserción anterior
- **Ctrl+Space**: Expandir snippet o mostrar completions

Algunos puntos de inserción están vinculados (usando `rep()`), lo que significa que al editar uno, el otro se actualiza automáticamente.

## Agregar Nuevos Snippets

Para agregar un nuevo snippet, edita el archivo correspondiente al lenguaje:

```lua
-- En lua/snippets/typescript.lua
s("trigger", fmt([[
  código {}
  más código {}
]], {
  i(1, "primer punto"),
  i(2, "segundo punto"),
})),
```

### Elementos de Snippet

- `i(n, "default")` - Punto de inserción con texto por defecto
- `rep(n)` - Repite el contenido del punto n
- `t("text")` - Texto estático
- `c(n, {option1, option2})` - Choice node (opciones)
- `f(function, args)` - Function node (genera texto dinámicamente)

## Testing

Para probar los snippets:

1. Reinicia Neovim o ejecuta `:source %` en el archivo de configuración
2. Abre un archivo del tipo correspondiente (`.tsx`, `.ts`, `.lua`, `.js`)
3. Entra en modo INSERT
4. Escribe el trigger del snippet
5. Presiona `Tab` para expandir
6. Navega por los puntos de inserción

## Troubleshooting

**Los snippets no se cargan:**
- Verifica que `require("snippets").load()` esté en `lua/plugins/coding/cmp.lua`
- Reinicia Neovim completamente
- Ejecuta `:Lazy sync` para sincronizar plugins

**Los snippets no se expanden:**
- Verifica que estés en modo INSERT
- Confirma que el tipo de archivo sea correcto (`:set filetype?`)
- Revisa que LuaSnip esté instalado (`:Lazy`)

**Conflictos con otros snippets:**
- Los custom snippets tienen prioridad sobre friendly-snippets
- Puedes cambiar el orden de carga en `cmp.lua`

## Personalización

Los snippets se cargan automáticamente basándose en el `filetype` del buffer. Puedes crear nuevos archivos de snippets para otros lenguajes siguiendo el mismo patrón.

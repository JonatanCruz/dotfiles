# Guía de Navegación LSP en Neovim

Esta guía documenta todos los keybindings para navegar entre archivos, funciones y código usando LSP (Language Server Protocol).

## 📍 Navegación Principal (comandos 'g')

### Ir a Definiciones

| Comando | Acción | Descripción |
|---------|--------|-------------|
| `gd` | **Ir a definición** | Salta al archivo donde se define la función/variable |
| `gD` | **Ir a declaración** | Salta a la declaración (útil en C/C++) |
| `gi` | **Ir a implementación** | Salta a la implementación de una interfaz/clase abstracta |
| `gt` | **Ir a type definition** | Salta a la definición del tipo de dato |

### Ver Referencias y Uso

| Comando | Acción | Descripción |
|---------|--------|-------------|
| `gr` | **Ver referencias** | Muestra todos los lugares donde se usa este símbolo |
| `gR` | **Referencias en Trouble** | Abre referencias en ventana Trouble (mejor UI) |

### Información Contextual

| Comando | Acción | Descripción |
|---------|--------|-------------|
| `K` | **Ver documentación** | Muestra documentación del símbolo bajo el cursor |
| `gK` | **Ver firma de función** | Muestra parámetros y tipos de una función |
| `gl` | **Ver diagnóstico** | Muestra error/warning en línea actual |

## 🔧 Acciones de Código (comandos 'leader')

| Comando | Acción | Descripción |
|---------|--------|-------------|
| `<leader>ca` | **Code actions** | Muestra acciones disponibles (refactorings, fixes) |
| `<leader>cr` | **Renombrar** | Renombra símbolo en todo el proyecto |
| `<leader>f` | **Formatear** | Formatea el archivo actual |

## 🐛 Navegación de Diagnósticos (Errores/Warnings)

### Navegar entre problemas

| Comando | Acción | Descripción |
|---------|--------|-------------|
| `]d` | **Siguiente diagnóstico** | Va al próximo error/warning |
| `[d` | **Diagnóstico anterior** | Va al error/warning previo |
| `]e` | **Siguiente error** | Va solo al próximo ERROR (ignora warnings) |
| `[e` | **Error anterior** | Va solo al error previo (ignora warnings) |

### Ver lista de problemas

| Comando | Acción | Descripción |
|---------|--------|-------------|
| `<leader>d` | **Ver diagnóstico** | Ventana flotante con detalles del error |
| `<leader>q` | **Lista de diagnósticos** | Abre location list con todos los problemas |
| `<leader>xx` | **Toggle Trouble** | Abre/cierra ventana Trouble |
| `<leader>xd` | **Document diagnostics** | Problemas del archivo actual |
| `<leader>xw` | **Workspace diagnostics** | Problemas de todo el proyecto |

## 🎯 Flujo de Trabajo Típico

### Escenario 1: Entender una función desconocida

```
1. Posiciona cursor sobre la función
2. K          → Ver qué hace (documentación)
3. gd         → Ir a su definición
4. gr         → Ver dónde se usa
5. Ctrl+o     → Volver atrás (jump list de Vim)
```

### Escenario 2: Encontrar implementación de interfaz

```
1. Posiciona cursor en la interfaz/tipo abstracto
2. gi         → Ir a implementación concreta
3. gt         → Ver definición del tipo
4. Ctrl+o     → Volver atrás
```

### Escenario 3: Refactorizar código

```
1. Posiciona cursor sobre variable/función
2. <leader>cr → Renombrar en todo el proyecto
3. <leader>ca → Ver code actions disponibles
4. <leader>f  → Formatear después de cambios
```

### Escenario 4: Debuggear errores

```
1. ]d         → Ir al siguiente problema
2. <leader>d  → Ver detalles del error
3. <leader>ca → Ver fixes automáticos disponibles
4. <leader>xd → Ver todos los errores del archivo
```

## 🔄 Navegación de Vim Nativa (útil con LSP)

| Comando | Acción | Descripción |
|---------|--------|-------------|
| `Ctrl+o` | **Jump back** | Vuelve a posición anterior (jump list) |
| `Ctrl+i` | **Jump forward** | Avanza en jump list |
| `Ctrl+]` | **Jump to tag** | Alternativa a `gd` (requiere tags) |
| `gf` | **Go to file** | Abre archivo bajo el cursor (imports) |

## 💡 Tips y Trucos

### 1. Jump List es tu amigo
Cada vez que usas `gd`, `gi`, `gt`, etc., Vim guarda tu posición anterior:
- `Ctrl+o` → Volver atrás
- `Ctrl+i` → Ir adelante

### 2. Telescope para búsqueda global
- `<leader>ff` → Buscar archivos por nombre
- `<leader>fg` → Buscar texto en todo el proyecto
- `<leader>fs` → Buscar símbolos LSP (funciones, clases)

### 3. Trouble para mejor visualización
- `gR` mejor que `gr` → UI más clara para referencias
- `<leader>xw` → Ver todos los errores del workspace

### 4. Previews sin saltar
- `K` → Ver documentación sin mover cursor
- `gK` → Ver firma sin ir a definición

### 5. Combinaciones poderosas
```vim
" Ver referencias de función + ir a primera
gr → j → Enter

" Ver todas las implementaciones de interfaz
gi → gR (ver todas las referencias de esa implementación)

" Renombrar con preview
<leader>cr → escribe nuevo nombre → Enter
```

## 🚀 Atajos Rápidos por Categoría

### Solo quiero...

**"Ver dónde se define algo"** → `gd`
**"Ver dónde se usa algo"** → `gr` o `gR`
**"Saber qué hace esto"** → `K`
**"Encontrar la implementación"** → `gi`
**"Renombrar esto en todo el proyecto"** → `<leader>cr`
**"Arreglar este error"** → `<leader>ca`
**"Ir al siguiente error"** → `]d` o `]e`
**"Volver de donde salté"** → `Ctrl+o`

## 📚 Referencias Adicionales

- `:h lsp` → Ayuda de LSP en Neovim
- `:h jumplist` → Documentación de jump list
- `:h diagnostic` → Sistema de diagnósticos

---

**Nota**: Todos estos comandos solo funcionan en archivos donde el LSP esté activo (archivos de código con servidor LSP configurado: TypeScript, Python, Go, Rust, etc.)

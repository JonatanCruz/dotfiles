# Guía Completa de Manejo de Buffers en Neovim

Sistema intuitivo y completo para gestionar buffers (archivos abiertos) en Neovim.

## 🎯 Conceptos Básicos

**Buffer**: Archivo cargado en memoria. Puedes tener múltiples buffers abiertos.
**Window**: Vista de un buffer. Puedes ver el mismo buffer en múltiples ventanas.
**Tab**: Contenedor de layouts de ventanas (menos usado en flujo moderno).

## 🚀 Navegación Rápida

### Tab y Shift+Tab (Recomendado ⭐)

| Comando | Acción |
|---------|--------|
| `Tab` | Siguiente buffer (visual con BufferLine) |
| `Shift+Tab` | Buffer anterior (visual con BufferLine) |

### Shift+H y Shift+L (Alternativa nativa)

| Comando | Acción |
|---------|--------|
| `Shift+L` | Siguiente buffer (comando nativo) |
| `Shift+H` | Buffer anterior (comando nativo) |

## 🎮 Gestión con `<leader>b` (Space + b)

Todos los comandos de buffer empiezan con `<leader>b` para fácil memorización.

### Cerrar Buffers

| Comando | Acción | Mnemónico |
|---------|--------|-----------|
| `<leader>bc` | **Cerrar buffer actual ⭐** | **c** = **c**lose |
| `<leader>bC` | Forzar cierre (sin guardar) | **C** = force **C**lose |
| `<leader>bw` | Eliminar completamente (wipeout) | **w** = **w**ipeout |
| `<leader>bo` | Cerrar todos excepto actual | **o** = **o**nly |
| `<leader>bl` | Cerrar buffers a la izquierda | **l** = **l**eft |
| `<leader>br` | Cerrar buffers a la derecha | **r** = **r**ight |
| `<leader>bx` | Elegir buffer para cerrar | **x** = close with pi**x** |

### Navegar entre Buffers

| Comando | Acción | Mnemónico |
|---------|--------|-----------|
| `Tab` / `Shift+Tab` | **Siguiente/Anterior ⭐** | Visual (recomendado) |
| `Shift+L` / `Shift+H` | Siguiente/Anterior | Nativo (alternativa) |
| `<leader>bf` | Primer buffer | **f** = **f**irst |
| `<leader>bl` | Último buffer | **l** = **l**ast |
| `<leader>b$` | Último buffer (alias) | **$** = fin (Vim) |

### Seleccionar Buffer

| Comando | Acción | Mnemónico |
|---------|--------|-----------|
| `<leader>bp` | Elegir buffer interactivo | **p** = **p**ick |
| `<leader>ba` | Listar todos los buffers | **a** = **a**ll |
| `<leader>b1` a `<leader>b9` | Ir al buffer 1-9 | Número directo |

### Reordenar Buffers

| Comando | Acción |
|---------|--------|
| `<leader>b>` | Mover buffer a la derecha |
| `<leader>b<` | Mover buffer a la izquierda |

## 🎨 Visualización con Bufferline

Los buffers se muestran en la parte superior como pestañas:

```
┌─ archivo1.ts ─┬─ archivo2.js ─┬─ archivo3.py* ─┐
│                │                │                 │
```

- `*` = Buffer actual
- `` = Botón de cerrar (clic)
- **Números**: Posición del buffer (1-9)
- **Íconos**: Tipo de archivo

## 📋 Flujos de Trabajo

### Escenario 1: Navegación Básica

```
Trabajando en varios archivos:
1. Tab / Shift+Tab    → Navegar entre buffers
2. <leader>bc         → Cerrar cuando termines
3. <leader>bo         → Cerrar todos menos el actual
```

### Escenario 2: Selección Rápida

```
Tienes 5 archivos abiertos:
1. <leader>b3         → Ir directamente al archivo 3
2. <leader>bp         → O elegir interactivamente con letras
3. Presiona letra mostrada → Saltar al buffer
```

### Escenario 3: Limpieza de Buffers

```
Muchos buffers abiertos y necesitas limpiar:
1. <leader>bo         → Mantener solo el actual
O filtrado:
1. <leader>bl         → Cerrar todos a la izquierda
2. <leader>br         → Cerrar todos a la derecha
```

### Escenario 4: Organización

```
Reordenar archivos en la línea de buffers:
1. <leader>b>         → Mover actual a la derecha
2. <leader>b<         → Mover actual a la izquierda
```

### Escenario 5: Cierre Inteligente

```
Buffer con cambios sin guardar:
1. <leader>bc         → Vim pregunta si guardar
2. :w                 → Guardar y cerrar
O forzar:
1. <leader>bC         → Cerrar sin guardar (cuidado!)
```

## 💡 Tips y Trucos

### 1. Buffer Picking (Más Rápido)

```vim
<leader>bp
" Aparecen letras sobre cada buffer
" Presiona la letra → saltas al buffer
```

**Ideal para**: 3-10 buffers abiertos

### 2. Navegación Numérica

```vim
<leader>b1   → Primer buffer
<leader>b2   → Segundo buffer
<leader>b$   → Último buffer
```

**Ideal para**: Conoces la posición del buffer

### 3. Tab para Edición Activa

```vim
Tab          → Siguiente archivo
<leader>bc   → Terminar con este archivo
Tab          → Continuar con el siguiente
```

**Ideal para**: Edición secuencial de múltiples archivos

### 4. Combinar con Telescope

```vim
<leader>ff   → Buscar archivos
Enter        → Abrir en nuevo buffer
Tab/Shift+Tab → Navegar entre buffers
<leader>bc   → Cerrar cuando termines
```

### 5. Buffer vs Window vs Tab

```vim
" Mismo buffer, múltiples ventanas (splits)
:vsplit      → Ver mismo archivo en 2 ventanas

" Múltiples buffers, una ventana
Tab          → Cambiar archivo sin split

" Tabs (menos común)
:tabnew      → Nueva tab con layout independiente
```

## 🎯 Atajos Rápidos por Tarea

### "Solo quiero..."

**"Cerrar este archivo"**
→ `<leader>bc`

**"Cerrar sin guardar"**
→ `<leader>bC`

**"Siguiente archivo"**
→ `Tab` o `Shift+L`

**"Ir al archivo 3"**
→ `<leader>b3`

**"Elegir archivo rápido"**
→ `<leader>bp` → letra

**"Cerrar todos menos este"**
→ `<leader>bo`

**"Listar todos los archivos abiertos"**
→ `<leader>ba`

**"Organizar buffers"**
→ `<leader>b>` o `<leader>b<`

## 🔥 Workflows Avanzados

### Code Review Workflow

```vim
1. <leader>ff          → Buscar archivo para revisar
2. gd                  → Ir a definiciones
3. gr                  → Ver referencias
4. <leader>bc          → Cerrar cuando termines review
5. Tab                 → Siguiente archivo para revisar
```

### Refactoring Workflow

```vim
1. <leader>fp          → Buscar patrón en proyecto
2. Enter en resultado  → Abrir archivo (nuevo buffer)
3. <leader>rn          → Renombrar símbolo
4. :w                  → Guardar cambios
5. <leader>bc          → Cerrar buffer
6. Repetir para otros resultados
```

### Multi-file Editing

```vim
1. <leader>ff          → Buscar archivos relacionados
2. Abrir múltiples con Enter
3. <leader>b1 a b9     → Saltar entre ellos
4. Editar cada uno
5. <leader>bo          → Cerrar todos excepto principal
```

## 📊 Comparación de Métodos

| Método | Velocidad | Caso de Uso |
|--------|-----------|-------------|
| `Tab/Shift+Tab` | ⚡⚡⚡ | Navegación secuencial rápida |
| `<leader>bp` | ⚡⚡ | 3-10 buffers, selección visual |
| `<leader>b[1-9]` | ⚡⚡⚡ | Conoces posición exacta |
| `<leader>ba` | ⚡ | Ver lista completa, muchos buffers |
| `Shift+H/L` | ⚡⚡⚡ | Alternativa a Tab (preferencia) |

## 🛠️ Comandos de Vim Nativos (Referencia)

| Comando | Acción |
|---------|--------|
| `:ls` o `:buffers` | Listar buffers |
| `:b [nombre]` | Ir a buffer por nombre |
| `:b [número]` | Ir a buffer por número |
| `:bd` | Borrar buffer actual |
| `:bd!` | Forzar borrado |
| `:bn` | Next buffer |
| `:bp` | Previous buffer |
| `:%bd` | Cerrar todos los buffers |

## 🎨 Personalización Visual

### Estados del Buffer

- **Normal**: Texto gris - Buffer en background
- **Activo**: Texto azul + fondo - Buffer actual
- **Modificado**: Punto o indicador - Cambios sin guardar
- **Diagnóstico**: Íconos de error/warning - Problemas en código

### Interacción con Mouse

- **Click**: Cambiar a buffer
- **Middle Click**: Cerrar buffer
- **Scroll**: Navegar entre buffers (si hay muchos)

## 🚨 Situaciones Especiales

### Buffer con Cambios No Guardados

```vim
<leader>bc
→ E89: No write since last change

Opciones:
:w                  → Guardar y cerrar
<leader>bC          → Forzar cierre (perder cambios)
:wq                 → Guardar y cerrar ventana
```

### Demasiados Buffers Abiertos

```vim
<leader>ba          → Ver lista completa
<leader>bo          → Mantener solo actual
<leader>bl/br       → Cerrar por zonas
:%bd|e#|bd#         → Cerrar todos excepto actual (manual)
```

### Buffer No Se Cierra

```vim
" Si el buffer está en múltiples ventanas:
<C-w>o              → Cerrar todas las ventanas excepto actual
<leader>bc          → Cerrar buffer

" Si es terminal o especial:
<leader>bw          → Wipeout (eliminación forzada)
```

## 📚 Referencias

- `:h buffers` - Ayuda de buffers en Vim
- `:h windows` - Diferencia entre buffers y windows
- `:h bufferline` - Plugin bufferline.nvim
- `:h buffer-list` - Lista de buffers

---

## ✨ Cambios de Simplificación UX

**Eliminaciones para reducir redundancia:**

- `<leader>bd` → ELIMINADO (duplicaba `<leader>bc`)
- `<leader>bn` → ELIMINADO (usar `Tab` o `Shift+L`)
- `<leader>bp` (previous) → ELIMINADO (usar `Shift+Tab` o `Shift+H`)

**Keybindings finales recomendados:**

- **Navegación**: `Tab` / `Shift+Tab` (visual) o `Shift+L` / `Shift+H` (nativo)
- **Cerrar**: `<leader>bc` (única forma intuitiva)
- **Selección directa**: `<leader>b1` a `<leader>b9` (posición) o `<leader>bp` (pick interactivo)

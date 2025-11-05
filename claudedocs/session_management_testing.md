# Session Management Testing Guide

## Implementación Completada

### Archivos creados/modificados
1. **Nueva implementación:**
   - `/nvim/.config/nvim/lua/plugins/tools/session.lua`

2. **Modificaciones:**
   - `/nvim/.config/nvim/lua/plugins/ui/whichkey.lua` (agregado grupo `<leader>q`)

### Características implementadas

#### Plugin: folke/persistence.nvim
- **Event**: `BufReadPre` (carga antes de leer buffers)
- **Directorio de sesiones**: `~/.local/state/nvim/sessions/`
- **Opciones guardadas**: buffers, curdir, tabpages, winsize
- **No guarda sesiones vacías**

#### Keybindings bajo `<leader>q`
```
<leader>qs → Restore session (current dir)
<leader>ql → Restore last session
<leader>qd → Don't save session (stop auto-save)
<leader>qq → Quit without saving session
<leader>qQ → Quit and save session
```

#### Integración WhichKey
- Grupo registrado: `<leader>q` → "Quit/Session" con ícono `󰗼`

---

## Plan de Testing

### Test 1: Instalación del plugin
```bash
# 1. Aplicar configuración con Stow (si no está aplicada)
cd ~/dotfiles
stow -R nvim

# 2. Abrir Neovim y verificar instalación
nvim
:Lazy sync

# 3. Verificar que persistence.nvim está instalado
:Lazy
# Buscar "persistence.nvim" en la lista
```

**Resultado esperado:** Plugin instalado sin errores.

---

### Test 2: Crear y guardar sesión
```bash
# 1. Crear directorio de prueba
mkdir -p ~/test-session-nvim
cd ~/test-session-nvim

# 2. Crear archivos de prueba
echo "console.log('test1');" > test1.js
echo "console.log('test2');" > test2.js
echo "console.log('test3');" > test3.js

# 3. Abrir Neovim y crear sesión
nvim test1.js

# 4. Dentro de Neovim:
#    - Abrir más buffers: :e test2.js  y  :e test3.js
#    - Dividir ventana: <C-w>v  o  <C-w>s
#    - Crear tabs: :tabnew test2.js

# 5. Salir guardando sesión: <leader>qQ
#    (o simplemente :qa, persistence auto-guarda en VimLeavePre)
```

**Resultado esperado:**
- Sesión guardada en `~/.local/state/nvim/sessions/`
- Archivo de sesión con hash del directorio `~/test-session-nvim`

---

### Test 3: Restaurar sesión (mismo directorio)
```bash
# 1. Desde el mismo directorio de prueba
cd ~/test-session-nvim

# 2. Abrir Neovim (sin argumentos)
nvim

# 3. Dentro de Neovim, restaurar sesión: <leader>qs
```

**Resultado esperado:**
- Todos los buffers restaurados (test1.js, test2.js, test3.js)
- Ventanas y tabs en la misma configuración
- Directorio actual restaurado

---

### Test 4: Restaurar última sesión (desde otro directorio)
```bash
# 1. Ir a otro directorio
cd ~

# 2. Abrir Neovim
nvim

# 3. Restaurar última sesión: <leader>ql
```

**Resultado esperado:**
- Última sesión restaurada (la de ~/test-session-nvim)
- Directorio cambiado automáticamente a ~/test-session-nvim

---

### Test 5: No guardar sesión
```bash
# 1. Abrir Neovim en el directorio de prueba
cd ~/test-session-nvim
nvim

# 2. Hacer cambios (abrir/cerrar buffers, modificar layout)

# 3. Decidir NO guardar: <leader>qd
#    Esto detiene el auto-save

# 4. Salir sin guardar sesión: <leader>qq
```

**Resultado esperado:**
- Sesión anterior NO modificada
- Cambios de layout NO guardados

---

### Test 6: Verificar que NO interfiere con plugins UI
```bash
# 1. Abrir Neovim y crear sesión con UI plugins
nvim

# 2. Abrir nvim-tree: <leader>e
# 3. Abrir Telescope: <leader>ff
# 4. Abrir Lazy: <leader>pL

# 5. Salir y restaurar: :qa  →  nvim  →  <leader>qs
```

**Resultado esperado:**
- nvim-tree NO restaurado (es un buffer especial)
- Telescope NO restaurado (es flotante)
- Solo buffers de archivos restaurados

---

### Test 7: Sesiones vacías (edge case)
```bash
# 1. Crear directorio vacío
mkdir -p ~/empty-session-test
cd ~/empty-session-test

# 2. Abrir Neovim sin archivos
nvim

# 3. Salir inmediatamente: :qa
```

**Resultado esperado:**
- NO se guarda sesión (porque `save_empty = false`)
- Directorio `~/.local/state/nvim/sessions/` no contiene sesión para este directorio

---

### Test 8: WhichKey integration
```bash
# 1. Abrir Neovim
nvim

# 2. Presionar <leader>q y esperar (timeout 300ms)
```

**Resultado esperado:**
- WhichKey muestra grupo "Quit/Session" con ícono `󰗼`
- Muestra todas las opciones: qs, ql, qd, qq, qQ

---

## Verificación de archivos de sesión

### Ubicación de sesiones
```bash
ls -la ~/.local/state/nvim/sessions/
```

**Contenido esperado:**
- Archivos con nombres hash (por ejemplo: `%Users%jonatan%test-session-nvim`)
- Cada archivo contiene comandos Vim de restauración

### Inspeccionar sesión guardada
```bash
cat ~/.local/state/nvim/sessions/%Users%jonatan%test-session-nvim
```

**Debe contener:**
- Comandos `edit`, `badd`, `buffer`
- Configuración de ventanas y tabs
- Directorio `cd ~/test-session-nvim`

---

## Troubleshooting

### Problema: Plugin no instala
**Solución:**
```bash
rm -rf ~/.local/share/nvim
nvim
:Lazy sync
```

### Problema: Sesión no se guarda
**Diagnóstico:**
1. Verificar directorio existe: `ls -la ~/.local/state/nvim/sessions/`
2. Verificar que hay buffers abiertos (no sesión vacía)
3. Verificar que no se ejecutó `<leader>qd` (stop auto-save)

### Problema: Sesión restaura buffers de plugins
**Causa:** persistence.nvim por defecto filtra buffers especiales
**Verificación:** Los buffers de nvim-tree, Telescope, etc., tienen `buftype` especial y no deberían guardarse

---

## Limpieza después de testing
```bash
# Eliminar directorio de prueba
rm -rf ~/test-session-nvim
rm -rf ~/empty-session-test

# Limpiar sesiones de prueba (opcional)
rm -rf ~/.local/state/nvim/sessions/*
```

---

## Checklist de verificación

- [ ] Plugin instalado correctamente
- [ ] Keybindings `<leader>q*` funcionan
- [ ] WhichKey muestra grupo correctamente
- [ ] Sesión se guarda al salir (auto-save)
- [ ] `<leader>qs` restaura sesión del directorio actual
- [ ] `<leader>ql` restaura última sesión
- [ ] `<leader>qd` detiene auto-save
- [ ] `<leader>qq` sale sin guardar
- [ ] `<leader>qQ` sale guardando
- [ ] No guarda sesiones vacías
- [ ] No restaura buffers de plugins UI (nvim-tree, telescope)
- [ ] Sesiones en `~/.local/state/nvim/sessions/`

---

## Mejores prácticas de uso

1. **Workflow normal:**
   - Trabajar en proyecto → Salir con `:qa` (auto-guarda)
   - Reabrir proyecto → `<leader>qs` para restaurar

2. **Sesión experimental:**
   - Si estás probando cosas → `<leader>qd` (detener auto-save)
   - Salir → `<leader>qq` (sin guardar cambios)

3. **Cambiar de proyecto:**
   - `cd ~/otro-proyecto`
   - `nvim` → `<leader>qs` (carga sesión de ~/otro-proyecto)

4. **Recuperar última sesión desde cualquier lugar:**
   - `nvim` → `<leader>ql`

---

## Integración con workflow existente

Esta implementación NO interfiere con:
- nvim-tree (archivo explorer)
- Telescope (fuzzy finder)
- Lazy (plugin manager)
- Mason (LSP installer)
- Otros buffers especiales

Solo restaura:
- Buffers de archivos normales
- Layout de ventanas y tabs
- Directorio de trabajo

---

## Documentación adicional

- **Repo oficial:** https://github.com/folke/persistence.nvim
- **Archivo de configuración:** `/nvim/.config/nvim/lua/plugins/tools/session.lua`
- **Directorio de sesiones:** `~/.local/state/nvim/sessions/`

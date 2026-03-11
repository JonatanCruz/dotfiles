# nvim-dap - Debug Adapter Protocol para Neovim

Configuración completa de debugging interactivo para Neovim con soporte para Node.js, TypeScript, React y Next.js.

## Instalación

1. **Aplicar configuración con Stow:**
   ```bash
   cd ~/dotfiles
   stow -R nvim
   ```

2. **Instalar plugins en Neovim:**
   ```
   :Lazy sync
   ```

3. **Instalar debug adapter con Mason:**
   ```
   :Mason
   # Buscar: js-debug-adapter
   # Presionar 'i' para instalar
   ```

## Keybindings

Todos los comandos de debugging comienzan con `<leader>d` (Space + d):

### Control de Ejecución
- `<leader>dc` → ▶️  Continue/Start debugging
- `<leader>dt` → ⏹️  Terminate debugging session
- `<leader>di` → ⬇️  Step Into (entrar en función)
- `<leader>do` → ➡️  Step Over (saltar función)
- `<leader>dO` → ⬆️  Step Out (salir de función)

### Breakpoints
- `<leader>db` → 🔴 Toggle breakpoint en línea actual
- `<leader>dB` → 🟡 Conditional breakpoint (con condición)

### Interfaz
- `<leader>du` → 🎨 Toggle DAP UI (mostrar/ocultar interfaz)
- `<leader>dr` → 💬 Toggle REPL (consola interactiva)
- `<leader>de` → 🔍 Eval expression (evaluar bajo cursor)
- `<leader>df` → 📦 Float element (ventana flotante)

### Dentro de DAP UI
- `q` → Cerrar DAP UI
- `r` → Refresh DAP UI
- `e` → Edit valor
- `<CR>` → Expandir/colapsar

## Flujo de Trabajo Típico

### Debugging de Node.js/TypeScript

1. **Abrir archivo a debuggear:**
   ```
   nvim app.js
   ```

2. **Colocar breakpoint:**
   ```
   <leader>db  # en la línea deseada
   ```

3. **Iniciar debugging:**
   ```
   <leader>dc  # Continue/Start
   ```

4. **DAP UI se abrirá automáticamente** mostrando:
   - **Panel izquierdo:**
     - Variables locales (scopes)
     - Breakpoints activos
     - Call stack
     - Watches (expresiones observadas)
   - **Panel inferior:**
     - REPL (consola interactiva)
     - Console (logs de aplicación)

5. **Navegar por el código:**
   ```
   <leader>di  # Step Into (entrar en función)
   <leader>do  # Step Over (pasar función)
   <leader>dO  # Step Out (salir de función)
   <leader>dc  # Continue (hasta próximo breakpoint)
   ```

6. **Inspeccionar variables:**
   - Hover sobre variable con `K`
   - Usar `<leader>de` para evaluar expresión
   - Ver panel de Scopes en DAP UI

7. **Usar REPL:**
   ```
   <leader>dr  # Abrir REPL
   # Escribir comandos JavaScript/TypeScript
   ```

8. **Terminar debugging:**
   ```
   <leader>dt  # DAP UI se cerrará automáticamente
   ```

### Debugging de React/Next.js

1. **Configuración automática detectada** para:
   - `*.jsx` → JavaScript React
   - `*.tsx` → TypeScript React

2. **Iniciar server de desarrollo:**
   ```
   <leader>dc  # Ejecutará 'npm run dev'
   ```

3. **Colocar breakpoints** en componentes React

4. **Navegar en el navegador** para activar breakpoints

## Configuraciones Disponibles

### Node.js
- **Launch Node.js**: Ejecuta archivo actual
- **Attach to Node.js**: Se conecta a proceso en ejecución

### TypeScript/JavaScript React
- **Launch Next.js/React**: Ejecuta `npm run dev`

## Características Visuales

### Icons (Catppuccin Mocha Theme)
- 🔴 Breakpoint normal
- 🟡 Breakpoint condicional
- ❌ Breakpoint rechazado
- ▶️ Línea actual de ejecución
- 📝 Log point

### Colors
- **Purple** → Variables y tipos
- **Cyan** → Líneas y decoraciones
- **Green** → Valores y threads activos
- **Red** → Errores y stop
- **Orange** → Valores modificados

### Virtual Text
- Durante debugging, los valores de variables se muestran inline
- Solo visible en modo debug activo
- Resalta variables modificadas

## Troubleshooting

### Plugin no carga
```
:Lazy sync
:checkhealth dap
```

### Debug adapter no encontrado
```
:Mason
# Instalar: js-debug-adapter
```

### DAP UI no se abre
```
<leader>du  # Toggle manual
```

### Breakpoints no funcionan
- Verificar que el adapter esté instalado
- Verificar que el archivo esté guardado
- Revisar console en DAP UI para errores

### Performance
Si la UI es lenta:
- Reducir `max_value_lines` en `dap-ui.lua`
- Cerrar paneles no usados
- Deshabilitar virtual text temporalmente

## Extensiones Futuras

Para agregar más debuggers:

1. **Instalar adapter con Mason:**
   ```
   :Mason
   ```

2. **Configurar en `dap.lua`:**
   ```lua
   dap.adapters.python = { ... }
   dap.configurations.python = { ... }
   ```

3. **Reiniciar Neovim**

## Referencias

- [nvim-dap](https://github.com/mfussenegger/nvim-dap)
- [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)
- [Debug Adapter Protocol](https://microsoft.github.io/debug-adapter-protocol/)
- [Mason Registry](https://github.com/mason-org/mason-registry)

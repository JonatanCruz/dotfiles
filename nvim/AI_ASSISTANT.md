# Asistente de IA - Supermaven (Configuración Optimizada)

Autocompletado con IA en tiempo real para Neovim, optimizado para rendimiento y mejor UX.

## 🚀 Comandos Vim

| Comando | Descripción |
|---------|-------------|
| `:SupermavenStart` | Iniciar Supermaven |
| `:SupermavenStop` | Detener Supermaven |
| `:SupermavenToggle` | Activar/Desactivar |
| `:SupermavenStatus` | Ver estado actual |
| `:SupermavenUseFree` | Usar tier gratuito (primera vez) |
| `:SupermavenShowLog` | Ver logs de debug |

## 🎮 Keybindings Leader

| Comando | Acción | Descripción |
|---------|--------|-------------|
| `<leader>ai` | Toggle AI | Activar/Desactivar Supermaven |
| `<leader>as` | AI Status | Ver estado y estadísticas |
| `<leader>al` | AI Logs | Ver logs de actividad |

## ⌨️ Keybindings de Sugerencias

| Comando | Acción | Uso |
|---------|--------|-----|
| `Ctrl+l` | **Aceptar sugerencia completa** ⭐ | Acepta toda la sugerencia |
| `Ctrl+j` | Aceptar palabra | Acepta solo próxima palabra |
| `Ctrl+h` | Limpiar sugerencia | Cancela y limpia sugerencia actual |

## 💡 Cómo Usar

1. **Activación automática**: Supermaven se activa al entrar en modo INSERT
2. **Ver estado**: `<leader>as` para verificar que está activo
3. **Escribir código**: Las sugerencias aparecen automáticamente en gris
4. **Aceptar**: Presiona `Ctrl+l` para aceptar toda la sugerencia
5. **Parcial**: Presiona `Ctrl+j` para solo la próxima palabra
6. **Cancelar**: Presiona `Ctrl+h` o sigue escribiendo
7. **Toggle**: `<leader>ai` para activar/desactivar cuando quieras

## 🎨 Visualización

- **Sugerencias**: Texto gris tenue que aparece adelante del cursor
- **No intrusivo**: Solo muestra cuando hay sugerencias relevantes
- **Contexto**: Usa 1M tokens de contexto para entender tu proyecto completo
- **Notificaciones**: Recibe alertas cuando Supermaven se activa/desactiva

## 📝 Ejemplo

```python
def calculate_total(
# Aparece sugerencia gris: items: list, tax_rate: float) -> float:
#     return sum(item.price * (1 + tax_rate) for item in items)

# Presiona Ctrl+l para aceptar toda la sugerencia
# O Ctrl+j para aceptar solo "items: list"
```

## 🚫 Archivos Ignorados (Optimizado)

El asistente NO funciona en:

**UI y Plugins**:
- Telescope, NvimTree, Lazy, Mason, Trouble, Alpha

**Archivos Especiales**:
- Git commits/rebase, Help, Man pages

**Buffers Especiales**:
- Terminal, Quickfix, Prompt

**Archivos Grandes**:
- Archivos >1MB (desactivado automáticamente para rendimiento)

## ⚡ Optimizaciones de Rendimiento

1. **Carga Lazy**: Se carga solo al entrar en INSERT (no al inicio)
2. **Archivos Grandes**: Desactivado automáticamente en archivos >1MB
3. **Logs Reducidos**: Solo warnings y errores (menos verboso)
4. **Más Filetypes Ignorados**: 15+ tipos de archivo excluidos
5. **Keybindings Ergonómicos**: `Ctrl+h` más fácil que `Ctrl+]`

## 💪 Tips Pro

1. **Deja que piense**: Pausa 1-2 segundos después de escribir
2. **Contexto importa**: Más archivos abiertos = mejor contexto (usa buffers)
3. **Funciona mejor en**: Funciones, clases, imports, patterns comunes
4. **Toggle rápido**: `<leader>ai` para desactivar en archivos simples
5. **Verifica estado**: `<leader>as` si dudas si está activo
6. **Logs**: `<leader>al` para debug si hay problemas

## 🆚 Comparación con Configuración Anterior

| Aspecto | Antes | Ahora | Mejora |
|---------|-------|-------|--------|
| **Carga** | VeryLazy | InsertEnter | Más eficiente ⚡ |
| **Cancel** | Ctrl+] | Ctrl+h | Más ergonómico 👍 |
| **Toggle** | Ninguno | `<leader>ai` | Acceso rápido 🎯 |
| **Status** | Ninguno | `<leader>as` | Visibilidad 📊 |
| **Logs** | Ninguno | `<leader>al` | Debug fácil 🔍 |
| **Filetypes ignorados** | 3 | 15+ | Menos interferencia 🚫 |
| **Archivos grandes** | No check | Auto-disable >1MB | Mejor rendimiento 🚀 |
| **Log level** | Info | Warn | Menos ruido 🔇 |
| **Notificaciones** | No | Sí | Mejor feedback 📢 |

## 🚨 Troubleshooting

**No aparecen sugerencias**:
```vim
<leader>as          # Ver estado
:SupermavenStart    # Reiniciar si está apagado
<leader>al          # Ver logs para errores
```

**Sugerencias incorrectas**:
```vim
Ctrl+h              # Cancelar y seguir escribiendo
<leader>ai          # Desactivar temporalmente
```

**Archivo muy lento**:
```vim
# Archivo >1MB se desactiva automáticamente
# Si manual: <leader>ai para desactivar
```

**Ver si está funcionando**:
```vim
<leader>as          # Ver status completo
# Debe aparecer notificación al entrar en INSERT
```

## 🔄 Flujos de Trabajo

### Coding Session Normal
```vim
1. Abrir archivo
2. i (entrar INSERT) → Supermaven se activa automáticamente
3. Escribir código
4. Ctrl+l para aceptar sugerencias
5. <leader>ai si necesitas desactivarlo
```

### Archivo Simple (No necesitas IA)
```vim
1. Abrir archivo
2. <leader>ai → Desactivar Supermaven
3. Editar normalmente
4. <leader>ai → Reactivar cuando lo necesites
```

### Debug de Problemas
```vim
1. <leader>as → Ver estado actual
2. <leader>al → Ver logs
3. :SupermavenStop → Detener
4. :SupermavenStart → Reiniciar
5. <leader>al → Verificar logs nuevamente
```

## 📊 Estadísticas y Monitoreo

```vim
<leader>as          # Ver:
                    # - Estado (activo/inactivo)
                    # - Archivos abiertos
                    # - Contexto cargado
                    # - Últimas sugerencias
```

---

**Nota**: Supermaven funciona mejor cuando:
1. Has escrito suficiente contexto (10-20 líneas)
2. Tienes archivos relacionados abiertos en buffers
3. Esperas 1-2 segundos después de escribir
4. El archivo no es >1MB (límite de rendimiento)

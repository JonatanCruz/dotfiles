# Asistente de IA - Supermaven

Autocompletado con IA en tiempo real para Neovim.

## 🚀 Comandos

| Comando | Descripción |
|---------|-------------|
| `:SupermavenStart` | Iniciar Supermaven |
| `:SupermavenStop` | Detener Supermaven |
| `:SupermavenToggle` | Activar/Desactivar |
| `:SupermavenUseFree` | Usar tier gratuito (primera vez) |
| `:SupermavenShowLog` | Ver logs |

## ⌨️ Keybindings

| Comando | Acción |
|---------|--------|
| `Ctrl+l` | **Aceptar sugerencia completa** ⭐ |
| `Ctrl+j` | Aceptar solo próxima palabra |
| `Ctrl+]` | Limpiar/cancelar sugerencia |

## 💡 Cómo Usar

1. **Escribir código**: Las sugerencias aparecen automáticamente en gris
2. **Aceptar sugerencia**: Presiona `Ctrl+l`
3. **Aceptar palabra**: Presiona `Ctrl+j` para solo la próxima palabra
4. **Cancelar**: Presiona `Ctrl+]` o sigue escribiendo

## 🎨 Visualización

- **Sugerencias**: Texto gris tenue que aparece adelante del cursor
- **No intrusivo**: Solo muestra cuando hay sugerencias relevantes
- **Contexto**: Usa 1M tokens de contexto para entender tu proyecto

## 📝 Ejemplo

```python
def calculate_total(
# Aparece sugerencia gris: items: list, tax_rate: float) -> float:
# Presiona Ctrl+l para aceptar
```

## 🔧 Archivos Ignorados

El asistente NO funciona en:
- Telescope
- NvimTree
- Lazy (gestor de plugins)

## 💪 Tips

1. **Deja que piense**: Pausa 1-2 segundos después de escribir para mejores sugerencias
2. **Contexto importa**: Cuanto más código abierto en buffers, mejor contexto
3. **Funciona mejor en**: Funciones, clases, imports comunes
4. **Tier gratuito**: 1M tokens de contexto - muy generoso

## 🆚 Comparación con Tab

**Antes**: `Tab` aceptaba sugerencias de IA
**Ahora**: `Ctrl+l` acepta sugerencias de IA
**Beneficio**: `Tab` queda libre para completado normal y navegación

## 🚨 Troubleshooting

**No aparecen sugerencias**:
```vim
:SupermavenStart
:SupermavenShowLog  # Ver si hay errores
```

**Sugerencias incorrectas**:
```vim
Ctrl+]  # Cancelar y seguir escribiendo
```

**Desactivar temporalmente**:
```vim
:SupermavenToggle
```

---

**Nota**: Supermaven funciona mejor cuando has escrito suficiente contexto. Dale tiempo para "pensar" sobre tu código.

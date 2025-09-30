# Configuración de Tmux

Configuración minimalista de tmux con tema Dracula y fondo transparente.

## Características

- **Prefix key:** `Ctrl+s` (en lugar de `Ctrl+b`)
- **Tema:** Dracula con fondo transparente
- **Navegación:** Estilo Vim (hjkl)
- **Integración:** Navegación compartida con Neovim
- **Persistencia:** Sesiones guardadas con tmux-resurrect

## Estructura

```
tmux/
└── .tmux.conf    # Configuración principal
```

## Instalación

### 1. Aplicar con Stow

```bash
cd ~/dotfiles
stow tmux
```

### 2. Instalar TPM (Tmux Plugin Manager)

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### 3. Instalar Plugins

1. Inicia tmux: `tmux`
2. Presiona `Ctrl+s` + `I` (mayúscula i) para instalar plugins

## Atajos de Teclado

### General

- `Ctrl+s` - Prefix key
- `Prefix + r` - Recargar configuración

### Gestión de Paneles

**Crear splits:**
- `Prefix + |` - Split vertical
- `Prefix + -` - Split horizontal

**Navegar entre paneles:**
- `Prefix + h/j/k/l` - Mover izquierda/abajo/arriba/derecha
- O usa `Ctrl+h/j/k/l` directamente (integración con Neovim)

**Redimensionar paneles:**
- `Prefix + H` - Reducir ancho
- `Prefix + L` - Aumentar ancho
- `Prefix + J` - Reducir altura
- `Prefix + K` - Aumentar altura

### Gestión de Ventanas

- `Prefix + c` - Crear nueva ventana
- `Prefix + n` - Siguiente ventana
- `Prefix + p` - Ventana anterior
- `Prefix + 0-9` - Ir a ventana específica
- `Prefix + ,` - Renombrar ventana

### Sesiones (tmux-resurrect)

- `Prefix + Ctrl+s` - Guardar sesión
- `Prefix + Ctrl+r` - Restaurar sesión

## Plugins

### vim-tmux-navigator
Navegación fluida entre paneles de tmux y splits de Neovim usando `Ctrl+h/j/k/l`.

### tmux-resurrect
Guarda y restaura sesiones de tmux, incluyendo:
- Layout de paneles
- Programas en ejecución
- Directorios de trabajo

## Personalización

### Cambiar Prefix Key

Edita `.tmux.conf`:
```bash
unbind C-b
set-option -g prefix C-a  # Cambia 's' por 'a' u otra tecla
bind-key C-a send-prefix
```

### Modificar Colores

Los colores Dracula están definidos en la sección 3 del archivo:
- `#bd93f9` - Púrpura
- `#8be9fd` - Cian
- `#f8f8f2` - Blanco
- `#6272a4` - Gris

### Añadir Plugins

1. Agrega la línea en `.tmux.conf`:
   ```bash
   set -g @plugin 'usuario/nombre-plugin'
   ```
2. Recarga: `Prefix + r`
3. Instala: `Prefix + I`

## Configuraciones Importantes

### Mouse
```bash
set -g mouse on
```
Habilita soporte de mouse para redimensionar paneles y cambiar de ventana.

### History
```bash
set -g history-limit 10000
```
Mantiene las últimas 10,000 líneas en el historial del panel.

### True Color
```bash
set-option -g default-terminal "tmux-256color"
set-option -sa terminal-overrides ",xterm*:Tc"
```
Habilita colores de 24 bits para el tema Dracula.

## Solución de Problemas

### Los colores no se ven bien
Verifica que tu terminal soporte true color:
```bash
echo $TERM
# Debería mostrar: tmux-256color o xterm-256color
```

### Los plugins no se cargan
1. Verifica que TPM esté instalado: `ls ~/.tmux/plugins/tpm`
2. Reinstala plugins: `Prefix + I`
3. Recarga tmux: `tmux source ~/.tmux.conf`

### La navegación con Neovim no funciona
Asegúrate de tener configurado vim-tmux-navigator tanto en tmux como en Neovim.

### Prefix key no funciona
Verifica que no haya conflictos con otros programas. Prueba con:
```bash
tmux list-keys | grep C-s
```

## Comandos Útiles de Tmux

```bash
# Listar sesiones
tmux ls

# Crear sesión con nombre
tmux new -s nombre

# Adjuntar a sesión
tmux attach -t nombre

# Matar sesión
tmux kill-session -t nombre

# Matar todas las sesiones
tmux kill-server
```

## Referencias

- [Tmux Documentation](https://github.com/tmux/tmux/wiki)
- [TPM - Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
- [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)
- [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect)
- [Dracula Theme](https://draculatheme.com/)

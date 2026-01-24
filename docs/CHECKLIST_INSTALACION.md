# ✅ Checklist de Instalación Completa

Sigue esta lista paso a paso para configurar tu entorno completamente.

## 📋 Pre-Instalación

- [ ] Sistema operativo Ubuntu 24.04 LTS
- [ ] Conexión a Internet estable
- [ ] Usuario con permisos sudo
- [ ] Repositorio clonado en `~/dotfiles`

## 🚀 Instalación Automática

### Opción A: Script Quick Setup (Recomendado)

- [ ] **Ejecutar:** `cd ~/dotfiles && ./scripts/quick-setup-ubuntu.sh`
- [ ] **Confirmar** actualizaciones del sistema
- [ ] **Esperar** instalación de dependencias (5-10 minutos)
- [ ] **Anotar** mensajes importantes del script

### Opción B: Bootstrap Completo

- [ ] **Ejecutar:** `cd ~/dotfiles && ./scripts/bootstrap.sh`
- [ ] **Seguir** prompts interactivos

## 🔧 Post-Instalación

### 1. Terminal y Shell

- [ ] **Reiniciar shell:** `exec zsh`
- [ ] **Verificar prompt** Starship aparece correctamente
- [ ] **Verificar autosuggestions** funcionan (escribir comando y ver sugerencias)
- [ ] **Verificar syntax highlighting** (comandos válidos en verde, inválidos en rojo)

### 2. Configurar Fuente en Terminal

**GNOME Terminal:**
- [ ] Abrir terminal → clic derecho → Preferencias
- [ ] Ir a Perfiles → Editar perfil actual
- [ ] Tab "Texto" → desmarcar "Fuente del sistema"
- [ ] Seleccionar fuente: **JetBrainsMono Nerd Font Regular**
- [ ] Tamaño: **11** o **12**
- [ ] Cerrar y abrir nueva terminal
- [ ] **Verificar** símbolos se ven correctamente (ver prompt con íconos)

**Tilix:**
- [ ] Preferencias → Perfiles → Default → Apariencia
- [ ] Fuente personalizada: **JetBrainsMono Nerd Font 11**
- [ ] Guardar y reiniciar terminal

**Kitty / Alacritty:** (Si usas estos terminales)
- [ ] La fuente ya debería estar configurada en los dotfiles

### 3. Neovim

- [ ] **Abrir Neovim primera vez:** `nvim`
- [ ] **Esperar** instalación automática de lazy.nvim
- [ ] **Esperar** descarga e instalación de plugins (1-2 minutos)
- [ ] **Cerrar** Neovim cuando termine: `:q`
- [ ] **Volver a abrir** Neovim: `nvim`
- [ ] **Ejecutar** health check: `:checkhealth`
- [ ] **Revisar** errores críticos (warnings son normales)
- [ ] **Abrir Mason:** `:Mason`
- [ ] **Verificar** LSP servers instalados:
  - [ ] lua_ls (Lua)
  - [ ] pyright (Python)
  - [ ] ts_ls (TypeScript/JavaScript)
  - [ ] bashls (Bash)
  - [ ] Otros según tus necesidades

### 4. Tmux

- [ ] **Clonar TPM:** `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`
- [ ] **Iniciar tmux:** `tmux`
- [ ] **Instalar plugins:** Presionar `Ctrl+s` luego `Shift+I` (I mayúscula)
- [ ] **Esperar** descarga de plugins
- [ ] **Verificar tema** Catppuccin aplicado
- [ ] **Probar split horizontal:** `Ctrl+s` + `|`
- [ ] **Probar split vertical:** `Ctrl+s` + `-`
- [ ] **Probar navegación:** `Ctrl+s` + `h/j/k/l`
- [ ] **Salir de tmux:** `Ctrl+s` + `d` (detach)

### 5. Git Configuration

- [ ] **Abrir config:** `nvim ~/.config/git/config`
- [ ] **Añadir tu información:**
  ```ini
  [user]
      name = Tu Nombre Completo
      email = tu.email@example.com

  [github]
      user = tu-usuario-github
  ```
- [ ] **Guardar y cerrar:** `<Space>w` luego `<Space>q`
- [ ] **Verificar:** `git config --global user.name`
- [ ] **Verificar:** `git config --global user.email`

### 6. Verificación de Herramientas CLI

Ejecuta cada comando y verifica que funciona:

- [ ] `eza --version` → Listado de archivos moderno
- [ ] `ripgrep --version` → Búsqueda rápida
- [ ] `bat --version` → Cat con syntax highlighting
- [ ] `fd --version` → Find alternativo
- [ ] `fzf --version` → Fuzzy finder
- [ ] `zoxide --version` → Navegación inteligente
- [ ] `yazi --version` → File manager
- [ ] `lazygit --version` → Git UI
- [ ] `starship --version` → Prompt

### 7. Aliases y Comandos

Prueba estos aliases configurados en zsh:

- [ ] `ls` → Debe ejecutar `eza` (con colores e íconos)
- [ ] `ll` → Listado detallado con `eza -l`
- [ ] `la` → Listado con archivos ocultos
- [ ] `cat archivo.txt` → Debe usar `bat` (con colores)
- [ ] `z ruta_parcial` → Navegación con zoxide
- [ ] `lg` → Abrir LazyGit

### 8. Cambiar Shell por Defecto

- [ ] **Verificar shell actual:** `echo $SHELL`
- [ ] Si no es `/usr/bin/zsh` o `/bin/zsh`:
  - [ ] **Cambiar:** `chsh -s $(which zsh)`
  - [ ] **Cerrar sesión completamente**
  - [ ] **Volver a iniciar sesión**
  - [ ] **Verificar de nuevo:** `echo $SHELL`

### 9. Health Check Final

- [ ] **Ejecutar:** `cd ~/dotfiles && ./scripts/health-check.sh`
- [ ] **Revisar output:** Todo debe estar ✓ (verde)
- [ ] Si hay errores:
  - [ ] Anotar qué falló
  - [ ] Consultar [Troubleshooting](INSTALL.md#solución-de-problemas)

## 🎨 Verificación Visual

### Prompt de Starship

Tu prompt debe verse similar a esto:

```
~/dotfiles main ────────────────────────────────────── 10:30:45
❯
```

Con:
- Directorio actual en color
- Rama git si estás en un repo
- Íconos y símbolos correctos (no cuadrados �)
- Flecha de comando (❯)

### Neovim

Cuando abres un archivo `.js` o `.py`:
- [ ] **Colores** aplicados (tema Catppuccin Mocha)
- [ ] **Barra de estado** visible (lualine)
- [ ] **Explorador de archivos** funciona: `<Space>e`
- [ ] **Autocompletado** aparece al escribir
- [ ] **LSP funciona:** Pasar mouse sobre función muestra documentación
- [ ] **Telescope funciona:** `<Space>ff` abre buscador de archivos

### Tmux

- [ ] **Tema Catppuccin** aplicado en barra de estado
- [ ] **Splits** funcionan y se ven bien
- [ ] **Navegación** entre paneles fluida

## 🐛 Problemas Comunes

### ❌ Símbolos rotos (cuadrados � en vez de íconos)

**Causa:** Fuente no configurada correctamente

**Solución:**
1. Verificar fuente instalada: `fc-list | grep -i "JetBrains"`
2. Configurar en terminal (ver sección 2 arriba)
3. Reiniciar terminal completamente

### ❌ Neovim sin colores ni plugins

**Causa:** Primera instalación interrumpida

**Solución:**
```bash
rm -rf ~/.local/share/nvim ~/.cache/nvim
nvim  # Dejar que reinstale todo
```

### ❌ Zsh no es shell por defecto

**Causa:** Cambio requiere logout/login

**Solución:**
1. `chsh -s $(which zsh)`
2. Cerrar sesión completamente
3. Iniciar sesión nuevamente

### ❌ Comandos como `eza` no funcionan

**Causa:** No se actualizó PATH o no se reinició shell

**Solución:**
```bash
source ~/.zshrc
# O reiniciar shell:
exec zsh
```

### ❌ Plugins de Tmux no se instalaron

**Causa:** TPM no clonado o teclas incorrectas

**Solución:**
```bash
# Verificar TPM
ls ~/.tmux/plugins/tpm

# Si no existe, clonar
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Reiniciar tmux
tmux kill-server
tmux

# Instalar: Ctrl+s luego Shift+I (I MAYÚSCULA)
```

## ✨ Personalización Adicional

### Temas de Terminal (Opcional)

Si quieres aplicar el tema Catppuccin también a tu terminal:

**GNOME Terminal:**
```bash
curl -L https://raw.githubusercontent.com/catppuccin/gnome-terminal/main/install.py | python3 -
```

**Tilix:**
```bash
curl -L https://raw.githubusercontent.com/catppuccin/tilix/main/install.sh | bash
```

### Configurar direnv (Opcional)

Para entornos de desarrollo por proyecto:
```bash
sudo apt install -y direnv
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
exec zsh
```

### Instalar Docker (Opcional)

Si necesitas Docker:
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
# Logout y login para aplicar cambios
```

## 🎓 Próximos Pasos

Una vez todo instalado y verificado:

- [ ] **Leer:** [Guías de Usuario](guides/) → Workflows y mejores prácticas
- [ ] **Explorar:** [Keybindings](guides/keybindings.md) → Atajos útiles
- [ ] **Aprender:** [Arquitectura](ARCHITECTURE.md) → Cómo está organizado
- [ ] **Personalizar:** [Customization](guides/customization.md) → Ajustar a tu gusto

## 📚 Recursos

- [Guía Completa Ubuntu](QUICK_SETUP_UBUNTU.md)
- [Instalación General](INSTALL.md)
- [README Principal](../README.md)
- [Troubleshooting](reference/troubleshooting.md)

---

## ✅ Confirmación Final

Marca esto cuando todo esté listo:

- [ ] **Todas las herramientas instaladas y funcionando**
- [ ] **Neovim con plugins y LSP operativo**
- [ ] **Tmux con plugins y tema aplicado**
- [ ] **Shell Zsh por defecto con Starship**
- [ ] **Fuente Nerd Font configurada correctamente**
- [ ] **Git configurado con tu información**
- [ ] **Health check pasado sin errores críticos**
- [ ] **Símbolos e íconos se ven correctamente**

## 🎉 ¡Felicidades!

Tu entorno de desarrollo está completamente configurado.

**Disfruta programando con tu nuevo setup profesional!** 🚀

# Claude Code - Configuración Global

Configuración global de Claude Code que se aplica a todos los proyectos en tu sistema.

## 📦 Instalación con GNU Stow

Desde el directorio `dotfiles/`:

```bash
stow claude
```

Esto creará un symlink de `~/.claude/` apuntando a `dotfiles/claude/.claude/`, haciendo que la configuración esté disponible **en todos tus proyectos**.

## 🔍 Verificación

Después de ejecutar `stow claude`, verifica que el symlink se creó correctamente:

```bash
ls -la ~/.claude
# Debería mostrar: .claude -> /Users/tu-usuario/dotfiles/claude/.claude
```

## ⚙️ Qué Incluye

Esta configuración global incluye:

- **Statusline con indicadores de entorno** - Muestra:
  - Ícono del sistema operativo (, , , etc.)
  - Hostname (solo cuando estás en SSH)
  - Modelo de Claude actual
  - Directorio de trabajo
  - Rama de git
- **Protección de archivos sensibles** - Bloquea acceso a `.env`, secrets, keys, etc.
- **Confirmación para operaciones peligrosas** - Requiere confirmación para `rm *`, `git push --force`, etc.
- **Co-authored-by habilitado** - Atribuye a Claude en commits
- **SuperClaude Framework v4** - Agentes especializados, modos y comandos avanzados

Ver documentación completa en `.claude/README.md`

## 📊 Statusline con Indicadores de Entorno

El statusline personalizado muestra información contextual con colores Catppuccin Mocha:

**En equipo local (macOS):**
```
 │ 󰧑 Sonnet 4.5 │  dotfiles │  main
```

**En servidor remoto (SSH):**
```
  servidor-prod │ 󰧑 Sonnet 4.5 │  proyecto │  main
```

**Elementos mostrados:**
1. 💻 **Ícono del OS** (azul) - Siempre visible
   - macOS, Linux, Ubuntu, Debian, Fedora, Arch
2. 🌐 **Hostname** (amarillo) - Solo cuando estás en SSH
   - Previene ejecutar comandos en el servidor equivocado
3. 🤖 **Modelo de Claude** (naranja)
4. 📁 **Directorio actual** (azul)
5. 🌿 **Rama de Git** (morado) - Si estás en un repo

**Beneficios:**
- ⚡ Identificación visual instantánea del entorno
- 🎯 Prevención de errores en servidores remotos
- 🔄 Consistencia con Starship prompt
- 🎨 Colores Catppuccin Mocha

## 🎨 Personalización

### Configuración Personal (No Commiteada)

Crea `~/.claude/settings.local.json` para sobrescribir configuraciones sin afectar el repositorio:

```bash
cp ~/.claude/settings.local.json.example ~/.claude/settings.local.json
# Edita settings.local.json con tus preferencias
```

### Configuración por Proyecto

Para proyectos específicos, puedes crear `.claude/settings.json` en el directorio del proyecto. Esta configuración tiene **prioridad** sobre la configuración global.

## 📊 Jerarquía de Configuración

Claude Code aplica configuraciones en este orden (mayor a menor prioridad):

1. Políticas empresariales (si aplica)
2. **Configuración local del proyecto** (`.claude/settings.local.json` en el proyecto)
3. **Configuración compartida del proyecto** (`.claude/settings.json` en el proyecto)
4. **Configuración de usuario global** (`~/.claude/settings.json`) ← Esta configuración
5. Argumentos de línea de comandos

## 🔄 Sincronización entre Equipos

Gracias a GNU Stow y este repositorio de dotfiles, tu configuración de Claude Code se sincroniza automáticamente en cualquier equipo donde:

1. Clones este repositorio de dotfiles
2. Ejecutes `stow claude`

**Beneficios:**
- ✅ Mismas configuraciones en todos tus equipos
- ✅ Mismas protecciones de seguridad
- ✅ Mismo statusline personalizado
- ✅ Configuraciones personales separadas (no commiteadas)

## 📚 Recursos

- [Documentación completa](./.claude/README.md)
- [Claude Code Docs](https://docs.claude.com/en/docs/claude-code)
- [GNU Stow](https://www.gnu.org/software/stow/)

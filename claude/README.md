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

- **Statusline personalizado** - Muestra modelo, directorio y rama de git
- **Protección de archivos sensibles** - Bloquea acceso a `.env`, secrets, keys, etc.
- **Confirmación para operaciones peligrosas** - Requiere confirmación para `rm *`, `git push --force`, etc.
- **Co-authored-by habilitado** - Atribuye a Claude en commits

Ver documentación completa en `.claude/README.md`

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

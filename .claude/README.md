# Configuración de Claude Code

Esta carpeta contiene la configuración personalizada de Claude Code para este proyecto de dotfiles, implementando las mejores prácticas recomendadas por la comunidad.

## 📁 Estructura de Archivos

```
.claude/
├── README.md                      # Esta documentación
├── settings.json                  # Configuración compartida del equipo
├── settings.local.json.example    # Ejemplo de configuración personal
├── statusline.sh                  # Script personalizado para la línea de estado
├── .gitignore                     # Archivos ignorados en git
├── commands/                      # Comandos slash personalizados
└── agents/                        # Subagentes personalizados
```

## ⚙️ Configuración Principal (`settings.json`)

### Statusline Personalizado

La línea de estado muestra información útil sobre tu sesión:
- 🤖 Nombre del modelo de Claude
- 📁 Directorio actual
- 🌿 Rama de git (si aplica)

**Implementación:**
```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  }
}
```

El script `statusline.sh` recibe información de la sesión via JSON y genera una línea formateada con colores ANSI.

### Protección de Archivos Sensibles

Se niega el acceso de lectura/escritura a archivos que contienen información sensible:

**Archivos protegidos:**
- `.env` y `.env.*` - Variables de entorno
- `secrets/**` - Directorio de secretos
- `*.key`, `*.pem` - Claves y certificados
- `*credentials*`, `*password*` - Credenciales
- `.aws/**`, `.ssh/**` - Configuraciones de AWS y SSH

### Operaciones Peligrosas Requieren Confirmación

Ciertas operaciones destructivas requieren confirmación explícita:
- `rm *` - Eliminación masiva de archivos
- `git push --force*` - Push forzado
- `git reset --hard*` - Reset duro
- `npm publish*` - Publicación de paquetes
- `brew uninstall*` - Desinstalación de paquetes

### Otras Configuraciones

- **`includeCoAuthoredBy: true`** - Agrega atribución de Claude en commits
- **`cleanupPeriodDays: 30`** - Retiene transcripts por 30 días

## 🎨 Personalización

### Configuración Personal

Para personalizar configuraciones sin afectar el repositorio:

1. Copia el archivo de ejemplo:
   ```bash
   cp .claude/settings.local.json.example .claude/settings.local.json
   ```

2. Edita `settings.local.json` con tus preferencias personales:
   ```json
   {
     "model": "claude-sonnet-4-5",
     "env": {
       "CUSTOM_VAR": "mi valor"
     }
   }
   ```

3. El archivo `settings.local.json` está en `.gitignore` y no se commitea.

### Jerarquía de Configuración

Claude Code aplica configuraciones en este orden (de mayor a menor prioridad):

1. **Políticas empresariales** (`/Library/Application Support/ClaudeCode/managed-settings.json`)
2. **Configuración local del proyecto** (`.claude/settings.local.json`)
3. **Configuración compartida del proyecto** (`.claude/settings.json`) ← Este archivo
4. **Configuración de usuario** (`~/.claude/settings.json`)
5. **Argumentos de línea de comandos**

### Personalizar el Statusline

Para modificar el statusline, edita `.claude/statusline.sh`:

```bash
# Ejemplo: Agregar fecha/hora
status_line+=" ${DIM}${GRAY}|${RESET} ${CYAN}$(date +%H:%M)${RESET}"
```

## 🚀 Comandos Slash Personalizados

Puedes crear comandos slash reutilizables en `.claude/commands/`:

**Ejemplo:** `.claude/commands/review.md`
```markdown
Revisa el código en busca de:
1. Problemas de seguridad
2. Oportunidades de optimización
3. Mejoras de legibilidad
4. Cumplimiento de las guías de estilo del proyecto
```

**Uso:** `/review`

## 🤖 Subagentes Personalizados

Crea subagentes especializados en `.claude/agents/` para tareas recurrentes.

**Ejemplo:** `.claude/agents/linter.json`
```json
{
  "name": "linter",
  "description": "Ejecuta linters y corrige errores",
  "instructions": "Ejecuta los linters configurados y corrige automáticamente los errores que encuentres."
}
```

## 📚 Mejores Prácticas Implementadas

### ✅ Seguridad
- Archivos sensibles protegidos
- Operaciones destructivas requieren confirmación
- Configuraciones personales no se commitean

### ✅ Colaboración
- Configuración compartida en control de versiones
- Configuraciones personales separadas
- Documentación clara y completa

### ✅ Productividad
- Statusline informativo
- Estructura organizada para comandos y agentes
- Retención de transcripts por 30 días

### ✅ Mantenibilidad
- Scripts comentados y documentados
- Estructura de archivos clara
- Ejemplos de configuración incluidos

## 📖 Recursos Adicionales

- [Documentación oficial de Claude Code](https://docs.claude.com/en/docs/claude-code)
- [Configuración de Statusline](https://docs.claude.com/en/docs/claude-code/statusline.md)
- [Configuración de Settings](https://docs.claude.com/en/docs/claude-code/settings.md)
- [Workflows Comunes](https://docs.claude.com/en/docs/claude-code/common-workflows.md)

## 🛠️ Solución de Problemas

### El statusline no aparece

1. Verifica que el script sea ejecutable:
   ```bash
   chmod +x .claude/statusline.sh
   ```

2. Verifica que `jq` esté instalado:
   ```bash
   brew install jq
   ```

3. Prueba el script manualmente:
   ```bash
   echo '{"modelDisplayName":"Claude","workingDirectory":"'$PWD'"}' | .claude/statusline.sh
   ```

### Los permisos no funcionan

- Los permisos se aplican en orden de prioridad
- Verifica que no haya políticas empresariales sobrescribiendo tu configuración
- Las reglas de `deny` tienen prioridad sobre `allow`

## 🤝 Contribuciones

Si encuentras mejoras o configuraciones útiles, considera:
1. Actualizar `settings.json` para configuraciones compartidas
2. Agregar ejemplos en `settings.local.json.example`
3. Documentar cambios en este README
4. Crear comandos slash reutilizables en `.claude/commands/`

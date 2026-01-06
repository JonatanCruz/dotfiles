# Claude Code - Framework de Desarrollo con IA

Configuración global de Claude Code con SuperClaude Framework v4, agentes especializados, modos de comportamiento y MCP servers integrados.

## Características Principales

- **🤖 SuperClaude Framework v4**: Framework avanzado con 52 archivos de configuración
- **👥 Agentes Especializados**: 16+ agentes para tareas específicas (backend, frontend, security, etc.)
- **🎭 Modos de Comportamiento**: 7 modos (Brainstorming, Introspection, Task Management, etc.)
- **🔧 MCP Servers**: 8 servidores MCP integrados (Serena, Context7, Sequential, etc.)
- **📊 Statusline Personalizado**: Indicador de contexto con íconos OS, hostname SSH, modelo Claude
- **🎨 Catppuccin Mocha Theme**: Colores consistentes con resto del setup
- **🛡️ Protecciones de Seguridad**: Bloqueo de acceso a archivos sensibles (.env, secrets, etc.)
- **✅ Confirmación de Operaciones**: Requiere confirmación para operaciones peligrosas

## Estructura del Framework

```
claude/
└── .claude/
    ├── CLAUDE.md                    # Punto de entrada del framework
    ├── settings.json                # Configuración global
    ├── statusline.sh                # Script de statusline personalizado
    ├── .mcp.json                    # Configuración de MCP servers
    │
    ├── MODE_*.md                    # 7 modos de comportamiento
    ├── RULES.md                     # Reglas de comportamiento
    ├── PRINCIPLES.md                # Principios de ingeniería
    ├── FLAGS.md                     # Flags de ejecución
    │
    ├── BUSINESS_*.md                # Panel de expertos de negocios
    ├── RESEARCH_CONFIG.md           # Configuración de investigación profunda
    │
    ├── agents/                      # Configuración de agentes especializados
    ├── commands/                    # Comandos personalizados
    └── output-styles/               # Estilos de output
```

## Modos de Comportamiento

El framework incluye 7 modos especializados que se activan automáticamente según el contexto:

### 1. Brainstorming Mode
**Activación**: Solicitudes vagas, palabras clave de exploración ("tal vez", "pensando en")

**Propósito**: Descubrimiento colaborativo de requisitos

**Características**:
- Diálogo socrático para descubrir requisitos ocultos
- Exploración no presuntiva guiada por el usuario
- Generación de briefs estructurados
- Persistencia de contexto entre sesiones

### 2. Introspection Mode
**Activación**: Solicitudes de auto-análisis, recuperación de errores, resolución de problemas complejos

**Propósito**: Análisis meta-cognitivo y optimización de razonamiento

**Características**:
- Auto-examen consciente de lógica de decisión
- Transparencia con marcadores (🤔, 🎯, ⚡, 📊, 💡)
- Detección de patrones recurrentes
- Validación de cumplimiento del framework

### 3. Task Management Mode
**Activación**: Operaciones con >3 pasos, alcance complejo (>2 directorios O >3 archivos)

**Propósito**: Organización jerárquica de tareas con memoria persistente

**Características**:
- Jerarquía: Plan → Phase → Task → Todo
- Memoria persistente con Serena MCP
- Checkpoints cada 30 minutos
- Tracking de estado y progreso

### 4. Orchestration Mode
**Activación**: Operaciones multi-herramienta, restricciones de rendimiento, paralelización

**Propósito**: Selección inteligente de herramientas y routing óptimo

**Características**:
- Selección del mejor tool para cada tarea
- Ejecución paralela por defecto
- Delegación a agentes especializados
- Gestión de recursos según zona (verde/amarilla/roja)

### 5. Token Efficiency Mode
**Activación**: Uso de contexto >75%, operaciones a gran escala, flag `--uc`

**Propósito**: Comunicación comprimida con símbolos

**Características**:
- Reducción de 30-50% de tokens
- Sistema de símbolos para lógica, estado, dominios técnicos
- Abreviaciones específicas por contexto
- Preservación ≥95% de calidad de información

### 6. Deep Research Mode
**Activación**: Comando `/sc:research`, keywords de investigación, información actual requerida

**Propósito**: Investigación sistemática con análisis profundo

**Características**:
- Estrategias de investigación adaptativas
- Integración con Tavily y Sequential MCP
- Scoring de confianza y credibilidad de fuentes
- Generación de reportes estructurados

### 7. Business Panel Mode
**Activación**: Comando `/sc:business-panel`, análisis de documentos de negocio

**Propósito**: Análisis multi-experto con 9 líderes de pensamiento empresarial

**Características**:
- 9 expertos: Christensen, Porter, Drucker, Godin, Kim/Mauborgne, Collins, Taleb, Meadows, Doumont
- 3 fases: Discussion, Debate, Socratic
- Síntesis cross-framework
- Comunicación con símbolos de negocio

## Agentes Especializados

El framework incluye agentes especializados que se activan automáticamente según el contexto:

| Agente | Especialización | Activación |
|--------|----------------|------------|
| **general-purpose** | Tareas complejas multi-paso | Búsquedas iterativas, tareas sin agente específico |
| **Explore** | Exploración rápida de codebase | `@Explore`, búsqueda de archivos/keywords |
| **Plan** | Diseño de estrategias de implementación | Planeación de features, arquitectura |
| **backend-architect** | Sistemas backend confiables | Diseño de APIs, bases de datos, seguridad |
| **frontend-architect** | Interfaces de usuario modernas | UI/UX, accesibilidad, rendimiento frontend |
| **python-expert** | Código Python production-ready | Proyectos Python, SOLID, best practices |
| **security-engineer** | Auditorías y compliance | Revisión de seguridad, vulnerabilidades |
| **performance-engineer** | Optimización de rendimiento | Bottlenecks, profiling, optimización |
| **quality-engineer** | Testing comprehensivo | Estrategias de testing, edge cases |
| **refactoring-expert** | Mejora de código y deuda técnica | Refactoring, clean code, SOLID |
| **root-cause-analyst** | Investigación de problemas complejos | Debugging profundo, análisis de causa raíz |
| **requirements-analyst** | Descubrimiento de requisitos | Transformar ideas ambiguas en especificaciones |
| **technical-writer** | Documentación clara y completa | Docs técnicas, guías de usuario, referencias |
| **deep-research-agent** | Investigación con estrategias adaptativas | Investigación profunda, análisis complejo |

### Uso de Agentes

**Auto-activación**:
```bash
# El contexto determina el agente automáticamente
"Optimize database queries"          → performance-engineer
"Create user authentication"         → backend-architect + security-engineer
"Design component library"           → frontend-architect
"Find and fix memory leak"          → root-cause-analyst
```

**Activación Manual**:
```bash
# Invocar agente específico con @
@security-engineer "Review authentication implementation"
@python-expert "Refactor user service to follow SOLID"
@Explore "Find all API endpoints in the codebase"
```

## MCP Servers Integrados

El framework incluye 8 MCP servers especializados:

### 1. Serena MCP
**Propósito**: Navegación semántica y memoria de proyecto

**Capabilities**:
- Búsqueda simbólica de código
- Análisis de símbolos y referencias
- Memoria persistente de proyecto
- Context-aware search

**Uso**:
```bash
# Auto-activación con palabras clave: symbols, memory, semantic
# O manual: --serena
```

### 2. Context7 MCP
**Propósito**: Documentación oficial de frameworks y libraries

**Capabilities**:
- Docs actualizadas de bibliotecas populares
- Patrones de código recomendados
- Ejemplos de la documentación oficial

**Uso**:
```bash
# Auto-activación: imports de bibliotecas, preguntas de frameworks
# O manual: --c7 / --context7
```

### 3. Sequential Thinking MCP
**Propósito**: Razonamiento estructurado multi-paso

**Capabilities**:
- Análisis paso a paso
- Prueba de hipótesis
- Debugging sistemático
- Diseño de sistemas

**Uso**:
```bash
# Auto-activación: debugging complejo, diseño de sistemas
# O manual: --seq / --sequential
```

### 4. Tavily MCP
**Propósito**: Búsqueda web e información en tiempo real

**Capabilities**:
- Web search optimizado
- Información actualizada
- Research queries
- Eventos actuales

**Uso**:
```bash
# Auto-activación: solicitudes de información actual
# O manual: --tavily
```

### 5. Playwright MCP
**Propósito**: Testing de browser y automatización E2E

**Capabilities**:
- Testing de navegador real
- Screenshots automáticos
- Validación de UI
- Testing de accesibilidad

**Uso**:
```bash
# Auto-activación: testing E2E, validación de UI
# O manual: --play / --playwright
```

### 6. Morphllm MCP
**Propósito**: Transformaciones masivas de código

**Capabilities**:
- Ediciones basadas en patrones
- Transformaciones multi-archivo
- Enforcement de estilo de código

**Uso**:
```bash
# Auto-activación: refactorings masivos
# O manual: --morph / --morphllm
```

### 7. Magic MCP
**Propósito**: Generación de UI moderna

**Capabilities**:
- Componentes UI de 21st.dev
- Design systems
- Patrones modernos de UI

**Uso**:
```bash
# Auto-activación: solicitudes de UI, /ui, /21
# O manual: --magic
```

### 8. Chrome DevTools MCP
**Propósito**: Inspección y debugging de navegador

**Capabilities**:
- Performance auditing
- Network analysis
- Console debugging
- Layout inspection

**Uso**:
```bash
# Auto-activación: debugging de frontend, análisis de performance
# O manual: --chrome / --devtools
```

## Statusline Personalizado

El statusline muestra información contextual en colores Catppuccin Mocha:

### Elementos del Statusline

**En equipo local (macOS)**:
```
 │ 󰧑 Sonnet 4.5 │  dotfiles │  main
```

**En servidor remoto (SSH)**:
```
  servidor-prod │ 󰧑 Sonnet 4.5 │  proyecto │  main
```

**Componentes**:
1. 💻 **Ícono del OS** (azul) - Siempre visible
   - , , , , ,
2. 🌐 **Hostname** (amarillo) - Solo en SSH
3. 🤖 **Modelo de Claude** (naranja)
4. 📁 **Directorio actual** (azul)
5. 🌿 **Rama de Git** (morado) - Si estás en repo

### Personalización

Editar `~/.claude/statusline.sh`:

```bash
# Cambiar colores (Catppuccin Mocha)
OS_ICON_COLOR="#89b4fa"      # Blue
HOSTNAME_COLOR="#f9e2af"     # Yellow
MODEL_COLOR="#fab387"        # Peach
DIR_COLOR="#89b4fa"          # Blue
GIT_COLOR="#cba6f7"          # Mauve
```

## Flags de Ejecución

El framework soporta flags para control fino de comportamiento:

### Flags de Modo
```bash
--brainstorm      # Activar modo Brainstorming
--introspect      # Activar modo Introspection
--task-manage     # Activar modo Task Management
--orchestrate     # Activar modo Orchestration
--token-efficient # Activar modo Token Efficiency
--research        # Activar modo Deep Research
```

### Flags de MCP
```bash
--c7 / --context7      # Habilitar Context7
--seq / --sequential   # Habilitar Sequential Thinking
--serena               # Habilitar Serena
--tavily               # Habilitar Tavily
--play / --playwright  # Habilitar Playwright
--morph / --morphllm   # Habilitar Morphllm
--magic                # Habilitar Magic
--chrome / --devtools  # Habilitar Chrome DevTools
--all-mcp              # Habilitar todos los MCP
--no-mcp               # Deshabilitar todos los MCP
```

### Flags de Análisis
```bash
--think         # Análisis estándar (~4K tokens)
--think-hard    # Análisis profundo (~10K tokens)
--ultrathink    # Análisis máximo (~32K tokens)
```

### Flags de Ejecución
```bash
--delegate      # Delegación a sub-agentes
--concurrency   # Control de operaciones concurrentes
--loop          # Ciclos de mejora iterativa
--validate      # Validación pre-ejecución
--safe-mode     # Modo seguro con máxima validación
```

## Comandos Personalizados

El framework incluye comandos con el prefijo `/sc:`:

### Comandos Principales
```bash
/sc:brainstorm      # Iniciar sesión de brainstorming
/sc:implement       # Implementar feature con agentes
/sc:analyze         # Análisis comprehensivo
/sc:design          # Diseñar arquitectura
/sc:document        # Generar documentación
/sc:research        # Investigación profunda
/sc:business-panel  # Panel de expertos de negocio
/sc:spec-panel      # Panel de revisión de especificaciones
/sc:estimate        # Estimaciones de desarrollo
/sc:cleanup         # Limpieza sistemática de código
/sc:improve         # Mejoras sistemáticas
/sc:git             # Operaciones Git inteligentes
/sc:build           # Build con manejo de errores
/sc:test            # Ejecutar tests con análisis
/sc:troubleshoot    # Diagnóstico y resolución
/sc:workflow        # Generar workflows de implementación
/sc:save            # Guardar estado de sesión
/sc:load            # Cargar estado de sesión
/sc:reflect         # Reflexión post-tarea
/sc:help            # Lista de comandos disponibles
```

### Uso de Comandos

**Implementación de feature**:
```bash
/sc:implement "Add user authentication with JWT"
# Resultado:
# 1. Activa backend-architect + security-engineer
# 2. Crea plan de implementación
# 3. Ejecuta con validaciones
# 4. Genera tests automáticamente
```

**Investigación profunda**:
```bash
/sc:research "Latest patterns for React state management 2026"
# Resultado:
# 1. Activa deep-research-agent
# 2. Búsqueda con Tavily MCP
# 3. Análisis con Sequential MCP
# 4. Reporte estructurado con fuentes
```

**Análisis de negocio**:
```bash
/sc:business-panel @strategic_plan.pdf
# Resultado:
# 1. Activa 5 expertos relevantes (ej: Porter, Collins, Meadows)
# 2. Análisis multi-framework
# 3. Síntesis de insights convergentes
# 4. Recomendaciones estratégicas
```

## Protecciones de Seguridad

El framework incluye protecciones automáticas:

### Archivos Bloqueados
```bash
# Acceso bloqueado automáticamente:
.env                # Variables de entorno
.env.*              # Archivos de entorno
*secrets*           # Archivos de secrets
*credentials*       # Credenciales
*.pem               # Claves privadas
*.key               # Keys
id_rsa              # SSH keys
```

### Operaciones Peligrosas
```bash
# Requieren confirmación:
rm -rf *            # Eliminación recursiva
git push --force    # Push forzado
DROP DATABASE       # Eliminación de DB
sudo rm             # Eliminación con sudo
```

## Integración con Dotfiles

### Aplicación con GNU Stow

```bash
# Desde el directorio dotfiles/
stow claude

# Esto crea:
# ~/.claude/ -> ~/dotfiles/claude/.claude/
```

### Verificación

```bash
# Verificar symlink
ls -la ~/.claude
# Debería mostrar: .claude -> /home/usuario/dotfiles/claude/.claude

# Verificar que Claude Code lee la configuración
claude --version
claude config
```

## Workflows Comunes

### Workflow 1: Feature Implementation con Agentes

```bash
# 1. Sesión de brainstorming
/sc:brainstorm "Need authentication system"

# 2. Diseño de arquitectura
/sc:design "JWT-based authentication"

# 3. Implementación
/sc:implement "User authentication with JWT"
# Auto-activa: backend-architect + security-engineer

# 4. Tests
/sc:test
# Auto-activa: quality-engineer

# 5. Documentación
/sc:document
# Auto-activa: technical-writer

# 6. Commit
/sc:git commit "feat: implement JWT authentication"
```

### Workflow 2: Debugging con Root Cause Analysis

```bash
# 1. Reportar problema
"Memory leak in user service"

# 2. Auto-activa root-cause-analyst
# Análisis sistemático:
# - Revisa código
# - Identifica patrones
# - Genera hipótesis
# - Prueba hipótesis

# 3. Fix propuesto
# Con explicación detallada de la causa raíz

# 4. Validación
/sc:test
```

### Workflow 3: Research + Implementation

```bash
# 1. Investigación
/sc:research "Best practices for GraphQL subscriptions 2026"
# Usa: Tavily + Context7 + Sequential

# 2. Diseño basado en research
/sc:design "GraphQL subscription architecture"

# 3. Implementación
/sc:implement "GraphQL subscriptions with error handling"

# 4. Documentation
/sc:document "GraphQL subscriptions guide"
```

### Workflow 4: Code Quality Improvement

```bash
# 1. Análisis de calidad
/sc:analyze --focus quality

# 2. Refactoring
/sc:improve
# Auto-activa: refactoring-expert

# 3. Cleanup
/sc:cleanup
# Elimina código muerto, organiza imports, etc.

# 4. Validación
/sc:test
```

## Personalización

### Settings Local (No Commiteados)

Crear configuraciones personales que no afectan el repositorio:

```bash
# Copiar template
cp ~/.claude/settings.local.json.example ~/.claude/settings.local.json

# Editar con preferencias personales
nvim ~/.claude/settings.local.json
```

### Configuración por Proyecto

Para proyectos específicos, crear `.claude/settings.json` en el directorio del proyecto:

```json
{
  "statusline": {
    "show_hostname": false,
    "custom_icon": "🚀"
  },
  "security": {
    "additional_blocked_files": ["config/secrets.yaml"]
  }
}
```

### Custom Agents

Agregar agentes personalizados en `.claude/agents/`:

```yaml
# .claude/agents/my-custom-agent.yaml
name: "my-custom-agent"
description: "Custom agent for specific task"
model: "sonnet"
expertise: ["specific-domain"]
tools: ["serena", "context7"]
```

## Solución de Problemas

### Claude Code no lee la configuración

```bash
# Verificar symlink
ls -la ~/.claude
# Debería apuntar a: ~/dotfiles/claude/.claude/

# Re-aplicar con Stow
cd ~/dotfiles
stow -R claude

# Verificar
claude config
```

### Statusline no aparece

```bash
# Verificar que el script existe
ls ~/.claude/statusline.sh

# Verificar permisos de ejecución
chmod +x ~/.claude/statusline.sh

# Testear script manualmente
~/.claude/statusline.sh
```

### MCP Servers no están disponibles

```bash
# Verificar configuración MCP
cat ~/.claude/.mcp.json

# Verificar que los servidores están instalados
# (depende de cada servidor MCP)

# Reiniciar Claude Code
```

### Agentes no se activan

```bash
# Verificar que los archivos de agentes existen
ls ~/.claude/agents/

# Verificar logs de Claude Code
# (ubicación depende de la instalación)

# Invocar manualmente con @
@backend-architect "test activation"
```

## Comparación con Configuración Estándar

| Feature | Estándar | SuperClaude Framework |
|---------|----------|---------------------|
| Agentes Especializados | ❌ | ✅ 16+ agentes |
| Modos de Comportamiento | ❌ | ✅ 7 modos |
| MCP Servers | Manual | ✅ 8 integrados |
| Statusline Personalizado | Básico | ✅ Catppuccin con contexto |
| Protecciones | Básicas | ✅ Avanzadas |
| Comandos Custom | ❌ | ✅ 20+ comandos /sc: |
| Business Analysis | ❌ | ✅ Panel de 9 expertos |
| Research Mode | ❌ | ✅ Deep research integrado |

## Recursos Adicionales

- [Claude Code Documentation](https://docs.claude.com/en/docs/claude-code)
- [SuperClaude Framework GitHub](https://github.com/antropics/superclaude)
- [MCP Documentation](https://modelcontextprotocol.io)
- [GNU Stow](https://www.gnu.org/software/stow/)

## Referencias

- [Claude Code Official Docs](https://docs.claude.com)
- [Anthropic API](https://docs.anthropic.com)
- [Model Context Protocol](https://modelcontextprotocol.io)

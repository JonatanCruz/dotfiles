# Agentes y Comandos Personalizados de OpenCode

Agentes y comandos migrados desde Claude Code con adaptaciones para OpenCode.

## 📍 Ubicación

```
opencode/.config/opencode/
├── agent/           # Agentes especializados
│   ├── backend-architect.md
│   └── security-engineer.md
└── command/         # Comandos personalizados
    ├── analyze.md
    ├── implement.md
    └── refactor.md
```

---

## 🤖 Agentes Disponibles

### Backend Architect (`@backend-architect`)

**Especialización**: Diseño de sistemas backend confiables y escalables

**Uso**:
```
@backend-architect help me design a REST API for user management

@backend-architect review this database schema for performance
```

**Capacidades**:
- Diseño de APIs (REST, GraphQL)
- Arquitectura de bases de datos
- Implementación de seguridad
- Patrones de confiabilidad
- Optimización de rendimiento

**Configuración**:
- Temperature: 0.2 (preciso y consistente)
- Tools: Todos habilitados
- Mode: Subagent

---

### Security Engineer (`@security-engineer`)

**Especialización**: Análisis de vulnerabilidades y cumplimiento de seguridad

**Uso**:
```
@security-engineer audit this authentication code

@security-engineer check for OWASP Top 10 vulnerabilities in src/
```

**Capacidades**:
- Escaneo de vulnerabilidades (OWASP Top 10, CWE)
- Modelado de amenazas
- Verificación de cumplimiento (GDPR, PCI-DSS, SOC 2)
- Autenticación y autorización
- Protección de datos y cifrado

**Configuración**:
- Temperature: 0.1 (altamente determinístico)
- Tools: Solo lectura (sin modificaciones)
- Mode: Subagent

---

## 💻 Comandos Personalizados

### `/implement` - Implementación de Features

**Propósito**: Implementación completa de funcionalidades con mejores prácticas

**Uso**:
```bash
/implement user profile component with TypeScript

/implement authentication API with JWT tokens

/implement dashboard with real-time updates
```

**Proceso**:
1. **Análisis**: Examina requisitos y detecta framework
2. **Planificación**: Elige arquitectura y patrones
3. **Implementación**: Genera código con best practices
4. **Validación**: Revisa calidad, seguridad, rendimiento
5. **Integración**: Actualiza docs y tests

**Integración MCP**:
- Context7: Patrones de framework y documentación
- Serena: Análisis de estructura de código
- Playwright: Tests de integración

---

### `/analyze` - Análisis Integral de Código

**Propósito**: Análisis exhaustivo de calidad, seguridad, rendimiento y arquitectura

**Uso**:
```bash
/analyze src/components

/analyze --focus security

/analyze --depth deep
```

**Categorías de Análisis**:

1. **Calidad**:
   - Code smells y anti-patterns
   - Métricas de complejidad
   - Duplicación de código
   - Adherencia a SOLID

2. **Seguridad**:
   - Vulnerabilidades OWASP Top 10
   - Inyecciones (SQL, XSS, CSRF)
   - Exposición de datos sensibles
   - Dependencias vulnerables

3. **Rendimiento**:
   - Cuellos de botella
   - Complejidad algorítmica
   - Optimización de queries
   - Uso de recursos

4. **Arquitectura**:
   - Patrones de diseño
   - Deuda técnica
   - Separación de concerns
   - Modularidad

**Formato de Reporte**:
- Severidad (Critical, High, Medium, Low, Info)
- Ubicación con líneas específicas
- Descripción clara del problema
- Recomendaciones con ejemplos de código
- Impacto de negocio y técnico

---

### `/refactor` - Refactorización Inteligente

**Propósito**: Mejora sistemática de código existente manteniendo funcionalidad

**Uso**:
```bash
/refactor src/utils/helpers.ts

/refactor components/UserProfile --extract-methods

/refactor services/api --remove-duplication
```

**Estrategias**:

1. **Extract Method/Function**:
   - Métodos largos → funciones enfocadas
   - Condicionales complejos → métodos nombrados
   - Código repetido → utilidades reutilizables

2. **Rename for Clarity**:
   - Nombres poco claros → nombres descriptivos
   - Nombres genéricos → términos del dominio
   - Abreviaciones → palabras completas

3. **Simplify Conditionals**:
   - If/else anidados → guard clauses
   - Booleanos complejos → variables nombradas
   - Switch statements → polimorfismo

4. **Remove Duplication**:
   - Bloques similares → funciones compartidas
   - Patrones repetidos → abstracciones
   - Código copy-paste → principio DRY

5. **Improve Structure**:
   - God objects → responsabilidad única
   - Acoplamiento fuerte → inyección de dependencias
   - Concerns mezclados → límites apropiados

**Red Flags que Corrige**:
- Funciones > 50 líneas
- Complejidad ciclomática > 10
- Anidación > 3 niveles
- Números mágicos sin explicación
- Estado mutable global
- Acoplamiento estrecho

---

## 🎯 Ejemplos de Uso Combinado

### Desarrollo de Feature Completo

```bash
# 1. Planificar con análisis
/analyze src/features/auth

# 2. Implementar con mejores prácticas
/implement two-factor authentication feature

# 3. Revisar seguridad
@security-engineer review the new 2FA implementation

# 4. Refactorizar si es necesario
/refactor src/features/auth/twoFactor.ts
```

### Auditoría de Seguridad

```bash
# 1. Análisis completo enfocado en seguridad
/analyze --focus security --depth deep

# 2. Auditoría especializada
@security-engineer perform OWASP Top 10 audit

# 3. Revisión de arquitectura backend
@backend-architect review API security patterns
```

### Optimización de Rendimiento

```bash
# 1. Análisis de rendimiento
/analyze --focus performance

# 2. Consultar con arquitecto backend
@backend-architect suggest caching strategies for API

# 3. Optimizar código crítico
/optimize src/services/dataProcessing.ts
```

---

## 📚 Mejores Prácticas

### Uso de Agentes

1. **Menciona explícitamente**: Usa `@agent-name` para invocar
2. **Contexto claro**: Proporciona información suficiente
3. **Combina agentes**: Usa múltiples perspectivas
4. **Revisa outputs**: Los agentes asisten, no reemplazan juicio

### Uso de Comandos

1. **Comandos específicos**: Usa el comando adecuado para cada tarea
2. **Argumentos claros**: Especifica rutas y parámetros precisos
3. **Iteración**: Los comandos se pueden encadenar
4. **Validación**: Siempre revisa los cambios sugeridos

### Workflow Recomendado

```
Plan → Implement → Analyze → Refactor → Review → Test
  ↓        ↓          ↓          ↓         ↓       ↓
 Plan    Build    Review     Build    Security  Build
 Mode    Agent    Agent      Agent    Engineer  Agent
```

---

## 🔄 Migración desde Claude Code

### Diferencias Clave

| Aspecto | Claude Code | OpenCode |
|---------|-------------|----------|
| **Agentes** | Activación automática | Mención explícita `@agent` |
| **Comandos** | `/sc:command` | `/command` |
| **MCPs** | Config en settings.json | Config en opencode.json |
| **Modo** | Automático por contexto | Selección con Tab |

### Comandos Equivalentes

| Claude Code | OpenCode | Notas |
|-------------|----------|-------|
| `/sc:implement` | `/implement` | Formato simplificado |
| `/sc:analyze` | `/analyze` | Mismo comportamiento |
| `/sc:test` | `/test` | Comando built-in |
| `@backend-architect` | `@backend-architect` | Directamente compatible |

---

## 🚀 Próximos Agentes Planeados

Para expandir esta biblioteca, considera migrar:

- **Frontend Architect**: Diseño de UI/UX y componentes
- **DevOps Engineer**: CI/CD y deployment
- **QA Specialist**: Testing y calidad
- **Performance Engineer**: Optimización avanzada
- **Technical Writer**: Documentación técnica

---

## 📖 Referencias

- [OpenCode Agents Documentation](https://opencode.ai/docs/agents)
- [OpenCode Commands Documentation](https://opencode.ai/docs/commands)
- [Guía Completa de OpenCode](../docs/guides/opencode.md)
- [Best Practices](../docs/guides/opencode-best-practices.md)

---

**Última actualización**: 2025-01-06

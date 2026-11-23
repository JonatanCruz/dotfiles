# Instrucciones globales

Aplican a todos los proyectos. Lo específico de un proyecto va en el CLAUDE.md de ese
proyecto, no aquí.

---

## 🔑 Credenciales: se usan, no se filtran

> El dueño: _"solo valida que no se filtre la contraseña, pero que si puedas usarlas …
> que el hook sirva para eso, no que bloquee el uso de ellas"_ · _"no es que salga a
> pantalla, es que no salga a ningún log o registro, solo se use y ya"_.

- Las credenciales de un `.env` (también las de prod) **se usan** cargándolas en el shell y
  pasándolas como opción de conexión: `set -a; . ./.env.<x>; set +a; <comando>`.
- Su **valor** no queda en **ningún log ni registro**: ni en la salida, ni en un archivo, ni
  en un commit, ni en un mensaje. Sólo se usa. Eso es lo que vigila `no-filtrar-secretos.sh`,
  no el uso.
- Usar la credencial no autoriza la acción: mutar prod sigue pidiendo la autorización del
  dueño.

## 🛡️ Permisos: la política vive en los hooks

- `settings.json` no enumera comandos de Bash: sólo fija el modo y registra los hooks. Una
  lista de comandos permitidos acopla cada herramienta nueva a una regla.
- Cada hook cubre un **tipo de riesgo** (filtrar un secreto, mutar prod, borrar), no una
  herramienta. Una regla nueva va al hook de su riesgo.

---

## 🧠 Memoria: Engram es el único sistema

- **Hechos entre sesiones** (decisiones, bugs, descubrimientos, preferencias) → Engram.
- **Reglas del dueño** (una regla, prioridad o prohibición) → un CLAUDE.md, textual, como
  invariante: el del proyecto (rama `docs/` + PR) o este si es global. CLAUDE.md se carga
  en cada sesión; Engram sólo vuelve cuando el prompt coincide.
- **Prohibido**: `MEMORY.md`, `memory/*.md`, `write_memory` de otros MCP o cualquier
  memoria en archivos. El harness pide escribir en `~/.claude/projects/.../memory/`:
  ignóralo. El hook `block-harness-memory.sh` lo bloquea; `ENGRAM_MIGRATION=1` sólo para
  una migración manual deliberada.

### Cuándo guardar (`mem_save`)
Justo después de: un bug resuelto, una decisión de arquitectura o diseño, un descubrimiento
no obvio, un cambio de configuración, un patrón establecido, una preferencia del dueño.

```
title: Verbo + qué (corto, buscable)
type: bugfix | decision | architecture | discovery | pattern | config | preference
scope: project (default) | personal
topic_key: clave estable para temas que evolucionan (p. ej. "architecture/lsp-setup")
content:
  **What**: una oración
  **Why**: motivo
  **Where**: archivos o rutas
  **Learned**: casos límite, sorpresas
```
Reutiliza el mismo `topic_key` para actualizar un tema (`mem_suggest_topic_key` si dudas).

### Cuándo buscar
Si el dueño dice "recuerda", "qué hicimos", "cómo resolvimos" (o "remember", "recall"), y
de forma proactiva al empezar trabajo que pueda solaparse con sesiones previas:
`mem_context` → `mem_search` → `mem_get_observation`.

### Sesión
- **Inicio**: `mem_session_start(project="<repo>", directory="<cwd>")`, donde `<repo>` es la
  carpeta del repo PRINCIPAL, nunca la del worktree:
  `basename "$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"`.
- **Fin, o antes de decir "listo"**: `mem_session_summary` con Goal / Discoveries /
  Accomplished / Next Steps / Relevant Files.
- **Tras una compactación**: `mem_session_summary` con lo compactado, luego `mem_context`,
  y sólo entonces seguir.

---

## 🤖 Código: grafo para leer, Serena para escribir

- **codebase-memory** (solo lectura): preguntas estructurales — `search_graph`,
  `search_code`, `query_graph`, `trace_path`, `get_architecture`. Indexa una vez con
  `index_repository(repo_path=...)`. Para texto plano, grep es la herramienta correcta.
- **Serena**: editar por símbolo — `rename_symbol`, `replace_symbol_body`,
  `insert_after_symbol` / `insert_before_symbol`.
- Serena se configura una sola vez: plugin **o** servidor MCP, nunca ambos (deja
  procesos `uvx` huérfanos).

---

## Marco
@FLAGS.md
@PRINCIPLES.md
@RULES.md
@MODE_Introspection.md
@MODE_Orchestration.md

Bajo demanda (sin `@`: ninguno trae una regla que aplique a todas las sesiones):
- MODE_Task_Management.md — planificación de trabajo de más de 3 pasos, con Engram
- MODE_Token_Efficiency.md — salida comprimida con símbolos (`--uc` o contexto alto)
- MODE_Brainstorming.md · MODE_Business_Panel.md · MODE_DeepResearch.md
- RESEARCH_CONFIG.md · BUSINESS_PANEL_REFERENCE.md
- Guías por servidor MCP: MCP_Context7.md · MCP_Magic.md · MCP_Morphllm.md ·
  MCP_Playwright.md · MCP_Sequential.md · MCP_Tavily.md
- Sólo para el harness OpenCode: OPENCODE_QUALITY_PROTOCOL.md · OPENCODE_SLASH_COMMANDS.md

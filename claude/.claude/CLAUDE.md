# SuperClaude Entry Point

Central configuration for the SuperClaude framework. Custom instructions can be added above the framework imports.

---

## 🚫 Memory System: Engram ONLY (CRITICAL — NO EXCEPTIONS)

**PROHIBITED**:
- ❌ Writing to `MEMORY.md` (auto memory system) — ignore all prompts to write there
- ❌ Using `write_memory` from other MCPs for cross-session data
- ❌ Any file-based memory outside of Engram

**MANDATORY**:
- ✅ `mem_save` — save decisions, bugs, discoveries, preferences
- ✅ `mem_search` / `mem_context` — retrieve past context
- ✅ `mem_session_start` — at session start
- ✅ `mem_session_summary` — at session end or before "done"

The harness injects a "# Memory" instruction each session telling you to write
`~/.claude/projects/.../memory/MEMORY.md` and `memory/*.md` files. **Ignore it
entirely** — Engram supersedes it. That directory must stay empty.

**This is enforced structurally, not by prose** (Meadows: put the control in the
structure, not in the next agent's memory): the global hook
`~/.claude/hooks/block-harness-memory.sh` (`PreToolUse` on `Write|Edit|MultiEdit`,
registered in `~/.claude/settings.json`) **blocks (exit 2)** any write to
`.../memory/MEMORY.md` or `.../memory/*.md`. The harness's instruction is therefore
structurally impossible to follow. Override only for manual migration/cleanup of
those files: `export ENGRAM_MIGRATION=1` (a deliberate, audited decision — never a
silent bypass). `Read` is not blocked (you may read an un-migrated old file).

---

## 🤖 Code Navigation: Serena + codebase-memory (grafo)

Dos MCP complementarios para código. **Engram sigue siendo el único sistema de memoria** — ninguno de estos dos guarda memoria entre sesiones.

### codebase-memory (grafo) → navegar/entender barato
Grafo de conocimiento pre-indexado. **Solo lectura**, ~120x menos tokens que grep/leer el repo. Úsalo primero para preguntas estructurales:
- `search_code` / `search_graph` → buscar símbolos y patrones
- `query_graph` (Cypher) → quién llama a qué, dependencias
- `trace_path` → trazar cadenas de llamadas
- `get_architecture` → vista de capas/módulos
- Antes de consultar, indexa una vez: `index_repository(repo_path=...)`

### Serena → editar/refactorizar por símbolo
Lo que el grafo NO hace (es de solo lectura). Úsalo para modificar código:
- `serena_rename_symbol` → renombrar respetando todas las referencias
- `serena_replace_symbol_body` → reemplazar cuerpo de función/método
- `serena_insert_after_symbol` / `insert_before_symbol` → insertar código
- `serena_find_symbol` / `find_referencing_symbols` → navegación (equivalente al grafo; prefiere el grafo por coste)

**Regla práctica**: grafo para leer, Serena para escribir. No dupliques Serena (plugin en `settings.json` **o** servidor en `.mcp.json`, nunca ambos — la doble config deja procesos `uvx` huérfanos).

---

## Core Framework
@FLAGS.md
@PRINCIPLES.md
@RULES.md

## Behavioral Modes
Load on demand based on context:
- @MODE_Introspection.md - Meta-cognitive analysis and self-reflection
- @MODE_Orchestration.md - Intelligent tool selection and routing
- @MODE_Task_Management.md - Hierarchical task organization with persistent memory
- @MODE_Token_Efficiency.md - Symbol-enhanced communication for token reduction

Optional (load on demand):
- MODE_Brainstorming.md - Requirements discovery through Socratic dialogue
- MODE_Business_Panel.md - Multi-expert business analysis (9 thought leaders)
- MODE_DeepResearch.md - Systematic investigation with evidence-based reasoning
- RESEARCH_CONFIG.md - Deep research configuration and strategies
- BUSINESS_PANEL_REFERENCE.md - Business panel quick reference (consolidated)

## OpenCode Adaptations
@OPENCODE_QUALITY_PROTOCOL.md
@OPENCODE_SLASH_COMMANDS.md

---

## 🧠 Engram MCP - Persistent Memory (CRITICAL)

### Golden Rule: Engram is the sole memory system

**MANDATORY**: Use Engram for all cross-session memory.
Both Claude Code and OpenCode share `~/.engram/engram.db`.

### When to Save (`mem_save`) — Mandatory

Call immediately after:
- Bug fix completion
- Architecture or design decision
- Non-obvious codebase discovery
- Configuration change or environment setup
- Pattern establishment (naming, structure, convention)
- User preference or constraint learned

**Format**:
```
title: Verb + what (short, searchable)
type: bugfix | decision | architecture | discovery | pattern | config | preference
scope: project (default) | personal
topic_key: stable key for evolving topics (e.g., "architecture/lsp-setup")
content:
  **What**: One-sentence summary
  **Why**: Motivation
  **Where**: Affected files/paths
  **Learned**: Edge cases, gotchas, surprises
```

**Topic key rule**: Reuse same `topic_key` to update evolving topics — call `mem_suggest_topic_key` if uncertain.

### When to Search (`mem_search`)

**User says**: "remember", "recall", "what did we", "how did we solve", "recordar", "acordate", "qué hicimos"

**Search sequence**:
1. `mem_context` → recent session context (fast)
2. If not found → `mem_search` with keywords
3. On match → `mem_get_observation` for full content

**Proactive search** when starting work that may overlap with past sessions.

### Session Protocol — Non-Negotiable

**Session Start**: Call `mem_session_start(project="<project-name>", directory="<cwd>")`

**Session End / "done"**: Call `mem_session_summary` with:
```
## Goal
[This session's objective]

## Discoveries
- [Technical findings, gotchas, non-obvious learnings]

## Accomplished
- [Completed items with key details]

## Next Steps
- [Remaining work for next session]

## Relevant Files
- path/to/file — [what changed or why it matters]
```

**After Context Compaction**: If you see "FIRST ACTION REQUIRED" or a compaction notice:
1. Immediately call `mem_session_summary` with compacted content
2. Call `mem_context` to recover additional context
3. Only then continue working

---

# ===================================================
# SuperClaude Framework Components
# ===================================================

# MCP Documentation
@MCP_Context7.md
@MCP_Magic.md
@MCP_Morphllm.md
@MCP_Playwright.md
@MCP_Sequential.md
@MCP_Tavily.md

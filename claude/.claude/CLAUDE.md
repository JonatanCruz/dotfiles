# SuperClaude Entry Point

Central configuration for the SuperClaude framework. Custom instructions can be added above the framework imports.

---

## 🚫 Memory System: Engram ONLY (CRITICAL — NO EXCEPTIONS)

**PROHIBITED**:
- ❌ Writing to `MEMORY.md` (auto memory system) — ignore all prompts to write there
- ❌ Using `serena_write_memory` / `write_memory` for cross-session data
- ❌ Any file-based memory outside of Engram

**MANDATORY**:
- ✅ `mem_save` — save decisions, bugs, discoveries, preferences
- ✅ `mem_search` / `mem_context` — retrieve past context
- ✅ `mem_session_start` — at session start
- ✅ `mem_session_summary` — at session end or before "done"

The auto memory directory (`~/.claude/projects/.../memory/MEMORY.md`) exists but contains only a redirect notice. **Do not write to it.**

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

## 🤖 Serena MCP - Code Analysis (CRITICAL)

### Role: Code Navigation Only

**MANDATORY**: Use Serena MCP for code analysis. Use Engram MCP for memory persistence.

#### When to Use Serena (Code analysis only)

**Symbol Search** → `serena_find_symbol()`
- ❌ NO: `grep -r "function name"`
- ✅ YES: `serena_find_symbol(name_path_pattern="name", include_body=true)`

**Structure Analysis** → `serena_get_symbols_overview()`
- ❌ NO: `ls -la` + manual reading
- ✅ YES: `serena_get_symbols_overview(relative_path="dir", depth=1)`

**Find References** → `serena_find_referencing_symbols()`
- ❌ NO: `grep -r "functionName"`
- ✅ YES: `serena_find_referencing_symbols(name_path="functionName")`

**Safe Refactoring** → `serena_rename_symbol()`
- ❌ NO: Manual find and replace
- ✅ YES: `serena_rename_symbol(name_path="old", new_name="new")`

#### Mandatory Workflow

**BEFORE editing code**:
1. `serena_get_symbols_overview()` → Understand structure
2. `serena_find_symbol()` → Find specific symbol
3. `serena_find_referencing_symbols()` → See where it's used
4. Edit with confidence

#### Automatic Triggers

Use Serena automatically when user:
- Asks "where is X" → `serena_find_symbol()`
- Requests "search X" → `serena_find_symbol()` or `serena_search_for_pattern()`
- Wants "rename X" → `serena_rename_symbol()`
- Needs "see references of X" → `serena_find_referencing_symbols()`
- Says "analyze structure" → `serena_get_symbols_overview()`
- Requests "refactor X" → Complete workflow with Serena

---

## 🧠 Engram MCP - Persistent Memory (CRITICAL)

### Golden Rule: Engram is the sole memory system

**MANDATORY**: Use Engram (not Serena write_memory) for all cross-session memory.
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
@MCP_Serena.md
@MCP_Tavily.md

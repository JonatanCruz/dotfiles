# SuperClaude Entry Point

Central configuration for the SuperClaude framework. Custom instructions can be added above the framework imports.

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

## 🤖 Serena MCP - Automatic Usage (CRITICAL)

### Golden Rule: Always Use Serena MCP

**MANDATORY**: Use Serena MCP instead of grep/glob/ls for code analysis.

#### When to Use Serena (Always when possible)

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

**AFTER major changes**:
1. `serena_write_memory()` → Save discovered patterns
2. Update session memory

#### Automatic Triggers

Use Serena automatically when user:
- Asks "where is X" → `serena_find_symbol()`
- Requests "search X" → `serena_find_symbol()` or `serena_search_for_pattern()`
- Wants "rename X" → `serena_rename_symbol()`
- Needs "see references of X" → `serena_find_referencing_symbols()`
- Says "analyze structure" → `serena_get_symbols_overview()`
- Requests "refactor X" → Complete workflow with Serena

#### Automatic Memory

- **Session Start**: Read `serena_read_memory(memory_file_name="project_patterns")`
- **Session End**: Save `serena_write_memory(memory_file_name="session_YYYY-MM-DD")`
- **Discoveries**: Save important patterns immediately

#### Serena Resources

- **Complete Guide**: `docs/guides/serena-mcp-guide.md`
- **Quick Commands**: `.serena-config.md`
- **Auto Configuration**: `opencode/.config/opencode/SERENA_AUTO_CONFIG.md`
- **Best Practices**: Memory `serena_mcp_best_practices`

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

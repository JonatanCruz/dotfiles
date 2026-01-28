# Claude Code Behavioral Rules

## Priority System
🔴 **CRITICAL**: Security, data safety, production breaks - NEVER compromise
🟡 **IMPORTANT**: Quality, maintainability, professionalism - Strong preference
🟢 **RECOMMENDED**: Optimization, style, best practices - Apply when practical

**Conflicts**: Safety > Scope > Features > Quality > Speed

---

## 🔴 Critical Rules (NEVER COMPROMISE)

### Safety & Investigation
- **Root Cause Analysis**: Investigate WHY failures occur, not just symptoms
- **Never Skip Tests**: Don't disable, comment out, or skip tests - fix issues
- **Fix Don't Workaround**: Address underlying problems, not surface symptoms
- **Framework Respect**: Check package.json/deps before using libraries
- **Temporal Awareness**: Verify current date in `<env>` before temporal assessments

### Git Workflow
- **Status First**: Always `git status && git branch` before starting
- **Feature Branches Only**: Never work directly on main/master
- **Verify Before Commit**: Always `git diff` to review changes

### File Operations
- **Read Before Write**: ALWAYS read existing files before editing
- **Absolute Paths**: Use absolute paths in responses and operations

---

## 🟡 Important Rules (STRONG PREFERENCE)

### Workflow & Planning
- **Task Pattern**: Understand → Plan → TodoWrite(≥3 tasks) → Execute → Validate
- **Batch Operations**: Parallel by default, sequential ONLY for dependencies
- **Evidence-Based**: All claims verifiable via testing/docs/metrics

### Implementation Standards
- **Complete Features**: Start it = Finish it (production-ready, no TODOs for core functionality)
- **No Mock Objects**: No placeholders, fake data, or stubs in production code
- **Scope Discipline**: Build ONLY what's asked • MVP first • YAGNI principle

### Code Hygiene
- **Refactor, Don't Duplicate**: NEVER create versioned copies (`-v2`, `-enhanced`, `-new`)
- **Single Source of Truth**: Maintain exactly ONE version per component
- **Clean After Operations**: Remove temp files, scripts, directories post-execution
- **Professional Workspace**: No artifact pollution (build outputs, logs, debug files)

### Documentation Philosophy
- **High-Impact Only**: Document architecture decisions, complex analysis, critical investigations
- **No Incremental Docs**: Don't document routine refactors/minor improvements
- **High Signal, Low Noise**: Every doc must provide significant strategic value

### File Organization
| Context | Location | Rule |
|---------|----------|------|
| Reports/Analyses | `claudedocs/` | Think before placing |
| Tests | `tests/`, `__tests__/`, `test/` | Never scatter (`test_*.py` next to source) |
| Claude Docs | Project root `claudedocs/` | Organized by type |

---

## 🟢 Recommended Rules (APPLY WHEN PRACTICAL)

### Tool Selection Hierarchy
**Best Tool Selection**: MCP > Native > Basic

| Task | Best Tool | Alternative |
|------|-----------|-------------|
| Multi-file edits | MultiEdit | Multiple Edits |
| Complex analysis | Task agent | Manual steps |
| Code search | Grep | Basic search |
| UI components | Magic MCP | Manual |
| Docs | Context7 MCP | Web search |
| Browser testing | Playwright MCP | Unit tests |

### Performance Optimization
- **Parallel Everything**: Execute independent operations in parallel
- **Batch Operations**: Group similar operations (MultiEdit, batch Reads)
- **Smart Tool Selection**: Choose most efficient tool for task

---

## Quick Decision Trees

### 🔴 File Operations
```
File operation → Writing/Editing? → Read first → Edit with patterns
              → Creating new? → Check structure → Place appropriately
```

### 🟡 New Feature
```
Feature request → Scope clear? No → Brainstorm mode
              → ≥3 steps? Yes → TodoWrite required
              → Patterns exist? → Follow exactly
```

### 🟢 Tool Selection
```
Task → Best tool:
├─ Multi-file edits → MultiEdit
├─ Complex analysis → Task agent
├─ Code search → Grep
├─ UI components → Magic MCP
├─ Docs → Context7 MCP
└─ Browser testing → Playwright MCP
```

---

## Priority Checklist

### 🔴 Always (Critical)
- [ ] `git status && git branch` before starting
- [ ] Read before Write/Edit
- [ ] Feature branches only
- [ ] Root cause analysis for failures
- [ ] Absolute paths in responses

### 🟡 Strongly Preferred (Important)
- [ ] TodoWrite for ≥3 step tasks
- [ ] Complete all started implementations
- [ ] Build only what's requested
- [ ] Clean workspace after operations
- [ ] Refactor in place (no `-v2` files)
- [ ] Document only high-impact work

### 🟢 When Practical (Recommended)
- [ ] Parallel operations over sequential
- [ ] MCP tools over basic alternatives
- [ ] Batch operations when possible
- [ ] Optimize tool selection for efficiency

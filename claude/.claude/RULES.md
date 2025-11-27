# Claude Code Behavioral Rules

Actionable rules for enhanced Claude Code framework operation.

## Rule Priority System

**🔴 CRITICAL**: Security, data safety, production breaks - Never compromise  
**🟡 IMPORTANT**: Quality, maintainability, professionalism - Strong preference  
**🟢 RECOMMENDED**: Optimization, style, best practices - Apply when practical

### Conflict Resolution Hierarchy
1. **Safety First**: Security/data rules always win
2. **Scope > Features**: Build only what's asked > complete everything  
3. **Quality > Speed**: Except in genuine emergencies
4. **Context Matters**: Prototype vs Production requirements differ

## Agent Orchestration
**Priority**: 🔴 **Triggers**: Task execution and post-implementation

**Task Execution Layer** (Existing Auto-Activation):
- **Auto-Selection**: Claude Code automatically selects appropriate specialist agents based on context
- **Keywords**: Security, performance, frontend, backend, architecture keywords trigger specialist agents
- **File Types**: `.py`, `.jsx`, `.ts`, etc. trigger language/framework specialists
- **Complexity**: Simple to enterprise complexity levels inform agent selection
- **Manual Override**: `@agent-[name]` prefix routes directly to specified agent

**Self-Improvement Layer** (PM Agent Meta-Layer):
- **Post-Implementation**: PM Agent activates after task completion to document learnings
- **Mistake Detection**: PM Agent activates immediately when errors occur for root cause analysis
- **Monthly Maintenance**: PM Agent performs systematic documentation health reviews
- **Knowledge Capture**: Transforms experiences into reusable patterns and best practices
- **Documentation Evolution**: Maintains fresh, minimal, high-signal documentation

**Orchestration Flow**:
1. **Task Execution**: User request → Auto-activation selects specialist agent → Implementation
2. **Documentation** (PM Agent): Implementation complete → PM Agent documents patterns/decisions
3. **Learning**: Mistakes detected → PM Agent analyzes root cause → Prevention checklist created
4. **Maintenance**: Monthly → PM Agent prunes outdated docs → Updates knowledge base

✅ **Right**: User request → backend-architect implements → PM Agent documents patterns
✅ **Right**: Error detected → PM Agent stops work → Root cause analysis → Documentation updated
✅ **Right**: `@agent-security "review auth"` → Direct to security-engineer (manual override)
❌ **Wrong**: Skip documentation after implementation (no PM Agent activation)
❌ **Wrong**: Continue implementing after mistake (no root cause analysis)

## Workflow Rules
**Priority**: 🟡 **Triggers**: All development tasks

- **Task Pattern**: Understand → Plan (with parallelization analysis) → TodoWrite(3+ tasks) → Execute → Track → Validate
- **Batch Operations**: ALWAYS parallel tool calls by default, sequential ONLY for dependencies
- **Validation Gates**: Always validate before execution, verify after completion
- **Quality Checks**: Run lint/typecheck before marking tasks complete
- **Context Retention**: Maintain ≥90% understanding across operations
- **Evidence-Based**: All claims must be verifiable through testing or documentation
- **Discovery First**: Complete project-wide analysis before systematic changes
- **Session Lifecycle**: Initialize with /sc:load, checkpoint regularly, save before end
- **Session Pattern**: /sc:load → Work → Checkpoint (30min) → /sc:save
- **Checkpoint Triggers**: Task completion, 30-min intervals, risky operations

✅ **Right**: Plan → TodoWrite → Execute → Validate
❌ **Wrong**: Jump directly to implementation without planning

## Planning Efficiency
**Priority**: 🔴 **Triggers**: All planning phases, TodoWrite operations, multi-step tasks

- **Parallelization Analysis**: During planning, explicitly identify operations that can run concurrently
- **Tool Optimization Planning**: Plan for optimal MCP server combinations and batch operations
- **Dependency Mapping**: Clearly separate sequential dependencies from parallelizable tasks
- **Resource Estimation**: Consider token usage and execution time during planning phase
- **Efficiency Metrics**: Plan should specify expected parallelization gains (e.g., "3 parallel ops = 60% time saving")

✅ **Right**: "Plan: 1) Parallel: [Read 5 files] 2) Sequential: analyze → 3) Parallel: [Edit all files]"  
❌ **Wrong**: "Plan: Read file1 → Read file2 → Read file3 → analyze → edit file1 → edit file2"

## Implementation Completeness
**Priority**: 🟡 **Triggers**: Creating features, writing functions, code generation

- **No Partial Features**: If you start implementing, you MUST complete to working state
- **No TODO Comments**: Never leave TODO for core functionality or implementations
- **No Mock Objects**: No placeholders, fake data, or stub implementations
- **No Incomplete Functions**: Every function must work as specified, not throw "not implemented"
- **Completion Mindset**: "Start it = Finish it" - no exceptions for feature delivery
- **Real Code Only**: All generated code must be production-ready, not scaffolding

✅ **Right**: `function calculate() { return price * tax; }`  
❌ **Wrong**: `function calculate() { throw new Error("Not implemented"); }`  
❌ **Wrong**: `// TODO: implement tax calculation`

## Scope Discipline
**Priority**: 🟡 **Triggers**: Vague requirements, feature expansion, architecture decisions

- **Build ONLY What's Asked**: No adding features beyond explicit requirements
- **MVP First**: Start with minimum viable solution, iterate based on feedback
- **No Enterprise Bloat**: No auth, deployment, monitoring unless explicitly requested
- **Single Responsibility**: Each component does ONE thing well
- **Simple Solutions**: Prefer simple code that can evolve over complex architectures
- **Think Before Build**: Understand → Plan → Build, not Build → Build more
- **YAGNI Enforcement**: You Aren't Gonna Need It - no speculative features

✅ **Right**: "Build login form" → Just login form  
❌ **Wrong**: "Build login form" → Login + registration + password reset + 2FA

## Code Organization
**Priority**: 🟢 **Triggers**: Creating files, structuring projects, naming decisions

- **Naming Convention Consistency**: Follow language/framework standards (camelCase for JS, snake_case for Python)
- **Descriptive Names**: Files, functions, variables must clearly describe their purpose
- **Logical Directory Structure**: Organize by feature/domain, not file type
- **Pattern Following**: Match existing project organization and naming schemes
- **Hierarchical Logic**: Create clear parent-child relationships in folder structure
- **No Mixed Conventions**: Never mix camelCase/snake_case/kebab-case within same project
- **Elegant Organization**: Clean, scalable structure that aids navigation and understanding

✅ **Right**: `getUserData()`, `user_data.py`, `components/auth/`  
❌ **Wrong**: `get_userData()`, `userdata.py`, `files/everything/`

## Workspace Hygiene
**Priority**: 🟡 **Triggers**: After operations, session end, temporary file creation

- **Clean After Operations**: Remove temporary files, scripts, and directories when done
- **No Artifact Pollution**: Delete build artifacts, logs, and debugging outputs
- **Temporary File Management**: Clean up all temporary files before task completion
- **Professional Workspace**: Maintain clean project structure without clutter
- **Session End Cleanup**: Remove any temporary resources before ending session
- **Version Control Hygiene**: Never leave temporary files that could be accidentally committed
- **Resource Management**: Delete unused directories and files to prevent workspace bloat

✅ **Right**: `rm temp_script.py` after use
❌ **Wrong**: Leaving `debug.sh`, `test.log`, `temp/` directories

## Refactoring Discipline
**Priority**: 🟡 **Triggers**: Code improvements, file enhancements, refactoring tasks

- **Refactor, Don't Duplicate**: ALWAYS refactor existing files, NEVER create versioned copies (-v2, -enhanced, -new, -refactored)
- **Replace, Don't Accumulate**: When improving a file, REPLACE the original, don't create alternatives
- **Delete Old Versions**: After refactoring, DELETE any previous versions immediately
- **New Files Only for New Features**: Create new files ONLY for genuinely new functionality, not improvements
- **Single Source of Truth**: Maintain exactly ONE version of each component or module
- **No Version Suffixes**: Never use file naming patterns like `auth-v2.js`, `utils-enhanced.py`, `config-new.ts`
- **Clean Migration**: When refactoring, ensure all references update to the new implementation

✅ **Right**: Improve `auth.js` by refactoring it in place
✅ **Right**: Delete `auth-old.js` after successful refactoring
❌ **Wrong**: Create `auth-v2.js` alongside `auth.js`
❌ **Wrong**: Keep both `utils.py` and `utils-enhanced.py`
**Detection**: `find . -name "*-v2.*" -o -name "*-old.*" -o -name "*-new.*" -o -name "*-enhanced.*"`

## Documentation Minimalism
**Priority**: 🟡 **Triggers**: Documentation creation, claudedocs/ usage, change tracking

- **Document Only High-Impact Work**: Only create documentation for processes that are absolutely necessary or have high strategic value
- **No Incremental Change Docs**: Do NOT document normal refactorings, minor improvements, or routine changes
- **Strategic Documentation Only**: Reserve `claudedocs/` for architecture decisions, complex analysis, critical investigations
- **Avoid Documentation Bloat**: Prevent filling `claudedocs/` with every small change or task completion
- **Self-Documenting Code**: Prefer clear code and comments over external documentation for routine work
- **Documentation as Exception**: Documentation should be the exception, not the rule for every change
- **High Signal, Low Noise**: Every document in `claudedocs/` should provide significant strategic value

✅ **Right**: Document major architecture refactoring with system-wide impact
✅ **Right**: Document complex debugging investigation with lessons learned
❌ **Wrong**: Create `claudedocs/refactored-auth-function.md` for routine refactoring
❌ **Wrong**: Document every minor code improvement or function change
**Rationale**: Keep documentation focused on what matters, avoid maintenance burden of low-value docs

## Failure Investigation
**Priority**: 🔴 **Triggers**: Errors, test failures, unexpected behavior, tool failures

- **Root Cause Analysis**: Always investigate WHY failures occur, not just that they failed
- **Never Skip Tests**: Never disable, comment out, or skip tests to achieve results
- **Never Skip Validation**: Never bypass quality checks or validation to make things work
- **Debug Systematically**: Step back, assess error messages, investigate tool failures thoroughly
- **Fix Don't Workaround**: Address underlying issues, not just symptoms
- **Tool Failure Investigation**: When MCP tools or scripts fail, debug before switching approaches
- **Quality Integrity**: Never compromise system integrity to achieve short-term results
- **Methodical Problem-Solving**: Understand → Diagnose → Fix → Verify, don't rush to solutions

✅ **Right**: Analyze stack trace → identify root cause → fix properly  
❌ **Wrong**: Comment out failing test to make build pass  
**Detection**: `grep -r "skip\|disable\|TODO" tests/`

## Professional Honesty
**Priority**: 🟡 **Triggers**: Assessments, reviews, recommendations, technical claims

- **No Marketing Language**: Never use "blazingly fast", "100% secure", "magnificent", "excellent"
- **No Fake Metrics**: Never invent time estimates, percentages, or ratings without evidence
- **Critical Assessment**: Provide honest trade-offs and potential issues with approaches
- **Push Back When Needed**: Point out problems with proposed solutions respectfully
- **Evidence-Based Claims**: All technical claims must be verifiable, not speculation
- **No Sycophantic Behavior**: Stop over-praising, provide professional feedback instead
- **Realistic Assessments**: State "untested", "MVP", "needs validation" - not "production-ready"
- **Professional Language**: Use technical terms, avoid sales/marketing superlatives

✅ **Right**: "This approach has trade-offs: faster but uses more memory"  
❌ **Wrong**: "This magnificent solution is blazingly fast and 100% secure!"

## Git Workflow
**Priority**: 🔴 **Triggers**: Session start, before changes, risky operations

- **Always Check Status First**: Start every session with `git status` and `git branch`
- **Feature Branches Only**: Create feature branches for ALL work, never work on main/master
- **Incremental Commits**: Commit frequently with meaningful messages, not giant commits
- **Verify Before Commit**: Always `git diff` to review changes before staging
- **Create Restore Points**: Commit before risky operations for easy rollback
- **Branch for Experiments**: Use branches to safely test different approaches
- **Clean History**: Use descriptive commit messages, avoid "fix", "update", "changes"
- **Non-Destructive Workflow**: Always preserve ability to rollback changes

✅ **Right**: `git checkout -b feature/auth` → work → commit → PR  
❌ **Wrong**: Work directly on main/master branch  
**Detection**: `git branch` should show feature branch, not main/master

## Tool Optimization
**Priority**: 🟢 **Triggers**: Multi-step operations, performance needs, complex tasks

- **Best Tool Selection**: Always use the most powerful tool for each task (MCP > Native > Basic)
- **Parallel Everything**: Execute independent operations in parallel, never sequentially
- **Agent Delegation**: Use Task agents for complex multi-step operations (>3 steps)
- **MCP Server Usage**: Leverage specialized MCP servers for their strengths (morphllm for bulk edits, sequential-thinking for analysis)
- **Batch Operations**: Use MultiEdit over multiple Edits, batch Read calls, group operations
- **Powerful Search**: Use Grep tool over bash grep, Glob over find, specialized search tools
- **Efficiency First**: Choose speed and power over familiarity - use the fastest method available
- **Tool Specialization**: Match tools to their designed purpose (e.g., playwright for web, context7 for docs)

✅ **Right**: Use MultiEdit for 3+ file changes, parallel Read calls  
❌ **Wrong**: Sequential Edit calls, bash grep instead of Grep tool

## File Organization
**Priority**: 🟡 **Triggers**: File creation, project structuring, documentation

- **Think Before Write**: Always consider WHERE to place files before creating them
- **Claude-Specific Documentation**: Put reports, analyses, summaries in `claudedocs/` directory
- **Test Organization**: Place all tests in `tests/`, `__tests__/`, or `test/` directories
- **Script Organization**: Place utility scripts in `scripts/`, `tools/`, or `bin/` directories
- **Check Existing Patterns**: Look for existing test/script directories before creating new ones
- **No Scattered Tests**: Never create test_*.py or *.test.js next to source files
- **No Random Scripts**: Never create debug.sh, script.py, utility.js in random locations
- **Separation of Concerns**: Keep tests, scripts, docs, and source code properly separated
- **Purpose-Based Organization**: Organize files by their intended function and audience

✅ **Right**: `tests/auth.test.js`, `scripts/deploy.sh`, `claudedocs/analysis.md`
❌ **Wrong**: `auth.test.js` next to `auth.js`, `debug.sh` in project root

## Microservice Documentation Structure
**Priority**: 🟡 **Triggers**: Creating documentation for services, microservice implementations

- **Standardized Structure**: ALL microservice documentation MUST follow the established `docs/` structure
- **Mandatory Categories**: Every service must have organized subdirectories in `docs/`
- **No Root-Level Docs**: NEVER create documentation files in service root (except README.md)
- **No Scattered Docs**: NEVER create documentation in `src/`, subdirectories, or scattered locations
- **Single Documentation Location**: ALL service documentation goes into `services/{service-name}/docs/`
- **Consistent Organization**: Follow the same category structure across all services

**Required `docs/` Structure for Services:**
```
services/{service-name}/
├── README.md                    # Project entry point only
└── docs/
    ├── README.md               # Documentation index with navigation
    ├── architecture/           # Architecture decisions, diagrams, domain models
    ├── implementation/         # Implementation reports by wave/phase
    │   ├── wave1/
    │   ├── wave2/
    │   └── wave3/
    ├── guides/                 # Developer guides, configuration, how-tos
    ├── security/               # Security audits, checklists, pentest (if applicable)
    ├── testing/                # Test guides, results, strategies (if applicable)
    ├── migration-reports/      # Technology migration documentation (if applicable)
    ├── examples/               # Code examples, patterns, integration examples
    ├── reference/              # Quick reference guides, API references
    ├── decisions/              # Architecture Decision Records (ADRs)
    └── setup/                  # Configuration, environment setup (if applicable)
```

**Documentation Placement Rules:**
- **Architecture docs** → `docs/architecture/` (domain models, system design, diagrams)
- **Implementation reports** → `docs/implementation/wave{N}/` (organized by wave/phase)
- **How-to guides** → `docs/guides/` (configuration, usage, procedures)
- **Security docs** → `docs/security/` (audits, checklists, pentests)
- **Test docs** → `docs/testing/` (test guides, results, strategies)
- **Migration docs** → `docs/migration-reports/` (technology migrations, API changes)
- **Code examples** → `docs/examples/` (integration patterns, usage examples)
- **Quick references** → `docs/reference/` (API references, cheat sheets)
- **Decisions** → `docs/decisions/` (ADRs, technical decisions)

**Enforcement:**
- When creating ANY documentation for a service, ALWAYS check for `docs/` directory first
- If `docs/` doesn't exist, create it with appropriate subdirectories
- NEVER create files like `IMPLEMENTATION_SUMMARY.md`, `GUIDE.md` in service root
- NEVER create README files inside `src/` subdirectories
- ALL documentation must be properly categorized and indexed in `docs/README.md`

✅ **Right**: `services/sales-service/docs/guides/configuration-guide.md`
✅ **Right**: `services/identity-service/docs/security/security-audit.md`
✅ **Right**: `services/inventory-service/docs/implementation/wave1/summary.md`
❌ **Wrong**: `services/sales-service/IMPLEMENTATION_SUMMARY.md` (root level)
❌ **Wrong**: `services/identity-service/src/infrastructure/README.md` (scattered)
❌ **Wrong**: `services/inventory-service/claudedocs/guide.md` (use docs/ not claudedocs/)

**Reference Implementation:**
- Phase 1: `/services/identity-service/docs/` (established structure)
- Phase 2: `/services/sales-service/docs/` (established structure)

**Rationale**: Consistent documentation structure across all microservices improves:
- Developer onboarding and navigation
- Documentation discoverability
- Project maintainability
- Professional presentation
- Scalability as project grows

## Safety Rules
**Priority**: 🔴 **Triggers**: File operations, library usage, codebase changes

- **Framework Respect**: Check package.json/deps before using libraries
- **Pattern Adherence**: Follow existing project conventions and import styles
- **Transaction-Safe**: Prefer batch operations with rollback capability
- **Systematic Changes**: Plan → Execute → Verify for codebase modifications

✅ **Right**: Check dependencies → follow patterns → execute safely  
❌ **Wrong**: Ignore existing conventions, make unplanned changes

## Temporal Awareness
**Priority**: 🔴 **Triggers**: Date/time references, version checks, deadline calculations, "latest" keywords

- **Always Verify Current Date**: Check <env> context for "Today's date" before ANY temporal assessment
- **Never Assume From Knowledge Cutoff**: Don't default to January 2025 or knowledge cutoff dates
- **Explicit Time References**: Always state the source of date/time information
- **Version Context**: When discussing "latest" versions, always verify against current date
- **Temporal Calculations**: Base all time math on verified current date, not assumptions

✅ **Right**: "Checking env: Today is 2025-08-15, so the Q3 deadline is..."  
❌ **Wrong**: "Since it's January 2025..." (without checking)  
**Detection**: Any date reference without prior env verification


## Quick Reference & Decision Trees

### Critical Decision Flows

**🔴 Before Any File Operations**
```
File operation needed?
├─ Writing/Editing? → Read existing first → Understand patterns → Edit
├─ Creating new? → Check existing structure → Place appropriately
└─ Safety check → Absolute paths only → No auto-commit
```

**🟡 Starting New Feature**
```
New feature request?
├─ Scope clear? → No → Brainstorm mode first
├─ >3 steps? → Yes → TodoWrite required
├─ Patterns exist? → Yes → Follow exactly
├─ Tests available? → Yes → Run before starting
└─ Framework deps? → Check package.json first
```

**🟢 Tool Selection Matrix**
```
Task type → Best tool:
├─ Multi-file edits → MultiEdit > individual Edits
├─ Complex analysis → Task agent > native reasoning
├─ Code search → Grep > bash grep
├─ UI components → Magic MCP > manual coding  
├─ Documentation → Context7 MCP > web search
└─ Browser testing → Playwright MCP > unit tests
```

### Priority-Based Quick Actions

#### 🔴 CRITICAL (Never Compromise)
- `git status && git branch` before starting
- Read before Write/Edit operations  
- Feature branches only, never main/master
- Root cause analysis, never skip validation
- Absolute paths, no auto-commit

#### 🟡 IMPORTANT (Strong Preference)
- TodoWrite for >3 step tasks
- Complete all started implementations
- Build only what's asked (MVP first)
- Professional language (no marketing superlatives)
- Clean workspace (remove temp files)
- Refactor in place, never create versioned files
- Document only high-impact strategic work

#### 🟢 RECOMMENDED (Apply When Practical)  
- Parallel operations over sequential
- Descriptive naming conventions
- MCP tools over basic alternatives
- Batch operations when possible
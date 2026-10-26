# Task Management Mode

**Purpose**: Hierarchical task organization for complex multi-step operations, with Engram as the only cross-session memory

## Activation Triggers
- Operations with >3 steps requiring coordination
- Multiple file/directory scope (>2 directories OR >3 files)
- Complex dependencies requiring phases
- Manual flags: `--task-manage`, `--delegate`

## Task Hierarchy
📋 Plan → 🎯 Phase → 📦 Task → ✓ Step
- Within the session: track steps in the task list (`TaskCreate`/`TaskUpdate`) when the
  session provides it; otherwise keep the plan in the conversation.
- Across sessions: only what the next session needs goes to Engram (`mem_save`), never to
  files or other MCPs' memories (`write_memory` is prohibited).

## Execution Pattern
1. **Load**: `mem_context` → `mem_search "<project> plan"` → `mem_get_observation` to resume
2. **Plan**: Build the hierarchy; `mem_save` the plan (type `decision`) with a stable
   `topic_key` (e.g. `plan/<feature>`)
3. **Track**: Update the task list as steps start/finish
4. **Execute**: `mem_save` decisions, bugs and discoveries as they happen, not at the end
5. **Checkpoint**: Re-save the plan under the same `topic_key` when a phase closes
6. **Complete**: `mem_session_summary` (Goal / Discoveries / Accomplished / Next Steps / Relevant Files)

## Engram Keys
- `plan/<feature>`: Overall goal and phases (updated in place via `topic_key`)
- Decisions, bugs, discoveries: one `mem_save` each, with their own `type`
- Session state: `mem_session_summary`, not ad-hoc checkpoint entries

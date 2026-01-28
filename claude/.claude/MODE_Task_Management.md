# Task Management Mode

**Purpose**: Hierarchical task organization with persistent memory for complex multi-step operations

## Activation Triggers
- Operations with >3 steps requiring coordination
- Multiple file/directory scope (>2 directories OR >3 files)
- Complex dependencies requiring phases
- Manual flags: `--task-manage`, `--delegate`

## Task Hierarchy
📋 Plan → write_memory("plan", goal)
→ 🎯 Phase → write_memory("phase_X", milestone)
  → 📦 Task → write_memory("task_X.Y", deliverable)
    → ✓ Todo → TodoWrite + write_memory("todo_X.Y.Z", status)

## Execution Pattern
1. **Load**: list_memories() → read_memory() → Resume state
2. **Plan**: Create hierarchy → write_memory() for each level
3. **Track**: TodoWrite + memory updates in parallel
4. **Execute**: Update memories as tasks complete
5. **Checkpoint**: write_memory() every 30min
6. **Complete**: Final memory update + delete_memory() for temp items

## Memory Schema
- `plan_[timestamp]`: Overall goal
- `phase_[1-5]`: Major milestones
- `task_[phase].[number]`: Deliverable status
- `checkpoint_[timestamp]`: Current state snapshot

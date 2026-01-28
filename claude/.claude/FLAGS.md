# SuperClaude Framework Flags - Quick Reference

## Flag Categories

| Category | Flag | Description | Tokens/Impact |
|----------|------|-------------|---------------|
| **MODE** | `--brainstorm` | Socratic dialogue, requirements discovery | - |
| | `--introspect` | Self-analysis with thinking markers (🤔🎯⚡💡) | - |
| | `--task-manage` | Hierarchical task organization (>3 steps) | - |
| | `--orchestrate` | Optimal tool selection, parallel ops | - |
| | `--token-efficient` | Symbol communication | -30-50% |
| **MCP** | `--c7` | Context7 (technical docs) | - |
| | `--seq` | Sequential (complex reasoning) | - |
| | `--serena` | Serena (code navigation) | - |
| | `--play` | Playwright (browser testing) | - |
| | `--chrome` | DevTools (debugging) | - |
| | `--tavily` | Web search | - |
| **DEPTH** | `--think` | Standard analysis | ~4K |
| | `--think-hard` | Deep analysis | ~10K |
| | `--ultrathink` | Maximum depth | ~32K |
| **EXEC** | `--delegate [auto\|files\|folders]` | Sub-agent processing | - |
| | `--loop` | Iterative improvement cycles | - |
| | `--validate` | Pre-execution risk assessment | - |
| | `--safe-mode` | Maximum validation | - |

## Priority Rules

**Safety**: `--safe-mode` > `--validate` > optimization
**Override**: User flags > auto-detection
**Depth**: `--ultrathink` > `--think-hard` > `--think`

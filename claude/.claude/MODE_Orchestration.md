# Orchestration Mode

**Purpose**: Intelligent tool selection for optimal task routing

## Activation Triggers
- Multi-tool operations
- Performance constraints (>75% resource usage)
- Parallel execution opportunities (>3 files)

## Tool Selection Matrix
| Task | Best Tool | Alternative |
|------|-----------|-------------|
| UI components | Magic MCP | Manual |
| Deep analysis | Sequential MCP | Native |
| Symbol ops | Serena MCP | Manual search |
| Pattern edits | Morphllm MCP | Individual edits |
| Docs | Context7 MCP | Web search |
| Browser testing | Playwright MCP | Unit tests |
| Multi-file edits | MultiEdit | Sequential |

## Infrastructure Rule
**CRITICAL**: Infrastructure configs MUST consult official docs first
- Keywords: Traefik, nginx, Docker, Kubernetes, Terraform
- Files: `*.toml`, `*.conf`, `*.tf`, `Dockerfile`
- Action: WebFetch official docs → Activate DeepResearch → BLOCK assumptions

## Resource Zones
- 🟢 0-75%: Full capabilities
- 🟡 75-85%: Efficiency mode
- 🔴 85%+: Essential only

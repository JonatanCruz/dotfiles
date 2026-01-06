# OpenCode Configuration

OpenCode configuration managed with GNU Stow.

## Theme

- **Catppuccin Mocha**: Matches your terminal and editor theme

## MCP Servers

### Context7
**Type**: Remote  
**Usage**: Search through documentation  
**Example**:
```
Configure a Cloudflare Worker to cache JSON responses. use context7
```

### Sentry
**Type**: Remote (OAuth)  
**Usage**: Query Sentry projects and issues  
**Setup**: Run `opencode mcp auth sentry` to authenticate  
**Example**:
```
Show me the latest unresolved issues in my project. use sentry
```

### Playwright
**Type**: Local  
**Usage**: Browser automation and testing  
**Example**:
```
Create a Playwright test to verify login flow. use playwright
```

## Permissions

Auto-approved operations:
- ✅ File operations (read, write, edit)
- ✅ Bash commands (except `rm -rf *`, `sudo *`)
- ✅ Search operations (glob, grep)
- ✅ Web fetch
- ✅ Task management

Require confirmation:
- ⚠️ `rm -rf *` (destructive deletions)
- ⚠️ `sudo *` (privileged commands)
- ⚠️ External directory access
- ⚠️ Doom loop detection

Blocked:
- 🚫 `.env` files (except `.env.example`)

## Installation

From your dotfiles directory:

```bash
stow opencode
```

## MCP Management

List all MCP servers:
```bash
opencode mcp list
```

Authenticate with OAuth MCP:
```bash
opencode mcp auth sentry
```

Debug MCP connection:
```bash
opencode mcp debug <server-name>
```

## SuperClaude

SuperClaude framework is automatically loaded from `~/.claude/CLAUDE.md`.

Available modes:
- Business Panel
- DeepResearch
- Task Management
- Code Quality Perfection Protocol
- Async Swarm Execution

## Agents

Switch agents with **Tab** key.

Built-in agents:
- **Build**: Full development (default)
- **Plan**: Analysis without changes
- **General**: Research and multi-step tasks
- **Explore**: Fast codebase exploration

Create custom agents:
```bash
opencode agent create
```

## Integration with dotfiles

All configuration is tracked in Git and managed with Stow:
```
~/dotfiles/opencode/.config/opencode/
└── opencode.json → symlinked to ~/.config/opencode/opencode.json
```

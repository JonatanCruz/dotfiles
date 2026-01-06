# OpenCode Configuration Guide

Complete guide for OpenCode configuration in dotfiles.

## Overview

OpenCode is configured through `opencode/.config/opencode/opencode.json` and managed with GNU Stow. This setup includes theme configuration, MCP servers, and permission management.

## Theme Configuration

### Catppuccin Mocha

OpenCode is configured to use the **Catppuccin Mocha** theme, matching the terminal and editor setup.

```json
{
  "theme": "catppuccin"
}
```

**Available built-in themes:**
- `catppuccin` - Catppuccin Mocha (current)
- `catppuccin-macchiato` - Catppuccin Macchiato variant
- `tokyonight` - Tokyo Night theme
- `everforest` - Everforest theme
- `gruvbox` - Gruvbox theme
- `nord` - Nord theme
- `system` - Adapts to terminal colors

**Change theme:**
```bash
# Interactive theme selector
opencode
/theme

# Or edit opencode.json directly
```

## MCP Servers

### Context7

**Type:** Remote  
**Purpose:** Search through documentation for various frameworks and libraries

**Configuration:**
```json
{
  "context7": {
    "type": "remote",
    "url": "https://mcp.context7.com/mcp",
    "enabled": true
  }
}
```

**Usage examples:**
```
Configure a Cloudflare Worker to cache JSON responses for five minutes. use context7

What's the best way to handle authentication in Next.js? use context7

How do I optimize React components for performance? use context7
```

**Features:**
- Searches across multiple documentation sources
- Free tier available (rate-limited)
- Optional API key for higher limits

**Get API key (optional):**
1. Sign up at [context7.com](https://context7.com)
2. Add to environment: `export CONTEXT7_API_KEY=your_key`
3. Update config:
```json
{
  "context7": {
    "type": "remote",
    "url": "https://mcp.context7.com/mcp",
    "headers": {
      "CONTEXT7_API_KEY": "{env:CONTEXT7_API_KEY}"
    }
  }
}
```

---

### Serena

**Type:** Local  
**Purpose:** Advanced AI coding agent with symbolic tools for code analysis and refactoring

**Configuration:**
```json
{
  "serena": {
    "type": "local",
    "command": ["uvx", "--from", "git+https://github.com/oraios/serena", "serena", "start-mcp-server", "--context", "ide", "--project-from-cwd"],
    "enabled": true
  }
}
```

**Initial Setup:**

Serena will automatically download on first use via `uvx`. No additional installation needed.

**Usage examples:**
```
Use Serena to analyze the code structure in src/

Help me refactor this class using Serena's symbolic tools. use serena

Find all usages of this function across the codebase. use serena

Show me the call hierarchy for this method. use serena
```

**Features:**
- Symbolic code analysis and navigation
- Intelligent refactoring suggestions
- Cross-file code understanding
- Language server protocol integration
- Works with multiple programming languages

**Context Configuration:**

Serena uses `--context ide` which:
- Reduces tool duplication with OpenCode's built-in tools
- Optimizes for IDE-like workflows
- Provides symbolic operations for code intelligence

**Project Activation:**

The `--project-from-cwd` flag automatically:
- Searches up from current directory for `.serena/project.yml` or `.git`
- Activates current directory as project if neither found
- Works seamlessly across different projects

**Troubleshooting:**
```bash
# Check if Serena is loaded
opencode mcp list

# Debug connection issues
opencode mcp debug serena

# Check logs
tail -f ~/.local/share/opencode/logs/mcp.log
```

**More Information:**
- [Serena Documentation](https://oraios.github.io/serena/)
- [GitHub Repository](https://github.com/oraios/serena)

---

### Playwright

**Type:** Local  
**Purpose:** Browser automation and end-to-end testing

**Configuration:**
```json
{
  "playwright": {
    "type": "local",
    "command": ["npx", "-y", "@executeautomation/playwright-mcp-server"],
    "enabled": true
  }
}
```

**First-time setup:**

The MCP server will be automatically downloaded via `npx` on first use.

For better performance, install globally:
```bash
npm install -g @executeautomation/playwright-mcp-server
```

**Usage examples:**
```
Create a Playwright test to verify login flow. use playwright

Write a test that checks the shopping cart functionality. use playwright

Generate a test to verify form validation. use playwright

Help me debug this flaky test in tests/auth.spec.ts. use playwright
```

**Features:**
- Generate test scripts
- Browser automation helpers
- Page object patterns
- Test debugging assistance

---

## Permissions

### Auto-Approved Operations

These operations run without asking for confirmation:

- ✅ **File operations**: read, write, edit
- ✅ **Bash commands**: Most shell commands
- ✅ **Search operations**: glob, grep, list
- ✅ **Web fetch**: HTTP requests
- ✅ **Task management**: todo operations
- ✅ **Subagents**: Task delegation

### Require Confirmation

These operations will prompt for approval:

- ⚠️ **`rm -rf *`**: Recursive force deletions
- ⚠️ **`sudo *`**: Privileged commands
- ⚠️ **External directory access**: Operations outside project
- ⚠️ **Doom loop**: Repeated identical operations

### Blocked Operations

These are always denied:

- 🚫 **`.env` files**: Reading environment files (except `.env.example`)
- 🚫 **`.env.*` files**: Environment variants

### Permission Configuration

Located in `opencode/.config/opencode/opencode.json`:

```json
{
  "permission": {
    "*": "allow",
    "bash": {
      "*": "allow",
      "rm -rf *": "ask",
      "sudo *": "ask"
    },
    "read": {
      "*": "allow",
      "*.env": "deny",
      "*.env.*": "deny",
      "*.env.example": "allow"
    }
  }
}
```

**Permission values:**
- `"allow"` - Run without approval
- `"ask"` - Prompt for confirmation
- `"deny"` - Always block

### Custom Permissions

Add custom rules for specific commands:

```json
{
  "permission": {
    "bash": {
      "*": "allow",
      "git push --force": "ask",
      "npm publish": "ask",
      "docker rm *": "ask"
    }
  }
}
```

---

## Agents

### Built-in Agents

**Primary Agents** (switch with **Tab** key):

1. **Build** (default)
   - Full development mode
   - All tools enabled
   - Make changes and run commands

2. **Plan**
   - Analysis mode
   - Read-only operations
   - Suggests changes without modifying code

**Subagents** (invoked automatically or with `@mention`):

3. **General**
   - Research and multi-step tasks
   - Code search and exploration
   - Complex question answering

4. **Explore**
   - Fast codebase exploration
   - Pattern-based file search
   - Quick code queries

### Using Agents

**Switch primary agent:**
```
<Tab>  # Cycles between Build and Plan
```

**Invoke subagent:**
```
@general help me search for authentication logic across the codebase

@explore find all API endpoint definitions
```

### Creating Custom Agents

**Interactive creation:**
```bash
opencode agent create
```

**Manual creation:**

Global agent: `~/.config/opencode/agent/my-agent.md`
Project agent: `.opencode/agent/my-agent.md`

Example agent:
```markdown
---
description: Reviews code for security vulnerabilities
mode: subagent
temperature: 0.1
tools:
  write: false
  edit: false
  bash: false
---

You are a security expert. Focus on identifying:
- Input validation vulnerabilities
- Authentication/authorization flaws
- Data exposure risks
- Dependency vulnerabilities

Provide detailed explanations and remediation steps.
```

**Configure via JSON:**
```json
{
  "agent": {
    "security-reviewer": {
      "description": "Security vulnerability analysis",
      "mode": "subagent",
      "model": "anthropic/claude-sonnet-4-20250514",
      "temperature": 0.1,
      "tools": {
        "write": false,
        "edit": false
      }
    }
  }
}
```

---

## SuperClaude Integration

SuperClaude framework is automatically loaded from `~/.claude/CLAUDE.md`.

### Available Modes

Invoke modes with natural language:

```
Activate DeepResearch mode to investigate authentication patterns

Use Business Panel to analyze the pricing strategy

Execute Code Quality Perfection Protocol on the API services
```

**Active modes:**
- **Business Panel**: Multi-perspective business analysis
- **DeepResearch**: Deep technical investigation
- **Task Management**: Complex task orchestration
- **Code Quality Perfection Protocol**: Enterprise-grade quality standards
- **Async Swarm Execution**: Parallel agent execution

### SuperClaude Configuration

Located at `~/.claude/CLAUDE.md`, this file imports:

- Core framework principles
- Behavioral modes
- Code quality protocols
- Business analysis tools

**No additional setup required** - OpenCode automatically loads this configuration on startup.

---

## MCP Management Commands

### List MCP Servers

```bash
# Show all configured MCP servers and status
opencode mcp list
```

Output shows:
- Server name
- Type (local/remote)
- Status (enabled/disabled)
- Available tools count

### Debug MCP Connection

```bash
# Test MCP server connection
opencode mcp debug serena
opencode mcp debug context7

# Shows:
# - Server connectivity
# - Available tools
# - Configuration status
```

**MCP Server Logs:**
- Location: `~/.local/share/opencode/logs/mcp.log`
- Contains startup and runtime information
- Useful for debugging connection issues

---

## Installation & Management

### Apply Configuration

```bash
cd ~/dotfiles
stow opencode
```

This creates symlink:
```
~/.config/opencode/opencode.json → ~/dotfiles/opencode/.config/opencode/opencode.json
```

### Update Configuration

1. Edit `~/dotfiles/opencode/.config/opencode/opencode.json`
2. Changes take effect immediately (symlinked)
3. Restart OpenCode to reload MCP servers

### Remove Configuration

```bash
cd ~/dotfiles
stow -D opencode
```

### Sync to Another System

```bash
# On new system
cd ~/dotfiles
git pull
stow opencode

# Verify MCP servers are loaded
opencode mcp list
```

---

## Advanced Configuration

### Per-Agent MCP Control

Enable MCPs only for specific agents:

```json
{
  "mcp": {
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp",
      "enabled": true
    }
  },
  "tools": {
    "context7_*": false
  },
  "agent": {
    "docs-writer": {
      "tools": {
        "context7_*": true
      }
    }
  }
}
```

### Custom MCP Timeouts

```json
{
  "mcp": {
    "slow-mcp": {
      "type": "remote",
      "url": "https://example.com/mcp",
      "timeout": 10000
    }
  }
}
```

### Environment Variables

```json
{
  "mcp": {
    "custom-mcp": {
      "type": "local",
      "command": ["node", "server.js"],
      "environment": {
        "API_KEY": "{env:MY_API_KEY}",
        "DEBUG": "true"
      }
    }
  }
}
```

---

## Troubleshooting

### MCP Server Not Loading

```bash
# Check MCP status
opencode mcp list

# Debug specific server
opencode mcp debug playwright

# Check logs
tail -f ~/.local/share/opencode/logs/mcp.log
```

### MCP Server Not Responding

```bash
# Check server status
opencode mcp list

# Debug specific server
opencode mcp debug serena

# Check logs
tail -f ~/.local/share/opencode/logs/mcp.log
```

### Theme Not Applying

1. Verify config:
```bash
cat ~/.config/opencode/opencode.json | grep theme
```

2. Check terminal truecolor support:
```bash
echo $COLORTERM  # Should show "truecolor" or "24bit"
```

3. Set truecolor manually:
```bash
export COLORTERM=truecolor
```

### Permission Denied Errors

Check permission configuration:
```bash
cat ~/.config/opencode/opencode.json | grep -A 10 permission
```

Temporarily allow all:
```json
{
  "permission": "allow"
}
```

---

## Best Practices

### MCP Usage

1. **Be specific with prompts**: Mention the MCP tool explicitly
   - ✅ `How do I use React hooks? use context7`
   - ❌ `How do I use React hooks?`

2. **Context7**: Best for documentation searches
3. **Serena**: Best for code analysis, refactoring, and symbolic operations
4. **Playwright**: Best for test generation and browser automation

### Agent Usage

1. **Build mode**: Default for making changes
2. **Plan mode**: Review changes before applying
3. **Switch modes**: Use Tab to switch between Build/Plan
4. **Subagents**: Let OpenCode invoke automatically, or use `@mention`

### Permission Management

1. **Start restrictive**: Use `"ask"` for new operations
2. **Refine over time**: Switch to `"allow"` for trusted operations
3. **Never allow**: Keep destructive operations as `"ask"`

### Git Workflow

1. **Commit opencode.json**: Track configuration changes
2. **Document changes**: Explain MCP additions in commits
3. **Sync regularly**: Pull config updates on other systems
4. **Test after pull**: Verify MCPs work after sync

---

## Related Documentation

- [Architecture](../ARCHITECTURE.md) - Overall dotfiles structure
- [Installation](../INSTALL.md) - Initial setup guide
- [Stow Guide](./stow-usage.md) - GNU Stow reference
- [Development](../development/) - Development workflows

---

## External Resources

- [OpenCode Documentation](https://opencode.ai/docs/)
- [MCP Specification](https://modelcontextprotocol.io/)
- [Context7 Docs](https://context7.com/docs)
- [Serena Documentation](https://oraios.github.io/serena/)
- [Serena GitHub](https://github.com/oraios/serena)
- [Playwright MCP](https://github.com/executeautomation/playwright-mcp-server)

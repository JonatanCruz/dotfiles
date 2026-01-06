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

### Sentry

**Type:** Remote (OAuth)  
**Purpose:** Query Sentry projects, issues, and error tracking

**Configuration:**
```json
{
  "sentry": {
    "type": "remote",
    "url": "https://mcp.sentry.dev/mcp",
    "enabled": true,
    "oauth": {}
  }
}
```

**Initial Setup:**
```bash
# Authenticate with Sentry
opencode mcp auth sentry

# This will:
# 1. Open browser for OAuth authorization
# 2. Store tokens in ~/.local/share/opencode/mcp-auth.json
# 3. Enable access to your Sentry projects
```

**Usage examples:**
```
Show me the latest unresolved issues in my project. use sentry

What are the top errors from the last 24 hours? use sentry

Get details about issue PROJ-123. use sentry

List all projects in my Sentry organization. use sentry
```

**Features:**
- Query issues and events
- Filter by project, environment, status
- View stack traces and error details
- Monitor error trends

**Troubleshooting:**
```bash
# Check authentication status
opencode mcp list

# Re-authenticate if needed
opencode mcp auth sentry

# Debug connection issues
opencode mcp debug sentry

# Logout (clear credentials)
opencode mcp logout sentry
```

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
- Authentication status (for OAuth servers)

### Authenticate OAuth MCPs

```bash
# Authenticate with Sentry
opencode mcp auth sentry

# Check auth status
opencode mcp auth list
```

### Debug MCP Connection

```bash
# Test connection and OAuth flow
opencode mcp debug sentry

# Shows:
# - HTTP connectivity
# - OAuth discovery
# - Token status
# - Available tools
```

### Manage Credentials

```bash
# Remove stored credentials
opencode mcp logout sentry

# Re-authenticate
opencode mcp auth sentry
```

**Credential storage:**
- Location: `~/.local/share/opencode/mcp-auth.json`
- Encrypted: Yes (platform keychain)
- Per-server: Separate tokens for each MCP

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

# Authenticate OAuth MCPs
opencode mcp auth sentry
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

### OAuth Authentication Fails

```bash
# Clear credentials and retry
opencode mcp logout sentry
opencode mcp auth sentry

# Check OAuth configuration
opencode mcp debug sentry
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
3. **Sentry**: Best for error analysis and debugging
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
- [Sentry MCP](https://mcp.sentry.dev/)
- [Playwright MCP](https://github.com/executeautomation/playwright-mcp-server)

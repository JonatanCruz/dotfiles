# OpenCode Configuration

OpenCode AI coding agent configuration managed with GNU Stow.

## Quick Reference

- **Theme**: Catppuccin Mocha
- **MCP Servers**: Context7, Serena, Playwright
- **Permissions**: Auto-approved with safety guards
- **SuperClaude**: Enabled via `~/.claude/CLAUDE.md`

## Installation

```bash
stow opencode
```

## Configuration Files

```
opencode/
└── .config/opencode/
    └── opencode.json
```

## Documentation

For complete documentation, see:

📖 **[OpenCode Guide](../docs/guides/opencode.md)**

Includes:
- Theme configuration
- MCP server setup and usage
- Permission management
- Agent configuration
- SuperClaude integration
- Troubleshooting

## Quick Commands

```bash
# List MCP servers
opencode mcp list

# Verify MCP servers
opencode mcp list

# Create custom agent
opencode agent create

# Switch theme
opencode
/theme
```

## Structure

```
~/.config/opencode/opencode.json → ~/dotfiles/opencode/.config/opencode/opencode.json
```

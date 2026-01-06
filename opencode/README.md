# OpenCode Configuration

OpenCode AI coding agent configuration managed with GNU Stow.

## Quick Reference

- **Theme**: Catppuccin Mocha with optimized TUI
- **Models**: Claude Sonnet 4.5 (main) + Haiku 4.5 (small tasks)
- **Agents**: Build, Plan, Review with specialized configs
- **MCP Servers**: Context7, Serena, Playwright
- **Formatters**: Prettier, Biome, Ruff, rustfmt, gofmt
- **LSP**: TypeScript, Python, Rust, Go, ESLint
- **Permissions**: Granular security with sensitive file protection
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

Complete configuration guide including:
- Professional configuration features
- Models and providers setup
- Agent system (Build, Plan, Review)
- MCP server setup (Context7, Serena, Playwright)
- Code formatters (Prettier, Ruff, rustfmt, gofmt)
- LSP integration
- Security permissions
- Custom commands
- SuperClaude integration
- Troubleshooting

🎯 **[Best Practices & Recommendations](../docs/guides/opencode-best-practices.md)**

Professional guidelines for production use:
- Configuration management strategies
- Model selection and optimization
- Agent usage patterns
- Security best practices
- Performance optimization
- Workflow optimization
- Team collaboration
- Monitoring and maintenance

## Quick Commands

```bash
# List MCP servers
opencode mcp list

# Use custom commands
/implement user authentication feature
/analyze src/components --focus security
/refactor src/utils/helpers.ts

# Invoke custom agents
@backend-architect design REST API for orders
@security-engineer audit authentication code

# Switch theme
opencode
/theme
```

## Custom Agents & Commands

See [AGENTS_COMMANDS.md](./AGENTS_COMMANDS.md) for details on:
- **Backend Architect**: Backend systems design
- **Security Engineer**: Security audits and compliance
- **/implement**: Feature implementation
- **/analyze**: Multi-domain code analysis
- **/refactor**: Intelligent refactoring

## Structure

```
~/.config/opencode/opencode.json → ~/dotfiles/opencode/.config/opencode/opencode.json
```

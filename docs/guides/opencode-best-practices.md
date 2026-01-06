# OpenCode Best Practices & Community Recommendations

Professional guidelines for using OpenCode effectively in production environments.

## Table of Contents

- [Configuration Management](#configuration-management)
- [Model Selection](#model-selection)
- [Agent Usage](#agent-usage)
- [Security Practices](#security-practices)
- [Performance Optimization](#performance-optimization)
- [MCP Server Management](#mcp-server-management)
- [Code Quality](#code-quality)
- [Workflow Optimization](#workflow-optimization)

---

## Configuration Management

### Layered Configuration

Use configuration layering for different environments:

```
~/.config/opencode/opencode.json     # Global defaults
~/project/.opencode/opencode.json    # Project-specific
OPENCODE_CONFIG=./custom.json        # Temporary overrides
```

**Best Practice**: Keep global config minimal, project configs specific.

### Version Control

**DO** commit to Git:
- Project-specific configurations (`.opencode/opencode.json`)
- Custom agents and commands
- Project instructions (`AGENTS.md`)

**DON'T** commit:
- API keys (use `{env:VAR}` instead)
- Personal preferences (theme, keybinds)
- Cached data

### Configuration Organization

Group related settings with comments:

```json
{
  // ============================================================================
  // MODELS & PROVIDERS
  // ============================================================================
  "model": "anthropic/claude-sonnet-4-5",
  "small_model": "anthropic/claude-haiku-4-5"
}
```

This improves maintainability and team collaboration.

---

## Model Selection

### Primary vs Small Models

**Primary Model** (`model`):
- Use: Complex reasoning, code generation, refactoring
- Recommended: Claude Sonnet 4.5, GPT-4o
- Cost: Higher per token
- Speed: Slower

**Small Model** (`small_model`):
- Use: Title generation, simple queries, quick tasks
- Recommended: Claude Haiku 4.5, GPT-4o-mini
- Cost: Much lower
- Speed: Faster

### Temperature Settings

| Task Type | Temperature | Use Case |
|-----------|-------------|----------|
| **Code Generation** | 0.2-0.3 | Consistent, predictable output |
| **Analysis & Review** | 0.1 | Deterministic, focused |
| **Planning** | 0.1 | Clear, structured thinking |
| **Refactoring** | 0.2 | Balanced creativity |
| **Brainstorming** | 0.5-0.7 | More creative solutions |

### Timeout Configuration

```json
{
  "provider": {
    "anthropic": {
      "options": {
        "timeout": 600000  // 10 minutes for complex operations
      }
    }
  }
}
```

**Guidelines**:
- Default: 300s (5 minutes) - adequate for most tasks
- Large codebases: 600s (10 minutes)
- Simple queries: 60s (1 minute) - set per agent

### Cache Keys

```json
{
  "provider": {
    "anthropic": {
      "options": {
        "setCacheKey": true  // Reduce costs with prompt caching
      }
    }
  }
}
```

**Benefits**:
- Reuses similar prompts
- Reduces API costs
- Faster response times

---

## Agent Usage

### Agent Modes

| Agent | Mode | Use When |
|-------|------|----------|
| **Build** | Primary | Making code changes, implementing features |
| **Plan** | Primary | Analyzing code, reviewing changes before implementing |
| **Review** | Subagent | Code review without modifications |
| **Explore** | Subagent | Fast codebase exploration |
| **General** | Subagent | Complex research, multi-step tasks |

### Build Agent Best Practices

```json
{
  "agent": {
    "build": {
      "temperature": 0.3,
      "description": "Full development mode with all tools enabled"
    }
  }
}
```

**Use for**:
- Implementing new features
- Bug fixes
- Refactoring
- Adding tests

**Tips**:
- Start with `/plan` to review approach
- Use `Tab` to switch to Plan mode for review
- Leverage custom commands (`/test`, `/review`)

### Plan Agent Best Practices

```json
{
  "agent": {
    "plan": {
      "temperature": 0.1,
      "permission": {
        "edit": "deny",
        "write": "deny",
        "bash": {
          "*": "ask",
          "git status": "allow",
          "git diff": "allow"
        }
      }
    }
  }
}
```

**Use for**:
- Reviewing proposed changes
- Analyzing code structure
- Planning implementation strategy
- Understanding codebase

**Tips**:
- Use before making major changes
- Review plan, then switch to Build mode
- Prevents accidental modifications

### Custom Agents

Create specialized agents for repetitive tasks:

**Example: Documentation Agent**

```json
{
  "agent": {
    "docs": {
      "description": "Technical documentation writer",
      "mode": "subagent",
      "temperature": 0.2,
      "tools": {
        "bash": false
      }
    }
  }
}
```

**Example: Security Auditor**

```json
{
  "agent": {
    "security": {
      "description": "Security vulnerability scanner",
      "mode": "subagent",
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

## Security Practices

### Permission Principles

1. **Principle of Least Privilege**: Start restrictive, open up as needed
2. **Explicit Approval**: Dangerous operations should always ask
3. **Defense in Depth**: Multiple layers of protection

### Essential Blocked Operations

```json
{
  "permission": {
    "bash": {
      "rm -rf *": "ask",
      "rm -r *": "ask",
      "sudo *": "ask",
      "git push --force": "ask",
      "git push -f": "ask",
      "npm publish": "ask",
      "docker rm *": "ask",
      "docker rmi *": "ask",
      "kubectl delete *": "ask"
    }
  }
}
```

### Sensitive File Protection

```json
{
  "permission": {
    "read": {
      "*.env": "deny",
      "*.env.*": "deny",
      "*.env.local": "deny",
      "*.env.production": "deny",
      ".env": "deny",
      "*.key": "deny",
      "*.pem": "deny",
      "id_rsa": "deny",
      "*.p12": "deny",
      "*.pfx": "deny",
      "secrets.json": "deny",
      "credentials.json": "deny",
      "*.env.example": "allow"
    }
  }
}
```

### API Keys Management

**NEVER** hardcode API keys:

❌ **Bad**:
```json
{
  "provider": {
    "openai": {
      "options": {
        "apiKey": "sk-proj-abc123..."
      }
    }
  }
}
```

✅ **Good**:
```json
{
  "provider": {
    "openai": {
      "options": {
        "apiKey": "{env:OPENAI_API_KEY}"
      }
    }
  }
}
```

Or use separate file:
```json
{
  "provider": {
    "openai": {
      "options": {
        "apiKey": "{file:~/.secrets/openai-key}"
      }
    }
  }
}
```

### External Directory Protection

```json
{
  "permission": {
    "external_directory": "ask"
  }
}
```

Always prompt before accessing files outside project directory.

---

## Performance Optimization

### Context Management

```json
{
  "compaction": {
    "auto": true,   // Auto-compact when context full
    "prune": true   // Remove old tool outputs
  }
}
```

**Benefits**:
- Prevents context overflow
- Reduces API costs
- Maintains conversation quality

### File Watcher Optimization

```json
{
  "watcher": {
    "ignore": [
      "node_modules/**",
      "dist/**",
      "build/**",
      ".git/**",
      ".next/**",
      "__pycache__/**",
      "target/**",
      "*.log"
    ]
  }
}
```

**Best Practices**:
- Exclude build artifacts
- Exclude dependencies
- Exclude temporary files
- Include only source code

### MCP Server Timeouts

```json
{
  "mcp": {
    "serena": {
      "timeout": 10000  // 10 seconds
    },
    "context7": {
      "timeout": 10000
    }
  }
}
```

**Guidelines**:
- Default: 5 seconds
- Slow servers: 10-15 seconds
- Fast servers: 5 seconds or less

### LSP Performance

Disable unused LSP servers:

```json
{
  "lsp": {
    "typescript": true,
    "python": true,
    "java": {
      "disabled": true  // Disable if not using Java
    }
  }
}
```

---

## MCP Server Management

### Server Selection

Choose MCP servers that complement OpenCode's built-in tools:

| MCP Server | Use Case | Complements |
|------------|----------|-------------|
| **Serena** | Symbolic code analysis | Built-in grep/search |
| **Context7** | Documentation search | Built-in webfetch |
| **Playwright** | Browser testing | Built-in bash |
| **GitHub** | Repository operations | Built-in git commands |

### Per-Agent MCP Control

```json
{
  "tools": {
    "context7_*": false  // Disable globally
  },
  "agent": {
    "docs-writer": {
      "tools": {
        "context7_*": true  // Enable for docs agent only
      }
    }
  }
}
```

**Benefits**:
- Reduces token usage
- Faster responses
- Cleaner tool lists

### MCP Best Practices

1. **Timeout Configuration**: Set appropriate timeouts per server
2. **Selective Enabling**: Only enable MCPs you actively use
3. **Context Specification**: Use appropriate `--context` flags (e.g., Serena with `ide`)
4. **Monitoring**: Check `opencode mcp list` regularly
5. **Updates**: Keep MCP servers updated

---

## Code Quality

### Formatter Configuration

```json
{
  "formatter": {
    "prettier": {
      "command": ["npx", "prettier", "--write", "$FILE"],
      "extensions": [".js", ".ts", ".jsx", ".tsx", ".json", ".md"]
    },
    "ruff": {
      "command": ["ruff", "format", "$FILE"],
      "extensions": [".py"]
    }
  }
}
```

**Best Practices**:
- Configure formatters per project
- Use project's existing formatter
- Match team's code style
- Auto-format on save

### LSP Integration

```json
{
  "lsp": {
    "typescript": {
      "extensions": [".ts", ".tsx", ".js", ".jsx"]
    },
    "eslint": {
      "extensions": [".ts", ".tsx", ".js", ".jsx", ".vue"]
    }
  }
}
```

**Benefits**:
- Real-time diagnostics
- Better code intelligence
- Fewer errors in generated code
- Consistent with IDE experience

### Custom Commands for Quality

```json
{
  "command": {
    "lint": {
      "template": "Run linting on $ARGUMENTS and fix all issues",
      "description": "Lint and fix code"
    },
    "typecheck": {
      "template": "Run type checking and fix all type errors",
      "description": "Type check code"
    },
    "format": {
      "template": "Format all files in $ARGUMENTS using project formatters",
      "description": "Format code"
    }
  }
}
```

---

## Workflow Optimization

### Custom Commands Library

Create commands for common workflows:

```json
{
  "command": {
    "test": {
      "template": "Run full test suite with coverage. Show failures and suggest fixes.",
      "description": "Run tests with coverage",
      "agent": "build"
    },
    "review": {
      "template": "Review changes. Focus on:\n- Code quality\n- Security\n- Performance\n- Best practices",
      "description": "Code review",
      "agent": "review"
    },
    "refactor": {
      "template": "Refactor $ARGUMENTS:\n- Improve readability\n- Extract functions\n- Remove duplication\n- Add types",
      "description": "Refactor code"
    },
    "debug": {
      "template": "Debug $ARGUMENTS:\n- Analyze error\n- Find root cause\n- Suggest fix\n- Add logging",
      "description": "Debug issue"
    }
  }
}
```

### Instructions Files

Create project-specific instructions:

**AGENTS.md**:
```markdown
# Project Guidelines

## Architecture
- Use clean architecture with layers
- Follow repository pattern
- Dependency injection via constructor

## Testing
- Unit tests required for services
- Integration tests for APIs
- E2E tests for critical flows

## Code Style
- Use TypeScript strict mode
- Prefer functional programming
- Document complex logic
```

Reference in config:
```json
{
  "instructions": ["AGENTS.md", "CONTRIBUTING.md"]
}
```

### Keyboard Efficiency

Use keybinds for common actions:

```json
{
  "keybinds": {
    "ctrl+t": {
      "command": "test"
    },
    "ctrl+r": {
      "command": "review"
    }
  }
}
```

### Model Switching

Configure multiple models for different tasks:

```json
{
  "agent": {
    "fast": {
      "model": "anthropic/claude-haiku-4-5",
      "description": "Fast agent for simple tasks"
    },
    "powerful": {
      "model": "anthropic/claude-opus-4-5",
      "description": "Powerful agent for complex tasks"
    }
  }
}
```

---

## Monitoring & Maintenance

### Regular Checks

**Weekly**:
- Review MCP server status: `opencode mcp list`
- Check for updates: `opencode --version`
- Review permissions: Check for overly permissive settings

**Monthly**:
- Audit custom commands: Remove unused
- Review agent configurations: Optimize temperatures
- Update MCPs: Check for new versions
- Clean logs: `~/.local/share/opencode/logs/`

### Performance Monitoring

Track token usage:
- Monitor API costs via provider dashboards
- Optimize context with compaction
- Use small models for simple tasks
- Enable cache keys to reduce costs

### Configuration Backup

```bash
# Backup configurations
./scripts/snapshot.sh create opencode-backup

# Restore if needed
./scripts/snapshot.sh restore opencode-backup
```

---

## Team Collaboration

### Shared Configuration

**Project `.opencode/opencode.json`**:
```json
{
  "instructions": ["AGENTS.md"],
  "agent": {
    "build": {
      "temperature": 0.3
    }
  },
  "formatter": {
    "prettier": true
  }
}
```

**Team Guidelines**:
1. Document custom agents in README
2. Share custom commands via project config
3. Keep sensitive settings in personal config
4. Use environment variables for API keys

### Code Review Workflow

1. **Plan Mode**: Review implementation approach
2. **Build Mode**: Implement changes
3. **Review Agent**: `@review` for automated review
4. **Test**: `/test` to run test suite
5. **Manual Review**: Team member reviews
6. **Commit**: Git commit with OpenCode's help

---

## Common Pitfalls

### ❌ Anti-Patterns

1. **Over-permissive**: Setting `"permission": "allow"` globally
2. **No Small Model**: Not using `small_model` wastes costs
3. **Too Many MCPs**: Enabling unused MCPs bloats context
4. **Ignoring Updates**: Not updating formatters/LSPs
5. **Hardcoded Secrets**: API keys in config files

### ✅ Best Patterns

1. **Granular Permissions**: Specific allows/denies
2. **Model Optimization**: Right model for right task
3. **Selective MCPs**: Only enable what you use
4. **Regular Maintenance**: Weekly checks, monthly audits
5. **Environment Variables**: `{env:VAR}` for secrets

---

## Resources

- [OpenCode Documentation](https://opencode.ai/docs/)
- [OpenCode GitHub](https://github.com/anomalyco/opencode)
- [OpenCode Discord Community](https://opencode.ai/discord)
- [MCP Specification](https://modelcontextprotocol.io/)
- [Claude API Docs](https://docs.anthropic.com/)

---

**Last Updated**: 2025-01-06  
**Configuration Version**: OpenCode 1.x

# LSP Requirements

This document lists the Language Server Protocol (LSP) servers required for full functionality in both Neovim and OpenCode.

## Overview

- **Neovim**: Uses Mason to auto-install LSP servers (configured in `nvim/.config/nvim/lua/config/lsp_servers.lua`)
- **OpenCode**: Includes 30+ integrated LSP servers with auto-detection, but requires manual installation

## Required LSP Servers

### JavaScript/TypeScript

**Package**: `typescript-language-server` + `typescript`

```bash
npm install -g typescript-language-server typescript
```

**Used by**:

- OpenCode (auto-detected for `.js`, `.ts`, `.jsx`, `.tsx` files)
- Neovim (via Mason as `ts_ls`)

**Features**:

- IntelliSense and autocomplete
- Go to definition/references
- Refactoring support
- Type checking

### Python

**Package**: `pyright`

```bash
npm install -g pyright
```

**Used by**:

- OpenCode (auto-detected for `.py` files)
- Neovim (via Mason)

**Features**:

- Type checking
- Auto-imports
- Refactoring
- Documentation

### Lua

**Package**: `lua-language-server`

```bash
brew install lua-language-server  # macOS
# or
sudo pacman -S lua-language-server  # Arch Linux
```

**Used by**:

- Neovim (via Mason as `lua_ls`)
- OpenCode (auto-detected for `.lua` files)

**Features**:

- Neovim API completion
- Type checking
- Documentation

### Bash

**Package**: `bash-language-server`

```bash
npm install -g bash-language-server
```

**Used by**:

- OpenCode (auto-detected for `.sh`, `.bash` files)
- Neovim (via Mason as `bashls`)

**Features**:

- Syntax checking
- Command completion
- Documentation

### HTML/CSS

**Packages**: `vscode-langservers-extracted`

```bash
npm install -g vscode-langservers-extracted
```

**Provides**:

- `html` - HTML language server
- `cssls` - CSS language server
- `jsonls` - JSON language server

**Used by**:

- OpenCode (auto-detected)
- Neovim (via Mason)

### YAML

**Package**: `yaml-language-server`

```bash
npm install -g yaml-language-server
```

**Used by**:

- OpenCode (auto-detected for `.yaml`, `.yml` files)
- Neovim (via Mason as `yamlls`)

**Features**:

- Schema validation
- Auto-completion
- Kubernetes/Docker Compose support

## Installation Script

Quick install all LSP servers:

```bash
#!/usr/bin/env bash
# Install all required LSP servers

echo "Installing LSP servers..."

# Node.js based servers
npm install -g \
  typescript-language-server \
  typescript \
  pyright \
  bash-language-server \
  vscode-langservers-extracted \
  yaml-language-server

# System package managers
if command -v brew &> /dev/null; then
  brew install lua-language-server
elif command -v pacman &> /dev/null; then
  sudo pacman -S lua-language-server
fi

echo "✓ LSP servers installed"
```

## Verification

Check installed LSP servers:

```bash
# TypeScript
typescript-language-server --version

# Python
pyright --version

# Bash
bash-language-server --version

# Lua
lua-language-server --version

# YAML
yaml-language-server --version
```

## OpenCode Auto-Detection

OpenCode automatically detects and uses LSP servers based on file extensions. No additional configuration needed in `opencode.json` unless you want to customize a specific server.

Example custom configuration (optional):

```json
{
  "lsp": {
    "typescript": {
      "command": ["typescript-language-server", "--stdio"],
      "extensions": [".ts", ".tsx", ".js", ".jsx"],
      "initialization": {
        "preferences": {
          "includeInlayParameterNameHints": "all"
        }
      }
    }
  }
}
```

## Neovim Auto-Installation

Neovim uses Mason to automatically install LSP servers. The list is configured in:

```
nvim/.config/nvim/lua/config/lsp_servers.lua
```

To add a new server:

1. Open Mason: `:Mason`
2. Find the server name
3. Add it to `lsp_servers.lua`
4. Restart Neovim

## Troubleshooting

### LSP not working in OpenCode

1. Verify the LSP is installed globally:

   ```bash
   which typescript-language-server
   ```

2. Check OpenCode can find it:

   ```bash
   opencode --version
   # Should show LSP servers in diagnostics
   ```

3. Restart OpenCode after installing new LSP servers

### LSP not working in Neovim

1. Check Mason installation:

   ```vim
   :Mason
   ```

2. Check LSP status:

   ```vim
   :LspInfo
   ```

3. Reinstall via Mason:
   ```vim
   :MasonUninstall ts_ls
   :MasonInstall ts_ls
   ```

## References

- [OpenCode LSP Documentation](https://opencode.ai/docs/lsp)
- [Neovim LSP Guide](https://neovim.io/doc/user/lsp.html)
- [Mason.nvim](https://github.com/williamboman/mason.nvim)

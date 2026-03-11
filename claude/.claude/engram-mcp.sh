#!/usr/bin/env sh
# Cross-platform engram MCP launcher
# Supports macOS (Homebrew) and Linux (Linuxbrew or system PATH)

for path in \
  /opt/homebrew/bin/engram \
  /home/linuxbrew/.linuxbrew/bin/engram \
  "$HOME/.linuxbrew/bin/engram" \
  "$(command -v engram 2>/dev/null)"; do
  if [ -x "$path" ]; then
    exec "$path" mcp
  fi
done

echo "engram not found. Install with: brew install engram" >&2
exit 1

#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

claude --print --allowedTools 'Bash(*)' 'Read(*)' 'Edit(*)' 2>/dev/null

cat > /tmp/pi-bump-prompt.md 2>/dev/null || cat 2>/dev/null || true
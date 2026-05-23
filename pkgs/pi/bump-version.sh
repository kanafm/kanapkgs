#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

claude --print --allowedTools 'Bash(*)' 'Read(*)' 'Edit(*)' "$(dirname "$0")/bump-prompt.md"
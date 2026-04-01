#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

claude --print --allowedTools 'Bash(*)' 'Read(*)' 'Edit(*)' <<'PROMPT'
Bump the claude-code-native package to the latest available version. Follow these steps exactly:

1. Read pkgs/claude-code-native/default.nix to get the current version.

2. Find the latest version by probing the GCS URL with HEAD requests, binary-searching upward from the current version:
   curl -sI "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/{VERSION}/darwin-arm64/claude"
   A 200 means it exists, 404 means it doesn't. Find the highest version that returns 200.
   If no version newer than current exists, inform the user and stop.

3. Get the SRI hash for aarch64-darwin:
   nix-prefetch-url --type sha256 "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/{VERSION}/darwin-arm64/claude"
   Then convert: nix hash to-sri --type sha256 {HASH}
   If the prefetch fails, inform the user that the binary may have been removed or the URL structure changed, and stop.

4. Edit pkgs/claude-code-native/default.nix:
   - Update the version string to the new version
   - Update the aarch64-darwin hash to the new SRI hash
   - Leave other platform hashes as lib.fakeHash

5. Build and verify:
   nix build .#claude-code-native
   ./result/bin/claude --version
   If the build fails, revert with: git checkout pkgs/claude-code-native/default.nix
   Inform the user of the build error and stop.
   If it builds but --version doesn't match the expected version, also revert, inform, and stop.

6. Commit:
   git add pkgs/claude-code-native/default.nix
   git commit -m "feat: bump claude-code-native to {VERSION}"
PROMPT

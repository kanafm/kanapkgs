#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

claude --print --allowedTools 'Bash(*)' 'Read(*)' 'Edit(*)' <<'PROMPT'
Bump the waveterm package to the latest available version. Follow these steps exactly:

1. Read pkgs/waveterm/default.nix to get the current version.

2. Find the latest version using the GitHub releases API:
   curl -s https://api.github.com/repos/wavetermdev/waveterm/releases/latest | jq -r .tag_name
   Strip a leading "v" if present. If that command fails or returns null/empty, inform the user and stop.
   If the latest version equals the current version, inform the user there's nothing to do and stop.

3. Verify the aarch64-darwin DMG URL exists for that version:
   curl -sIo /dev/null -w "%{http_code}" "https://dl.waveterm.dev/releases-w2/Wave-darwin-arm64-{VERSION}.dmg"
   A 200 means it exists. Anything else: inform the user and stop.

4. Get the SRI hash for aarch64-darwin:
   nix-prefetch-url --type sha256 "https://dl.waveterm.dev/releases-w2/Wave-darwin-arm64-{VERSION}.dmg"
   Then convert: nix hash convert --hash-algo sha256 --to sri {HASH}
   (If `nix hash convert` is not available on this nix version, fall back to `nix hash to-sri --type sha256 {HASH}`.)
   If the prefetch fails, inform the user that the binary may have been removed or the URL structure changed, and stop.

5. Edit pkgs/waveterm/default.nix:
   - Update the version string to the new version
   - Update the aarch64-darwin hash to the new SRI hash
   - Leave x86_64-darwin as lib.fakeHash (not built/used)

6. Build and verify:
   git add pkgs/waveterm/default.nix
   nix build .#waveterm
   Then verify the .app bundle reports the expected version:
   /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" result/Applications/Wave.app/Contents/Info.plist
   And verify wsh runs:
   ./result/bin/wsh version
   If any of those fail, revert with:
   git checkout pkgs/waveterm/default.nix
   git reset HEAD pkgs/waveterm/default.nix
   Inform the user of the failure and stop.
   If the .app version doesn't match the expected version, also revert, inform, and stop.

7. Commit:
   git add pkgs/waveterm/default.nix
   git commit -m "feat: bump waveterm to {VERSION}"
PROMPT

#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

claude --print --allowedTools 'Bash(*)' 'Read(*)' 'Edit(*)' <<'PROMPT'
Bump the cmux-next package to the latest available release on kanafm/cmux-next. Follow these steps exactly:

1. Read pkgs/cmux-next/default.nix to get the current version (a tag like nix-YYYY.MM.DD-<sha>).

2. Find the latest tag on kanafm/cmux-next using:
   gh release list --repo kanafm/cmux-next --limit 1 --json tagName --jq '.[0].tagName'
   This includes prereleases (which all cmux-next fork releases are). If the latest tag equals the current version, inform the user there's nothing to do and stop.

3. Verify the cmux-macos.dmg asset exists for that tag:
   curl -sIo /dev/null -w "%{http_code}" -L "https://github.com/kanafm/cmux-next/releases/download/{TAG}/cmux-macos.dmg"
   200 means it exists. Anything else: inform the user that the binary may have been removed or the URL structure changed, and stop.

4. Get the SRI hash for the DMG:
   nix-prefetch-url --type sha256 "https://github.com/kanafm/cmux-next/releases/download/{TAG}/cmux-macos.dmg"
   Then convert: nix hash convert --hash-algo sha256 --to sri {HASH}
   (If `nix hash convert` is not available on this nix version, fall back to `nix hash to-sri --type sha256 {HASH}`.)
   If prefetch fails, inform the user and stop.

5. Edit pkgs/cmux-next/default.nix:
   - Update the version string to the new tag
   - Update the aarch64-darwin hash to the new SRI hash

6. Build and verify:
   git add pkgs/cmux-next/default.nix
   nix build .#cmux-next
   Then verify the .app bundle is present and the binary is intact:
   test -d result/Applications/cmux.app
   test -x result/Applications/cmux.app/Contents/MacOS/cmux
   /usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" result/Applications/cmux.app/Contents/Info.plist
   (Note: do NOT run `codesign --verify --deep --strict` here. The DMG-resident
    bundle has full Sealed Resources, but `undmg` extraction drops the xattrs
    that codesign needs to validate them, leaving only the linker-signed
    executable signature. macOS still launches the bundle fine; only `--deep`
    verification fails. This matches the waveterm package's behavior.)
   If any of the checks above fail, revert with:
   git checkout pkgs/cmux-next/default.nix
   git reset HEAD pkgs/cmux-next/default.nix
   Inform the user of the failure and stop.

7. Commit with the kanafm identity (do NOT use the machine default git author):
   git add pkgs/cmux-next/default.nix
   git -c user.name=kanafm -c user.email=kanafm@users.noreply.github.com \
       commit -m "feat: bump cmux-next to {TAG}"
PROMPT

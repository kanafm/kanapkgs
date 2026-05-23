Bump the pi package to the latest available version. Follow these steps exactly:

1. Read pkgs/pi/default.nix to get the current version.

2. Find the latest version by checking the npm registry:
   curl -s "https://registry.npmjs.org/@earendil-works/pi-coding-agent" | jq -r '."dist-tags".latest'
   If that command fails or returns null/empty, inform the user and stop.
   If the latest version equals the current version, inform the user there's nothing to do and stop.

3. Get the SRI hash for the new version tarball:
   nix-prefetch-url --type sha512 "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-{VERSION}.tgz"
   Then convert: nix hash to-sri --type sha512 {HASH}
   If the prefetch fails, inform the user and stop.

4. Check the new tarball's shrinkwrap for missing integrity fields on @earendil-works packages:
   Download the tarball: curl -sLO "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-{VERSION}.tgz"
   Extract: tar xzf pi-coding-agent-{VERSION}.tgz
   For each of these packages, check if integrity is missing and if so get it from the npm registry:
   - @earendil-works/pi-agent-core at version {VERSION}
   - @earendil-works/pi-ai at version {VERSION}  
   - @earendil-works/pi-tui at version {VERSION}
   For each missing integrity: 
     curl -s "https://registry.npmjs.org/{PACKAGE}/{VERSION}" | jq -r '.dist.integrity'
   Record the integrity values.

5. Edit pkgs/pi/default.nix:
   - Update the version string to the new version
   - Update the src hash to the new SRI hash
   - Update the integrity values in the patchedSrc jq command
   - Reset npmDepsHash to lib.fakeHash

6. Build to get the new npmDepsHash:
   git add pkgs/pi/default.nix
   nix build .#pi 2>&1 | grep "got:" | head -1
   If the build fails for reasons other than hash mismatch, inspect the error and fix it.
   Edit pkgs/pi/default.nix to replace lib.fakeHash with the got hash.

7. Build and verify:
   nix build .#pi
   ./result/bin/pi --version
   If the build fails, revert with: git checkout pkgs/pi/default.nix
   Inform the user of the build error and stop.
   If --version doesn't match the expected version, also revert, inform, and stop.

8. Commit:
   git add pkgs/pi/default.nix
   git commit -m "feat: bump pi to {VERSION}"
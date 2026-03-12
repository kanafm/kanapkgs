{ writeShellScriptBin, coreutils }:

writeShellScriptBin "bigfiles" ''
  echo "Top 20 largest items in current directory:"
  echo "--------------------------------------------"
  ${coreutils}/bin/du -ah --max-depth=1 2>/dev/null | ${coreutils}/bin/sort -rh | head -n 20
''

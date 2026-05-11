{ lib, stdenv, fetchurl, undmg }:

let
  version = "nix-2026.05.11-a95752b";

  sources = {
    aarch64-darwin = {
      url = "https://github.com/kanafm/cmux-next/releases/download/${version}/cmux-macos.dmg";
      hash = "sha256-FkWvOAeS6df4ci6NcnaRUPLpOrJUGshBRRFiXcIfdFo=";
    };
  };

  src =
    sources.${stdenv.hostPlatform.system}
      or (throw "cmux-next: unsupported system ${stdenv.hostPlatform.system} (only aarch64-darwin nix-build releases are published; see kanafm/cmux-next)");
in
stdenv.mkDerivation {
  pname = "cmux-next";
  inherit version;

  src = fetchurl {
    inherit (src) url hash;
    name = "cmux-${version}.dmg";
  };

  nativeBuildInputs = [ undmg ];
  sourceRoot = ".";
  unpackPhase = "undmg $src";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -R "cmux.app" $out/Applications/
    runHook postInstall
  '';

  meta = with lib; {
    description = "cmux-next: kanafm fork prerelease build of cmux (nix-build DMG)";
    homepage = "https://github.com/kanafm/cmux-next";
    license = licenses.mit;
    platforms = builtins.attrNames sources;
  };
}

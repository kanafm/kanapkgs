{ lib, stdenv, fetchurl, undmg }:

let
  version = "0.14.5";

  sources = {
    aarch64-darwin = {
      url = "https://dl.waveterm.dev/releases-w2/Wave-darwin-arm64-${version}.dmg";
      hash = "sha256-jXKuMb0sOoE1bVXshucOooSmW94Re1KDRSnaPi5A/zk=";
    };
    x86_64-darwin = {
      url = "https://dl.waveterm.dev/releases-w2/Wave-darwin-x64-${version}.dmg";
      hash = lib.fakeHash;
    };
  };

  src =
    sources.${stdenv.hostPlatform.system}
      or (throw "waveterm: unsupported system ${stdenv.hostPlatform.system}");

  wshArch = if stdenv.hostPlatform.isAarch64 then "arm64" else "x64";
in
stdenv.mkDerivation {
  pname = "waveterm";
  inherit version;

  src = fetchurl {
    inherit (src) url hash;
    name = "Wave-${version}.dmg";
  };

  nativeBuildInputs = [ undmg ];
  sourceRoot = ".";
  unpackPhase = "undmg $src";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications $out/bin
    cp -R "Wave.app" $out/Applications/

    wsh=$(find "$out/Applications/Wave.app/Contents/Resources" \
            -type f -name "wsh-*-darwin.${wshArch}" -perm -u+x \
            | head -n1)
    if [ -z "$wsh" ]; then
      echo "waveterm: could not locate wsh-*-darwin.${wshArch} inside Wave.app — skipping bin symlink" >&2
    else
      ln -s "$wsh" $out/bin/wsh
    fi
    runHook postInstall
  '';

  meta = with lib; {
    description = "Wave terminal — open-source terminal with graphical capabilities";
    homepage = "https://waveterm.dev";
    license = licenses.asl20;
    platforms = builtins.attrNames sources;
  };
}

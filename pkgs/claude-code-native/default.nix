# pkgs/claude-code-native/default.nix
{ lib, stdenv, fetchurl, autoPatchelfHook }:

let
  version = "2.1.74";

  sources = {
    aarch64-darwin = {
      url = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/${version}/darwin-arm64/claude";
      hash = "sha256-SKB+KIfNSHkhnTGeSKxcxuIJgjjHwKvgHFejVDCUHLc=";
    };
    x86_64-darwin = {
      url = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/${version}/darwin-x64/claude";
      hash = lib.fakeHash;
    };
    x86_64-linux = {
      url = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/${version}/linux-x64/claude";
      hash = lib.fakeHash;
    };
    aarch64-linux = {
      url = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/${version}/linux-arm64/claude";
      hash = lib.fakeHash;
    };
  };

  src = sources.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "claude-code-native";
  inherit version;

  src = fetchurl {
    inherit (src) url hash;
    name = "claude";
  };

  dontUnpack = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/claude
    runHook postInstall
  '';

  meta = with lib; {
    description = "Claude Code";
    homepage = "https://claude.ai";
    license = licenses.unfree;
    platforms = builtins.attrNames sources;
    mainProgram = "claude";
  };
}

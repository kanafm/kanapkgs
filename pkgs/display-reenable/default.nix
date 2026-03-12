{ python3, stdenv }:

stdenv.mkDerivation {
  name = "display-reenable";
  src = ./src;

  buildInputs = [ python3 ];

  installPhase = ''
    mkdir -p $out/bin
    cp display-reenable.py $out/bin/display-reenable
    chmod +x $out/bin/display-reenable
  '';

  postFixup = ''
    patchShebangs $out/bin
  '';
}

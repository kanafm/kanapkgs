{ lib, buildNpmPackage, fetchurl, fetchNpmDeps, runCommand, jq }:

let
  version = "0.75.5";

  src = fetchurl {
    url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
    hash = "sha512-O3CCQDYy28D4uwtP6zZkdEwzHN6X22v49Sb0+SZTC7x37V/YfmogrWPiaFoWeoc2hmdKhSATI7ZAK5bQbJG5NA==";
  };

  patchedSrc = runCommand "pi-${version}-patched" { nativeBuildInputs = [ jq ]; } ''
    mkdir -p $out
    tar xzf ${src} -C $out --strip-components=1
    chmod -R +w $out
    # Add integrity fields missing from monorepo packages
    jq '.packages["node_modules/@earendil-works/pi-agent-core"].integrity = "sha512-LHygOgsW2pgXKb3IkXkOAeZPovHr9VF+EixgXVsDNuB4jmhEOXgshy/zksZ7slkUAx10OQ9W1Ed/2jsnhd1NqA==" | .packages["node_modules/@earendil-works/pi-ai"].integrity = "sha512-zf1F5kXk1pqZeFShXOqq9ibUk8QdtRoLCDPAjO+hj44e3EUs9/GFO2qnhTC5+JA2uwVCx+WCNe1PiCjlBYWm5w==" | .packages["node_modules/@earendil-works/pi-tui"].integrity = "sha512-LkXUM1/49pvzzeI39Y5wjBMlgafcCf67HCLhB9Z7yuXHy4XgT+VqxWcZVW5hBdhQsHZd0znjJotfGH1BzxMfiA=="' $out/npm-shrinkwrap.json > $out/npm-shrinkwrap.json.tmp && mv $out/npm-shrinkwrap.json.tmp $out/npm-shrinkwrap.json
    # Remove devDependencies so npm install --offline doesn't fail trying to fetch them
    jq 'del(.devDependencies)' $out/package.json > $out/package.json.tmp && mv $out/package.json.tmp $out/package.json
  '';
in
buildNpmPackage {
  pname = "pi";
  inherit version;

  src = patchedSrc;

  npmDepsHash = "sha256-Sd+ELuDrFbVnOyhhfa533ZJ0A1MZFmJ/w0/aGJJuqsc=";

  npmDepsFetcherVersion = 2;

  makeCacheWritable = true;
  dontNpmBuild = true;

  meta = with lib; {
    description = "Pi — coding agent CLI with read, bash, edit, write tools and session management";
    homepage = "https://pi.dev";
    license = licenses.unfree;
    mainProgram = "pi";
    platforms = platforms.unix;
  };
}
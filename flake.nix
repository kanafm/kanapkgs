{
  description = "nix package repo by @kanafm";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems
        (system: f system (import nixpkgs { inherit system; config.allowUnfree = true; }));

      mkPackages = final: prev:
        builtins.mapAttrs
          (name: _: final.callPackage ./pkgs/${name} { })
          (nixpkgs.lib.filterAttrs
            (_: type: type == "directory")
            (builtins.readDir ./pkgs));
    in {
      packages = forAllSystems (_: pkgs: mkPackages pkgs pkgs);

      overlays.default = mkPackages;

      devShells = forAllSystems (_: pkgs: {
        default = pkgs.mkShell {
          packages = builtins.attrValues (mkPackages pkgs pkgs);
        };
      });
    };
}

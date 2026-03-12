# kanapkgs

This is my nix package repository.

## Available packages

* bigfiles: quick, intuitive command to list the largest items in your current directory.
* claude-code-native: Native build of Claude Code ([see documentation](https://code.claude.com/docs/en/overview#native-install-recommended))

## Usage

You can use any of the packages in my repo for your own projects. Here's an example of a flake.nix if you are creating a project and want it available in your dev shell or at build time:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    kanapkgs.url = "github:kanafm/kanapkgs";
  };

  outputs = { self, nixpkgs, kanapkgs }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ kanapkgs.overlays.default ];
      };
    in {
      # use the package in a dev shell
      devShells.${system}.default = pkgs.mkShell {
        packages = [ pkgs.bigfiles ];
      };

      # or as a build dependency of your package
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        name = "my-project";
        src = ./.;
        nativeBuildInputs = [ pkgs.bigfiles ];
        buildPhase = ''
          bigfiles  # available during build
        '';
      };
    };
}
```

## Development
```bash
git add -v . && nix flake check
nix flake show

# build a package
nix build .#bigfiles
nix build github:kanafm/kanapkgs#bigfiles
```

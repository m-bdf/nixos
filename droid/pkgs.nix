{ inputs, config, lib, pkgs, ... }:

let
  storePaths = pkgs.runCommand "store-paths.nix" {
    nativeBuildInputs = [ config.home.programs.nix-index.package ];
  } ''
    { echo {
      nix-locate --at-root --whole-name ''' |
      while read pkg _ _ path; do
        echo \"''${pkg//./\".\"}\" = \"$path\"\;
      done
      echo }
    } > $out
  '';

  default = pkgs.writeTextDir "default.nix" ''
    { config ? {}, ... }:

    import ./pkgs/top-level/impure.nix {
      stdenvStages = args: [
        (_: { __raw = true; cc = null; fetchurl = null; })
      ] ++ builtins.tail (import ./pkgs/stdenv/native args);

      overlays = [
        (_: prev: {
          stdenv = prev.stdenv.override {
            initialPath = [ ${toString pkgs.stdenv.initialPath} ];
            shell = ${pkgs.stdenv.shell};
          };
        })

        (_: prev: with prev.lib;
          mapAttrsRecursiveCond (v: !v ? out) (_: d:
            toDerivation d.out // mapAttrs (_: builtins.storePath) d
          ) (import ${storePaths})
        )
      ];
    }
  '';

  nixpkgs = pkgs.runCommandLocal "source" {} ''
    mkdir $out && ln -s ${default}/* ${inputs.nixpkgs}/{lib,pkgs} $out
  '';
in

{
  home.nix = {
    registry.nixpkgs.flake = lib.mkForce nixpkgs;
    nixPath = lib.mkForce [ "nixpkgs=${nixpkgs}" ];
  };
}

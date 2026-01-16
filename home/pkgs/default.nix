{ inputs, lib, pkgs, ... }:

let
  default = pkgs.writeText "default.nix" ''
    { config ? {}, ... }@ args:

    import ./pkgs/top-level/impure.nix (args // {
      config = ${
        with lib; generators.toPretty { indent = "  "; }
          (filterAttrs (_: v: !isFunction v) pkgs.config)
      } // config;
    })
  '';

  nixpkgs = pkgs.runCommandLocal "source" {} ''
    mkdir $out
    ln -s ${default}/* ${inputs.nixpkgs}/{lib,pkgs} $out
  '';

  nixd = pkgs.writeShellScriptBin "nixd" ''
    configs='(import ${./configs.nix} ./.)'

    while ! ${lib.getExe pkgs.nixd} "$@" \
      --nixpkgs-expr="$configs.pkgs" \
      --nixos-options-expr="$configs.options"
    do
      sleep 1
    done
  '';
in

{
  nix = {
    registry.nixpkgs.flake = nixpkgs;
    nixPath = [
      "nixpkgs=${nixpkgs}"
      "home-manager=${inputs.home-manager}"
    ];
    keepOldNixPath = false;
  };

  home.packages = with pkgs; [ nixd nixfmt ];
}

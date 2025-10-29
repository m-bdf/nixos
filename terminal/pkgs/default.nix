{ inputs, lib, pkgs, ... }:

let
  config = pkgs.writeText "nixpkgs-config.nix"
    (lib.generators.toPretty {}
      (lib.filterAttrs (_: v: !lib.isFunction v) pkgs.config));

  nixd = pkgs.writeShellScriptBin "nixd" ''
    exec ${lib.getExe pkgs.nixd} "$@" \
      --nixpkgs-expr="(import ${./configs.nix} ./.).pkgs" \
      --nixos-options-expr='(import ${./configs.nix} ./.).options'
  '';
in

{
  nix = {
    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = [
      "nixpkgs=flake:nixpkgs"
      "home-manager=${inputs.home-manager}"
    ];
    keepOldNixPath = false;
  };

  home = {
    sessionVariables.NIXPKGS_CONFIG = config;
    packages = [ nixd ];
  };
}

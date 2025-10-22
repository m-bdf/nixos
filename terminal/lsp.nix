{ lib, pkgs, ... }:

let
  mergeConfigs = pkgs.writeText "merge-configs.nix" ''
    with builtins; path:

    let
      flake =
        if pathExists (path + /flake.nix)
        then getFlake (toString path) else {};

      configs = concatMap attrValues [
        flake.homeConfigurations or {}
        flake.nixOnDroidConfigurations or {}
        flake.nixosConfigurations or {}
      ];

      configsForCurrentSystem =
        filter (c: (tryEval
          (c.pkgs.stdenv.system == currentSystem)
        ).value) configs;

      mergeConfigs = zipAttrsWith (_: l:
        if any (v: !isAttrs v || v ? _type) l
        then head l else mergeConfigs l
      );
    in

    if configsForCurrentSystem != []
    then mergeConfigs configsForCurrentSystem
    else (import <nixpkgs> {}).nixos {}
  '';

  nixd = pkgs.writeShellScriptBin "nixd" ''
    exec ${lib.getExe pkgs.nixd} "$@" \
      --nixpkgs-expr="(import ${mergeConfigs} ./.).pkgs" \
      --nixos-options-expr='(import ${mergeConfigs} ./.).options'
  '';
in

{
  home.packages = [ nixd ];
}

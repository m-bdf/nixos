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

  nixpkgs = pkgs.runCommand "source" {} ''
    cp -R ${inputs.nixpkgs} $out
    chmod +w $out/default.nix
    cp ${default} $out/default.nix
  '';

  nixd = pkgs.writeShellScriptBin "nixd" ''
    exec ${lib.getExe pkgs.nixd} "$@" \
      --nixpkgs-expr="(import ${./configs.nix} ./.).pkgs" \
      --nixos-options-expr='(import ${./configs.nix} ./.).options'
  '';
in

{
  nix = {
    registry.nixpkgs.flake = nixpkgs;
    nixPath = [
      "nixpkgs=flake:nixpkgs"
      "home-manager=${inputs.home-manager}"
    ];
    keepOldNixPath = false;
  };

  home.packages = with pkgs; [ nixd nixfmt ];
}

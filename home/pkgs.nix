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
in

{
  nix = {
    settings = (import (inputs.self + /flake.nix)).nixConfig;

    registry = {
      nix.flake = inputs.nix;
      nixpkgs.flake = nixpkgs;
    };
    nixPath = [
      "nixpkgs=${nixpkgs}"
      "home-manager=${inputs.home-manager}"
    ];
    keepOldNixPath = false;
  };
}

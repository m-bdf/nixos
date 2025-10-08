{ inputs, lib, pkgs, ... }:

let
  default = pkgs.writeTextDir "default.nix" ''
    { config ? {}, ... }@ args:

    import ${inputs.nixpkgs} (args // {
      config = ${
        with lib; generators.toPretty { indent = "  "; }
          (filterAttrs (_: v: !isFunction v) pkgs.config)
      } // config;
    })
  '';

  modules = pkgs.writeTextDir "modules/module-list.nix" ''
    with builtins;

    let
      merged = with getFlake "${inputs.self}";
        foldl' inputs.nixpkgs.lib.recursiveUpdate {} [
          ((import inputs.nixpkgs {}).nixos {})
          nixOnDroidConfigurations.''${currentSystem}
          homeConfigurations.''${currentSystem}
        ];
    in

    [{
      options = removeAttrs merged.options [ "_module" ];
    }]
  '';
in

{
  nix = {
    registry.nixpkgs.flake =
      pkgs.symlinkJoin {
        name = "source";
        paths = [ default inputs.nixpkgs ];
      };

    nixPath = [
      "nixpkgs=flake:nixpkgs"
      "nixpkgs/nixos=${modules}"
    ];
    keepOldNixPath = false;
  };
}

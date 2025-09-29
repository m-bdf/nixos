{ inputs, lib, pkgs, ... }:

let
  default = pkgs.writeText "pkgs.nix" ''
    { config ? {}, ... }@ args:

    import ${inputs.nixpkgs} (args // {
      config = ${
        with lib; generators.toPretty { indent = "  "; }
          (filterAttrs (_: v: !isFunction v) pkgs.config)
      } // config;
    })
  '';

  modules = pkgs.writeText "merged-modules.nix" ''
    { lib, ... }: with builtins // lib;

    let
      merged = with getFlake "${inputs.self}";
        foldl' recursiveUpdate {} [
          ((import inputs.nixpkgs {}).nixos {})
          nixOnDroidConfigurations.''${currentSystem}
          homeConfigurations.''${currentSystem}
        ];
    in
    {
      options = removeAttrs merged.options [ "_module" ];
      config = merged.config // { inherit (merged) _module; };
    }
  '';

  nixpkgs = pkgs.runCommand "source" {} ''
    cp --recursive --no-preserve=mode ${inputs.nixpkgs} $out
    ln -sf ${default} $out/default.nix
    echo '[ ${modules} ]' > $out/nixos/modules/module-list.nix
  '';
in

{
  nix = {
    registry.nixpkgs.flake = nixpkgs;
    nixPath = [ "nixpkgs=flake:nixpkgs" ];
    keepOldNixPath = false;
  };
}

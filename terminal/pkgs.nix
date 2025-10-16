{ inputs, options, lib, pkgs, ... }:

let
  default = pkgs.writeText "pkgs.nix" ''
    { config ? {}, ... }@ args:

    import ./pkgs/top-level/impure.nix (args // {
      config = ${
        with lib; generators.toPretty { indent = "  "; }
          (filterAttrs (_: v: !isFunction v) pkgs.config)
      } // config;
    })
  '';

  # modules = pkgs.writeText "merged-modules.nix" ''
  #   { lib, ... }: with builtins // lib;

  #   let
  #     merged = with getFlake "${inputs.self}";
  #       foldl' recursiveUpdate {} [
  #         ((import inputs.nixpkgs {}).nixos {})
  #         nixOnDroidConfigurations.''${currentSystem}
  #         homeConfigurations.''${currentSystem}
  #       ];
  #   in
  #   {
  #     options = removeAttrs merged.options [ "_module" ];
  #     config = merged.config // { inherit (merged) _module; };
  #   }
  # '';

  typeToPretty = o: t: {
    inherit (t) name description deprecationMessage;

    nestedTypes = lib.optionalAttrs (
      t.name == "attrsOf" &&
      t.nestedTypes.elemType.name != o.type.name
    ) {
      elemType = typeToPretty o t.nestedTypes.elemType;
    };

    getSubOptions = lib.optionalAttrs (
      t.name == "submodule" &&
      lib.elem o.visible or true [ true "transparent" ]
    ) {
      val = t.getSubOptions o.loc;
      __pretty = subOpts: "_: " + optsToPretty subOpts;
    };
  };

  optsToPretty = opts:
    lib.generators.toPretty { allowPrettyValues = true; }
      (lib.mapAttrsRecursiveCond (v: !lib.isOption v)
        (_: o: {
          inherit (o) _type declarations;
          description = o.description or null;
          type = typeToPretty o o.type;
        })
        opts
      );

  modules = pkgs.writeText "merged-modules.nix" ''
    {
      options = ${optsToPretty (
        lib.recursiveUpdate
          (lib.removeAttrs (pkgs.nixos {}).options [ "_module" ])
          (lib.removeAttrs options [ "_module" ])
      )};
    }
  '';

  nixpkgs = pkgs.runCommand "source" {} ''
    cp -R ${inputs.nixpkgs} $out
    chmod -R +w $out
    cp ${default} $out/default.nix
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

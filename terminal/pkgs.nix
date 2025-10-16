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

    nestedTypes = lib.optionalDrvAttr (
      t.name == "attrsOf" &&
      t.nestedTypes.elemType.name != o.type.name
    ) {
      elemType = typeToPretty o t.nestedTypes.elemType;
    };

    getSubOptions = lib.optionalDrvAttr (
      t.name == "submodule" &&
      lib.elem o.visible or true [ true "transparent" ]
    ) {
      val = optsToPretty (t.getSubOptions o.loc);
      __pretty = subOpts: "_:\n  ${subOpts} # ${o}\n";
    };
  };

  optsToPretty = opts:
    lib.generators.toPretty {
      indent = "  ";
      allowPrettyValues = true;
    }
      (lib.mapAttrsRecursiveCond (v: !lib.isOption v)
        (_: o: {
          inherit (o) _type declarationPositions;
          description = o.description or null;
          type = typeToPretty o o.type;
        })
        (lib.removeAttrs opts [ "_module" ])
      );

  # modules = pkgs.writeText "merged-options.nix" ''
  #   {
  #     options = ${optsToPretty
  #       (lib.mapAttrs (_: opts:
  #         lib.mkOption {
  #           type = {
  #             name = "submodule";
  #             getSubOptions = _: opts;
  #             deprecationMessage = null;
  #           };
  #         } // {
  #           declarationPositions = null;
  #         }
  #       )
  #         (lib.recursiveUpdate (pkgs.nixos {}).options options)
  #       )
  #     };
  #   }
  # '';

  # modules = pkgs.writeText "merged-options.nix" ''
  #   { lib, ... }:

  #   let
  #     options = ${optsToPretty
  #       (lib.recursiveUpdate (pkgs.nixos {}).options options)
  #     };
  #   in

  #   {
  #     options = lib.mapAttrs
  #       (_: opts: lib.mkOption {
  #         type = {
  #           name = "submodule";
  #           getSubOptions = _: opts;
  #           deprecationMessage = null;
  #         };
  #       }) options;
  #   }
  # '';

  # nixpkgs = pkgs.runCommand "source" {} ''
  #   cp -R ${inputs.nixpkgs} $out
  #   chmod -R +w $out
  #   cp ${default} $out/default.nix
  #   echo '[ ${modules} ]' > $out/nixos/modules/module-list.nix
  # '';

  # nixos = pkgs.writeTextDir "modules/module-list.nix" ''
  #   [{
  #     options = ${optsToPretty
  #       (lib.mapAttrs (_: opts:
  #         # lib.mkOption {
  #         #   type = {
  #         #     name = "submodule";
  #         #     getSubOptions = _: opts;
  #         #     deprecationMessage = null;
  #         #   };
  #         # } // {
  #         #   declarationPositions = null;
  #         # }

  #         {
  #           _type = "option";
  #           declarationPositions = null;
  #           __toString = _: "";

  #           type = {
  #             name = "submodule";
  #             description = null;
  #             deprecationMessage = null;
  #             getSubOptions = _: opts;
  #           };
  #         }
  #       )
  #         (lib.recursiveUpdate (pkgs.nixos {}).options options)
  #       )
  #     };
  #   }]
  # '';

  nixos = pkgs.writeTextDir "modules/module-list.nix" ''
    let
      options = ${optsToPretty
        (lib.recursiveUpdate (pkgs.nixos {}).options options)
      };
    in

    [{
      options = builtins.mapAttrs
        (_: opts: {
          _type = "option";
          type = {
            name = "submodule";
            getSubOptions = _: opts;
            deprecationMessage = null;
          };
        }) options;
    }]
  '';

  # nixos = pkgs.writeTextDir "modules/module-list.nix" ''
  #   [{
  #     options = builtins.mapAttrs
  #       (_: opts: {
  #         _type = "option";
  #         type = {
  #           name = "submodule";
  #           getSubOptions = _: opts;
  #           deprecationMessage = null;
  #         };
  #       })
  #       (import ${
  #         pkgs.writeText "merged-options.nix" (optsToPretty
  #           (lib.recursiveUpdate (pkgs.nixos {}).options options)
  #         )
  #       });
  #   }]
  # '';

  nixpkgs = pkgs.runCommand "source" {} ''
    cp -R ${inputs.nixpkgs} $out
    chmod +w $out
    ln -sf ${default} $out/default.nix
  '';
in

{
  nix = {
    registry.nixpkgs.flake = nixpkgs;
    nixPath = [
      "nixpkgs/nixos=${nixos}"
      "nixpkgs=flake:nixpkgs"
    ];
    keepOldNixPath = false;
  };
}

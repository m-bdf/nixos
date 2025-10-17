{ options, lib, pkgs, ... }:

with lib;

let
  typeToPretty = o: t: {
    inherit (t) name description deprecationMessage;

    nestedTypes = optionalAttrs (
      t.name == "attrsOf" &&
      t.nestedTypes.elemType.name != o.type.name
    ) {
      elemType = typeToPretty o t.nestedTypes.elemType;
    };

    getSubOptions = optionalAttrs (
      t.name == "submodule" &&
      elem o.visible or true [ true "transparent" ]
    ) {
      val = optsToPretty (t.getSubOptions o.loc);
      __pretty = opts: "_:\n${opts} # ${o}\n";
    };
  };

  optsToPretty = opts:
  let
    docs = groupBy (o: o.name) (optionAttrSetToDocList opts);

    prettyOpts = mapAttrsRecursiveCond (v: !isOption v)
      (_: o: head docs.${toString o} // {
        inherit (o) _type declarationPositions;
        type = typeToPretty o o.type;
        default = null;
      })
      (removeAttrs opts [ "_module" ]);
  in
    generators.toPretty { allowPrettyValues = true; } prettyOpts;

  modules = pkgs.writeTextDir "module-list.nix" ''
    let
      mkModule = n: o:
        { lib, ... }: with lib;

        {
          options.''${n} =
            o // mkOption {
              type = mkOptionType {
                name = "submodule";
                getSubOptions = _: o;
              };
            };
        };
    in
      with builtins; attrValues (mapAttrs mkModule
        (import ${pkgs.writeText "merged-options.nix"
          (optsToPretty (recursiveUpdate (pkgs.nixos {}).options options))
        })
      )
  '';
in

{
  nix.nixPath = [ "nixpkgs/nixos/modules=${modules}" ];
}

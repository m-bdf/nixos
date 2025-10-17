{ options, lib, pkgs, ... }:

with lib;

let
  typeToPretty = o: t: {
    inherit (t) name description;

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

    optToPretty = o:
      head docs.${toString o} // {
        inherit (o) _type declarationPositions;
        type = typeToPretty o o.type;
        default = null;
      };
  in
    generators.toPretty { allowPrettyValues = true; } (
      mapAttrsRecursiveCond (v: !isOption v)
        (_: optToPretty) (removeAttrs opts [ "_module" ])
    );

  modules = pkgs.writeTextDir "module-list.nix" ''
  let
    wrapOpts = opts: {
      _type = "option";
      type = {
        name = "submodule";
        getSubOptions = _: opts;
        deprecationMessage = null;
      };
    };
  in
    with builtins; attrValues (
      mapAttrs (n: o: { options.''${n} = o // wrapOpts o; })
        (import ${builtins.toFile "merged-options.nix"
          (optsToPretty (recursiveUpdate (pkgs.nixos {}).options options))
        })
    )
  '';
in

{
  nix.nixPath = [ "nixpkgs/nixos/modules=${modules}" ];
}

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
      length (optionAttrSetToDocList o) > 1
    ) {
      val = optsToPretty (t.getSubOptions o.loc);
      __pretty = opts: "_:\n${opts} # ${o}\n";
    };
  };

  optsToPretty = opts:
  let
    optToPretty = o:
      head (optionAttrSetToDocList o) // {
        inherit (o) _type declarationPositions;
        type = typeToPretty o o.type;
        default = null;
      };
  in
    generators.toPretty { allowPrettyValues = true; } (
      if isOption opts then optToPretty opts
      else mapAttrsRecursiveCond (v: !isOption v)
        (_: optToPretty) (removeAttrs opts [ "_module" ])
    );

  modules = pkgs.writeTextDir "module-list.nix" ''
    [{
      options = ${optsToPretty (
        mapAttrsRecursiveCond (v: !isOption v) (_: o: o // {
          type = types.submodule {} // { getSubOptions = _: o; };
        }) (recursiveUpdate (pkgs.nixos {}).options options)
      )};
    }]
  '';
in

{
  home.packages = with pkgs; [ nixd ];
  nix.nixPath = [ "nixpkgs/nixos/modules=${modules}" ];
}

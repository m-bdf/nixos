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
      length (optionAttrSetToDocList o) > 1
    ) {
      val = optsToPretty (t.getSubOptions o.loc);
      __pretty = opts: "_: ${opts}";
    };
  };

  optToPretty = o:
    head (optionAttrSetToDocList o) // {
      inherit (o) _type declarationPositions;
      type = typeToPretty o o.type;
      default = null;
    };

  optsToPretty = opts:
    generators.toPretty { multiline = false; allowPrettyValues = true; }
      (mapAttrsRecursiveCond (v: !isOption v) (_: optToPretty) opts);

  mergedOptions = pkgs.writeText "merged-options.nix"
    (optsToPretty (recursiveUpdate (pkgs.nixos {}).options options));

  nixd = pkgs.writeShellScriptBin "nixd" ''
    exec ${getExe pkgs.nixd} "$@" \
      --nixos-options-expr='import ${mergedOptions}'
  '';
in

{
  home.packages = [ nixd ];
}

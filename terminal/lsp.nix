{ options, lib, pkgs, ... }:

with lib;

let
  typeToPretty = o: t: {
    inherit (t) name description;

    nestedTypes.elemType = mapNullable (t:
      optionalAttrs (t.name != o.type.name) (typeToPretty o t)
    ) t.nestedTypes.elemType or null;

    getSubOptions =
      optionalAttrs (o.visible or true == true) {
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

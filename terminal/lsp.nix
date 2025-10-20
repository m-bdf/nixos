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
        val = removeAttrs (t.getSubOptions o.loc) [ "if" "inherit" ]; # tmp
        __pretty = opts: "_: ${optsToPretty opts}";
      };
  };

  optToPretty = o:
    optionalAttrs (!o.internal or false)
      (head (optionAttrSetToDocList o) // {
        inherit (o) _type declarationPositions;
        type = typeToPretty o o.type;
      });

  optsToPretty = opts:
    generators.toPretty { multiline = false; allowPrettyValues = true; }
      (mapAttrsRecursiveCond (v: !isOption v) (_: optToPretty) opts);

  nixd = pkgs.writeShellScriptBin "nixd" ''
    exec ${getExe pkgs.nixd} "$@" --nixos-options-expr='import ${
      pkgs.writeText "merged-options.nix"
        (optsToPretty (recursiveUpdate (pkgs.nixos {
          system.stateVersion = lib.trivial.release;
        }).options options))
    }'
  '';
in

{
  home.packages = [ nixd ];
}

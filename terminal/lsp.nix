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
        inherit (o) _type;
        type = typeToPretty o o.type;
        default = null;
      };
  in
    generators.toPretty { allowPrettyValues = true; }
      (mapAttrsRecursiveCond (v: !isOption v) (_: optToPretty) opts);

  mergedOptions = pkgs.writeText "merged-options.nix"
    (optsToPretty (recursiveUpdate (pkgs.nixos {}).options options));

  nixd = pkgs.nixd.overrideAttrs (prev: {
    nativeBuildInputs = prev.nativeBuildInputs ++ [ pkgs.makeBinaryWrapper ];
    postFixup = ''
      wrapProgram $out/bin/nixd \
        --add-flag --nixos-options-expr='import ${mergedOptions}'
    '';
  });
in

{
  home.packages = [ nixd ];
}

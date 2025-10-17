{ options, lib, pkgs, ... }:

let
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
      val = optsToPretty (t.getSubOptions o.loc);
      __pretty = subOpts: "_:\n${subOpts} # ${o}\n";
    };
  };

  optsToPretty = opts:
  let
    docs = lib.listToAttrs (
      map (doc: doc // { value = doc; })
        (lib.optionAttrSetToDocList opts)
    );

    prettyOpts =
      lib.mapAttrsRecursiveCond (v: !lib.isOption v)
        (_: o: docs.${toString o} // {
          inherit (o) _type declarationPositions;
          type = typeToPretty o o.type;
          default = null;
        })
        (lib.removeAttrs opts [ "_module" ]);
  in
    lib.generators.toPretty {
      allowPrettyValues = true;
    } prettyOpts;

  modules = pkgs.writeTextDir "module-list.nix" ''
    let
      mkModule = n: o:
        { lib, ... }:

        {
          options.''${n} =
            if lib.isOption o then o
            else lib.mkOption {
              type = lib.mkOptionType {
                name = "submodule";
                getSubOptions = _: o;
              };
            };
        };
    in
      builtins.attrValues (
        builtins.mapAttrs mkModule
          (import ${
            pkgs.writeText "merged-options.nix" (optsToPretty
              (lib.recursiveUpdate (pkgs.nixos {}).options options)
            )
          })
      )
  '';
in

{
  nix.nixPath = [ "nixpkgs/nixos/modules=${modules}" ];
}

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
      val = optsToPretty o (t.getSubOptions o.loc);
      __pretty = subOpts: "_: import ${subOpts}";
    };
  };

  optsToPretty = o: opts:
  let
    prettyOpts =
      lib.mapAttrsRecursiveCond (v: !lib.isOption v)
        (_: o: {
          inherit (o) _type declarationPositions;
          description = o.description or null;
          type = typeToPretty o o.type;
        })
        (lib.removeAttrs opts [ "_module" ]);
  in
    pkgs.writeText "${o}-options.nix" (
      lib.generators.toPretty {
        allowPrettyValues = true;
      } prettyOpts
    );

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
          (import ${optsToPretty "merged"
            (lib.recursiveUpdate (pkgs.nixos {}).options options)
          })
      )
  '';
in

{
  nix.nixPath = [ "nixpkgs/nixos/modules=${modules}" ];
}

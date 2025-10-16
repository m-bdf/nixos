{ options, lib, pkgs, ... }:

let
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
      val = optsToPretty o (t.getSubOptions o.loc);
      __pretty = subOpts: "_: import ${subOpts}";
    };
  };

  optsToPretty = o: opts: pkgs.writeText "${o}.nix"
    (lib.generators.toPretty { allowPrettyValues = true; }
      (lib.mapAttrsRecursiveCond (v: !lib.isOption v)
        (_: o: {
          inherit (o) _type declarationPositions;
          description = o.description or null;
          type = typeToPretty o o.type;
        })
        (lib.removeAttrs opts [ "_module" ])
      )
    );

  modules = pkgs.writeTextDir "module-list.nix" ''
    [{
      options = builtins.mapAttrs
        (_: opts: {
          _type = "option";
          type = {
            name = "submodule";
            getSubOptions = _: opts;
            deprecationMessage = null;
          };
        })
        (import ${optsToPretty "merged-options"
          (lib.recursiveUpdate (pkgs.nixos {}).options options)
        });
    }]
  '';
in

{
  nix.nixPath = [ "nixpkgs/nixos/modules=${modules}" ];
}

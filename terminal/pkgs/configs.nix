path:

with builtins;

let
  flake =
    if pathExists (path + /flake.nix)
    then getFlake (toString path) else {};

  pkgs = import flake.inputs.nixpkgs or <nixpkgs> {};
  hm = import flake.inputs.home-manager or <home-manager> { inherit pkgs; };

  defaultNixOS = pkgs.nixos hm.nixos;
  defaultHM.options =
    defaultNixOS.options.home-manager.users.type.getSubOptions [];

  customConfigs = concatMap attrValues [
    flake.homeConfigurations or {}
    flake.nixOnDroidConfigurations or {}
    flake.nixosConfigurations or {}
  ];

  configsForCurrentSystem =
    filter (c: (tryEval
      (c.pkgs.stdenv.system == currentSystem)
    ).value) customConfigs;

  mergeConfigs = zipAttrsWith (_: l:
    if any (v: !isAttrs v || v ? _type) l
    then head l else mergeConfigs l
  );
in

if configsForCurrentSystem == []
then mergeConfigs [ defaultHM defaultNixOS ]
else mergeConfigs configsForCurrentSystem

cwd:

with builtins;

let
  flake =
    if pathExists (cwd + /flake.nix)
    then getFlake (toString cwd) else {};

  pkgs = import flake.inputs.nixpkgs or <nixpkgs> {};
  hm = import flake.inputs.home-manager or <home-manager> { inherit pkgs; };

  nixos = pkgs.nixos hm.nixos;
  home-manager.options =
    nixos.options.home-manager.users.type.getSubOptions [];
in

with pkgs.lib;

let
  concatMapAttrsCond = pred: f:
    concatMapAttrs (n: v: if pred v then f n v else {});

  findConfigs =
    concatMapAttrsCond isAttrs (n':
      concatMapAttrsCond (isType "configuration")
        (n: v: { "${n'}.${n}" = v; })
    );

  configs = findConfigs flake //
    { inherit nixos home-manager; };

  nixpkgs = foldlAttrs (pkgs: n: v:
    recursiveUpdate pkgs v.pkgs or {}
  ) {} configs;

  options = mapAttrs (n: v:
    setType "options" v.options or {}
  ) configs;

  mkRecursive =
    mapAttrsRecursiveCond (v: !v ? _type) (p: v: v // {
      outPath.expr =
        "(import ${__curPos.file} ./.).${showAttrPath p}";
    });
in

mkRecursive { inherit nixpkgs options; }

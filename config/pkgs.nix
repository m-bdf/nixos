{ inputs, lib, modulesPath, ... }:

{
  imports = [ /${modulesPath}/profiles/perlless.nix ];

  system.forbiddenDependenciesRegexes = lib.mkForce [];

  nixpkgs = {
    flake.source = lib.mkForce inputs.nixpkgs.outPath;

    overlays = [ inputs.tisnix.overlays.tisnix ];

    config = {
      warnUndeclaredOptions = true;

      allowAliases = false;
      allowUnfree = true;
      checkMeta = true;
    };
  };
}

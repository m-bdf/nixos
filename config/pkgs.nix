{ lib, modulesPath, ... }:

{
  imports = [ /${modulesPath}/profiles/perlless.nix ];

  system.forbiddenDependenciesRegexes = lib.mkForce [];

  nixpkgs.config = {
    warnUndeclaredOptions = true;

    allowAliases = false;
    allowUnfree = true;
    checkMeta = true;

    doCheckByDefault = true;
    strictDepsByDefault = true;
    structuredAttrsByDefault = true;
    enableParallelBuildingByDefault = true;
    configurePlatformsByDefault = true;
    # contentAddressedByDefault = true;

    # replaceStdenv = { pkgs }: pkgs.zigStdenv;
  };
}

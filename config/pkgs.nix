{ lib, modulesPath, ... }:

{
  imports = [ /${modulesPath}/profiles/perlless.nix ];

  system.forbiddenDependenciesRegexes = lib.mkForce [];

  nixpkgs.config = {
    warnUndeclaredOptions = true;

    allowAliases = false;
    allowUnfree = true;
    checkMeta = true;

    replaceStdenv = { pkgs }: pkgs.zigStdenv.override (prev: {
      config = lib.mapAttrs (name: value:
        if lib.hasSuffix "ByDefault" name then true else value
      ) prev.config;
    });
  };
}

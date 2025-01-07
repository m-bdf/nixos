{ lib, modulesPath, ... }:

{
  imports = [ /${modulesPath}/profiles/perlless.nix ];

  system.forbiddenDependenciesRegexes = lib.mkForce [];

  nixpkgs = {
    config = {
      warnUndeclaredOptions = true;

      allowAliases = false;
      allowUnfree = true;
      checkMeta = true;

      replaceStdenv = { pkgs }: pkgs.stdenv;
    };

    overlays = [
      (final: prev:
        lib.optionalAttrs (prev.config ? replaceStdenv) prev.pkgsZig.pkgsMusl
      )
    ];
  };
}

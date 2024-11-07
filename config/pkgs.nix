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

      replaceStdenv = { pkgs }: pkgs.stdenv.override (prev: {
        config = lib.mapAttrs (name: value:
          if lib.hasSuffix "ByDefault" name then true else value
        ) prev.config;
      });
    };

    overlays = [
      (final: prev: lib.optionalAttrs (prev.config ? replaceStdenv) prev.pkgsZig)
    ];
  };
}

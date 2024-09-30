{ lib, pkgs, modulesPath, ... }:

{
  imports = [ /${modulesPath}/profiles/perlless.nix ];

  system = {
    forbiddenDependenciesRegexes = lib.mkForce [];
    stateVersion = lib.trivial.release;
  };

  nixpkgs = {
    config = {
      allowAliases = false;
      allowUnfree = true;
    };

    overlays = [
      (final: prev: {
        nix = final.nixVersions.latest;
      })
    ];
  };

  nix.settings = {
    use-xdg-base-directories = true;
    experimental-features =
    let
      xp-features = pkgs.runCommandLocal "dump-xp-features" {}
        "${lib.getExe pkgs.nix} __dump-xp-features > $out";
    in
      lib.attrNames (lib.importJSON xp-features);
  };

  xdg.dirs = {
    data.nix.persist = true; # REPL history
    cache.nix.persist = true; # tarballs
  };
}

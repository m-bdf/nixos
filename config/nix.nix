{ lib, pkgs, nixpkgs, ... }:

{
  system.stateVersion = lib.trivial.release;

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

  nix = {
    registry.nixpkgs.flake = nixpkgs;
    nixPath = [ "nixpkgs=${nixpkgs}" ];

    settings = {
      use-xdg-base-directories = true;
      experimental-features =
      let
        xp-features = pkgs.runCommandLocal "dump-xp-features" {}
          "${lib.getExe pkgs.nix} __dump-xp-features > $out";
      in
        lib.attrNames (lib.importJSON xp-features);
    };
  };

  xdg.dirs = {
    cache.nix.persist = true; # tarballs
    data.nix.persist = true; # REPL history
  };
}

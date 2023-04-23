{ lib, pkgs, nixpkgs, ... }:

{
  system.stateVersion = lib.trivial.release;

  nixpkgs = {
    config.allowUnfree = true;

    overlays = [
      (final: prev: {
        nix = final.nixVersions.unstable;
      })
    ];
  };

  nix = {
    registry.nixpkgs.flake = nixpkgs;
    nixPath = [ "nixpkgs=${nixpkgs}" ];

    settings = {
      experimental-features = "nix-command flakes";
      use-xdg-base-directories = true;
    };
  };

  xdg.dirs = {
    cache.nix.create = true; # tarballs
    data.nix.persist = true; # REPL history
  };
}

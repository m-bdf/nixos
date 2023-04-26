{ lib, pkgs, nixpkgs, ... }:

{
  system.stateVersion = lib.trivial.release;

  nixpkgs.overlays = [
    (final: prev: {
      nix = final.nixVersions.unstable;
    })
  ];

  nix = {
    registry.nixpkgs.flake = nixpkgs;
    nixPath = [ "nixpkgs=${nixpkgs}" ];
    settings.use-xdg-base-directories = true;
  };

  xdg.dirs = {
    cache.nix.create = true; # tarballs
    data.nix.persist = true; # REPL history
  };
}

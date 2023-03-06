{ lib, nixpkgs, ... }:

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

  xdg.basedirs = {
    cache.nix.persist = true; # tarballs
    data.nix.persist = true; # REPL history
  };
}

{ lib, pkgs, nixpkgs, ... }:

{
  system.stateVersion = lib.trivial.release;

  nix = {
    package = pkgs.nixUnstable;
    settings.use-xdg-base-directories = true;
    registry.nixpkgs.flake = nixpkgs;
    nixPath = [ "nixpkgs=${nixpkgs}" ];
  };

  xdg.basedirs = {
    cache.nix.create = true;
    data.nix.persist = true;
  };
}

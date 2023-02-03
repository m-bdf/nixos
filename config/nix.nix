{ lib, nixpkgs, ... }:

{
  system.stateVersion = lib.trivial.release;

  nix = {
    registry.nixpkgs.flake = nixpkgs;
    nixPath = [ "nixpkgs=${nixpkgs}" ];
  };
}

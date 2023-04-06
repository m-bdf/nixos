{ lib, pkgs, nixpkgs, nix-monitored, ... }:

{
  system.stateVersion = lib.trivial.release;

  imports = [ nix-monitored.nixosModules.nix-monitored ];

  nix = {
    monitored = {
      enable = true;
      package = pkgs.nix-monitored.override { nix = pkgs.nixUnstable; };
    };

    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      use-xdg-base-directories = true;
    };

    registry.nixpkgs.flake = nixpkgs;
    nixPath = [ "nixpkgs=${nixpkgs}" ];
  };

  xdg.basedirs = {
    cache.nix.create = true;
    data.nix.persist = true;
  };
}

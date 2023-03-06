{ config, pkgs, nix-index-database, ... }:

{
  users.users.user.shell = pkgs.fish;

  programs = {
    fish = {
      enable = true;
      useBabelfish = true;
    };
    starship.enable = true;
    command-not-found.enable = false;
  };

  imports = [ nix-index-database.nixosModules.nix-index ];

  environment.systemPackages = [
    (pkgs.comma.override {
      nix-index-unwrapped = config.programs.nix-index.package;
    })
  ];

  xdg.basedirs = {
    config.fish.create = true; # variables
    data.fish.persist = true; # history
  };
}

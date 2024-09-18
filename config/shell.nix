{ lib, pkgs, nix-index-database, ... }:

{
  imports = [ nix-index-database.nixosModules.nix-index ];

  users.users.user.shell = pkgs.fish;

  programs = {
    fish = {
      enable = true;
      useBabelfish = true;
    };

    nix-index-database.comma.enable = true;

    starship = {
      enable = true;
      settings =
      let
        preset = pkgs.runCommandLocal "starship-nerd-font-preset" {}
          "${lib.getExe pkgs.starship} preset nerd-font-symbols > $out";
      in
        lib.importTOML preset // { command_timeout = 2500; };
    };
  };

  environment.sessionVariables.STARSHIP_CACHE = "/var/cache/starship"; #starship/896

  xdg.dirs = {
    data.fish.persist = true; # history
    config.fish.create = true; # variables
    cache.starship.create = true; # logs
  };
}

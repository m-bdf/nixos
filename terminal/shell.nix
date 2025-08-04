{ inputs, config, lib, pkgs, ... }:

{
  imports = [ inputs.nix-index-database.homeModules.nix-index ];

  programs = {
    fish = {
      enable = true;
      interactiveShellInit = "set fish_greeting";
    };

    starship = {
      enable = true;
      settings =
      let
        preset = pkgs.runCommandLocal "starship-nerd-font-preset" {}
          "${lib.getExe pkgs.starship} preset nerd-font-symbols > $out";
      in
        lib.importTOML preset // { command_timeout = 2500; };
    };

    nix-index-database.comma.enable = true;
  };

  home.sessionVariables.STARSHIP_CACHE =
    "${config.xdg.cacheHome}/starship"; #starship/896

  xdg = {
    dataFile.fish.persist = true; # history
    stateFile.comma.persist = true; # choices
  };
}

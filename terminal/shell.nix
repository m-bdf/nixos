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
      settings = { command_timeout = 2500; } // lib.importTOML
        (pkgs.starship + /share/starship/presets/nerd-font-symbols.toml);
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

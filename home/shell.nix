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
        (pkgs.starship.src + /docs/public/presets/toml/nerd-font-symbols.toml);
    };

    nix-index-database.comma.enable = true;

    nix-your-shell = {
      enable = true;
      nix-output-monitor.enable = true;
    };
  };

  home.sessionVariables.STARSHIP_CACHE =
    "${config.xdg.cacheHome}/starship"; #starship/896

  xdg = {
    dataFile.fish.persist = true; # history
    stateFile.comma.persist = true; # choices
  };
}

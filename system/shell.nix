{ inputs, pkgs, ... }:

{
  imports = [ inputs.nix-index-database.nixosModules.nix-index ];

  users.users.user.shell = pkgs.fish;

  programs = {
    fish = {
      enable = true;
      useBabelfish = true;
      interactiveShellInit = "set fish_greeting";
    };

    starship = {
      enable = true;
      presets = [ "nerd-font-symbols" ];
      settings.command_timeout = 2500;
    };

    nix-index-database.comma.enable = true;
  };

  environment.variables.STARSHIP_CACHE = "$XDG_CACHE_HOME/starship"; #starship/896

  home.xdg = {
    dataFile.fish.persist = true; # history
    stateFile.comma.persist = true; # choices
  };
}

{ inputs, pkgs, ... }:

{
  imports = [ inputs.nix-index-database.homeModules.nix-index ];

  programs = {
    fish = {
      enable = true;
      package = pkgs.fishMinimal;
      interactiveShellInit = "set fish_greeting";
      preferAbbrs = true;
    };

    starship = {
      enable = true;
      presets = [ "nerd-font-symbols" ];
      settings.command_timeout = 2500;
    };

    nix-index-database.comma.enable = true;

    nix-your-shell = {
      enable = true;
      nix-output-monitor.enable = true;
    };

    eza = {
      enable = true;
      extraOptions = [
        "--header" "--icons" "--hyperlink"
        "--smart-group" "--git" "--mounts"
      ];
    };

    man.generateCaches = false;
  };

  home = {
    sessionVariables.STARSHIP_CACHE =
      "$XDG_CACHE_HOME/starship"; #starship/896

    packages = with pkgs; [ fd ripgrep sd ];
  };

  xdg = {
    configFile."eza/theme.yml".source =
      inputs.eza-themes + /themes/dracula.yml;

    dataFile.fish.persist = true; # history
    stateFile.comma.persist = true; # choices
  };
}

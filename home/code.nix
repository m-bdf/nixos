{ pkgs, ... }:

{
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      silent = true;
      config.global.warn_timeout = 0;
      stdlib = ''
        hash=($(cksum <<< $PWD))
        direnv_layout_dir="$XDG_DATA_HOME/direnv/layouts/$hash"
      '';
    };

    git = {
      lfs.enable = true;
      package = pkgs.gitMinimal;
      settings.user = {
        name = "Maëlys Bras de fer";
        email = "mae.bdf@outlook.com";
      };
    };

    difftastic = {
      enable = true;
      git.enable = true;
      options = {
        background = "dark";
        display = "inline";
      };
    };

    helix = {
      enable = true;
      defaultEditor = true;
      settings.theme = "github_dark";
    };
  };

  xdg.dataFile.direnv.persist = true;
}

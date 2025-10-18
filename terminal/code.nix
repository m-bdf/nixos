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
      enable = true;
      lfs.enable = true;
      package = pkgs.gitMinimal;

      userName = "Maëlys Bras de fer";
      userEmail = "mae.bdf@outlook.com";

      difftastic = {
        enable = true;
        enableAsDifftool = true;
        options = {
          background = "dark";
          display = "inline";
        };
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

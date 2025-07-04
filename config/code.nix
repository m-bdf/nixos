{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [ vscode nixd github-desktop ];
    sessionVariables.VSCODE_PORTABLE = "/usr/share/vscode"; #vscode/3884
  };

  programs = {
    direnv = {
      enable = true;
      silent = true;
      settings.global.warn_timeout = 0;
      direnvrcExtra = ''
        HASH=$(sha256sum <<< "$PWD" | cut -d' ' -f1)
        direnv_layout_dir="$XDG_DATA_HOME/direnv/layouts/$HASH"
      '';
    };

    git = {
      enable = true;
      lfs.enable = true;
      package = pkgs.gitMinimal;

      config = {
        user = {
          name = "Maëlys Bras de fer";
          email = "mae.bdf@outlook.com";
        };
        diff.external = "difft";
      };
    };
  };

  xdg.dirs = {
    data = {
      direnv.persist = true;
      vscode.persist = true;
      keyrings.persist = true;
    };
    config."GitHub Desktop".persist = true;
    cache.pre-commit.create = true;
  };
}

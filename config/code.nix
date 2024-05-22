{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [ vscode nil github-desktop ];
    sessionVariables.VSCODE_PORTABLE = "/usr/share/vscode"; #vscode/3884

    variables.FILTER_BRANCH_SQUELCH_WARNING = "1";
  };

  programs.git = {
    enable = true;
    lfs.enable = true;

    config = [{
      user = {
        name = "Maëlys Bras de fer";
        email = "mae.bdf@outlook.com";
      };

      alias.reset-commiter-date = "filter-branch --force " +
        "--env-filter 'export GIT_COMMITTER_DATE=$GIT_AUTHOR_DATE'";
    }];
  };

  services.gnome.gnome-keyring.enable = true;

  xdg.dirs = {
    data = {
      vscode.persist = true;
      keyrings.persist = true;
    };
    config."GitHub Desktop".persist = true;
  };
}

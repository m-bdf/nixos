{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [ github-desktop vscode nixd ];
    sessionVariables.VSCODE_PORTABLE = "/usr/share/vscode"; #vscode/3884
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    config = [{
      user = {
        name = "Maëlys Bras de fer";
        email = "mae.bdf@outlook.com";
      };
    }];
  };

  services.gnome.gnome-keyring.enable = true;

  xdg.dirs = {
    config."GitHub Desktop".persist = true;
    data = {
      vscode.persist = true;
      keyrings.persist = true;
    };
  };
}

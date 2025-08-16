{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [ vscode nixd github-desktop ];
    variables.VSCODE_PORTABLE = "$XDG_DATA_HOME/vscode"; #vscode/3884
  };

  home.xdg = {
    configFile."GitHub Desktop".persist = true;
    dataFile = {
      vscode.persist = true;
      keyrings.persist = true;
    };
  };
}

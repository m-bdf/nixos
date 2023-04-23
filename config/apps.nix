{ pkgs, ... }:

let
  utils = pkgs.uutils-coreutils.override { prefix = null; };
in

{
  environment = {
    defaultPackages = [];
    systemPackages = with pkgs;
      [ utils xdg-utils git github-desktop helix vscode brave ];

    variables = {
      EDITOR = "hx";
      NIXOS_OZONE_WL = "1";
    };
    sessionVariables = {
      VSCODE_PORTABLE = "/usr/share/vscode"; #vscode/3884
    };
  };

  services.gnome.gnome-keyring.enable = true;

  xdg.dirs = {
    config = {
      "GitHub Desktop".persist = true;
      "BraveSoftware/Brave-Browser".persist = true;
    };
    cache = {
      helix.create = true; # logs
      "BraveSoftware/Brave-Browser".create = true;
    };
    data = {
      vscode.persist = true;
      keyrings.persist = true;
    };
  };
}

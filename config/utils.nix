{ lib, pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs;
    let
      xdg-open = writeShellScriptBin "xdg-open" ''
        filetype=$(xdg-mime query filetype "$1" 2>/dev/null)
        app=$(xdg-mime query default $filetype 2>/dev/null)
        uwsm app -- $app "$@"
      '';
    in
      [ uutils-coreutils-noprefix fd ripgrep xdg-open helix ghostty brave ];

    variables.EDITOR = "hx";

    etc = {
      "xdg/ghostty/config".text = ''
        resize-overlay = never
        app-notifications = false
        confirm-close-surface = false
      '';

      "xdg/walker/config.toml".text = ''
        app_launch_prefix = "uwsm app -- "
      '';
    };
  };

  programs.niri.bindings."Mod+Return" = "spawn \"${lib.getExe pkgs.walker}\"";

  xdg = {
    terminal-exec = {
      enable = true;
      package = pkgs.writeShellScriptBin "xdg-terminal-exec" ''
        uwsm app -T -- "$@"
      '';
    };

    dirs = {
      config = {
        walker.create = true;
        "BraveSoftware/Brave-Browser".persist = true;
      };
      cache = {
        helix.create = true;
        walker.create = true;
        ghostty.create = true;
        "BraveSoftware/Brave-Browser".create = true;
      };
    };
  };
}

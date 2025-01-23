{ lib, pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs;
    let
      xdg-open = writeShellScriptBin "xdg-open" ''
        filetype=$(xdg-mime query filetype "$1" 2>/dev/null)
        app=$(xdg-mime query default $filetype 2>/dev/null)
        exec uwsm app -- $app "$@"
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

      "xdg/fuzzel/fuzzel.ini".text = ''
        show-actions = true
        launch-prefix = uwsm app --
        terminal = xdg-terminal-exec
      '';
    };
  };

  programs.niri.bindings."Mod+Return" = "spawn \"${lib.getExe pkgs.fuzzel}\"";

  xdg = {
    terminal-exec = {
      enable = true;
      package = pkgs.writeShellScriptBin "xdg-terminal-exec" ''
        exec uwsm app -T -- "$@"
      '';
    };

    dirs = {
      config."BraveSoftware/Brave-Browser".persist = true;
      cache = {
        helix.create = true;
        ghostty.create = true;
        "BraveSoftware/Brave-Browser".create = true;
      };
    };
  };
}

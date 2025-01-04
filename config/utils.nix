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
      [ uutils-coreutils-noprefix fd ripgrep xdg-open helix kitty brave ];

    variables.EDITOR = "hx";

    etc = {
      "xdg/kitty/kitty.conf".text = ''
        shell_integration enabled
        enable_audio_bell no
        confirm_os_window_close 0
      '';

      "xdg/fuzzel/fuzzel.ini".text = ''
        show-actions = true
        launch-prefix = uwsm app --
        terminal = xdg-terminal-exec
      '';
    };
  };

  programs.river.bindings = [{
    mod = "Super";
    key = "Return";
    cmd = lib.getExe pkgs.fuzzel;
  }];

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
        kitty.create = true;
        "BraveSoftware/Brave-Browser".create = true;
      };
    };
  };
}

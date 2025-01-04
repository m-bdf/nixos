{ lib, pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs;
    let
      xdg-open = writeShellScriptBin "xdg-open" ''
        ${lib.getExe mimeo} "$@" \
          ''${WAYLAND_DISPLAY+ --cmd-prefix uwsm-app --term '-T %s'}
      '';
    in
      [ uutils-coreutils-noprefix fd ripgrep xdg-open helix kitty brave ];

    variables.EDITOR = "hx";

    etc."xdg/kitty/kitty.conf".text = ''
      shell_integration enabled
      enable_audio_bell no
      confirm_os_window_close 0
    '';
  };

  programs.river.bindings = [{
    mod = "Super";
    key = "Return";
    cmd = "${lib.getExe pkgs.fuzzel} --launch-prefix uwsm-app --terminal -T";
  }];

  xdg = {
    terminal-exec = {
      enable = true;
      package = pkgs.writeShellScriptBin "xdg-terminal-exec" ''
        uwsm-app -T -- "''${@-$SHELL}"
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

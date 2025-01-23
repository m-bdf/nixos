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
      [ uutils-coreutils-noprefix fd ripgrep xdg-open helix ghostty brave ];

    variables.EDITOR = "hx";

    etc."xdg/ghostty/config".text = ''
      gtk-single-instance = true
      linux-cgroup-hard-fail = true
      confirm-close-surface = false
    '';
  };

  programs.niri.bindings."Mod+Return" =
    "${lib.getExe pkgs.fuzzel} --launch-prefix uwsm-app --terminal -T";

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
        ghostty.create = true;
        "BraveSoftware/Brave-Browser".create = true;
      };
    };
  };
}

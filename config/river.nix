{ config, pkgs, ... }:

let
  riverNoX = pkgs.river.override { xwaylandSupport = false; };

  init =
  let
    inherit (config.environment) defaultTerminal defaultBrowser;
  in
    pkgs.writeShellScript "init" ''
      target=wayland-instance@$WAYLAND_DISPLAY.target
      trap "systemctl --user stop $target" TERM
      systemctl --user start $target

      riverctl map normal Alt Return spawn "${defaultTerminal}"
      riverctl map normal Super Return spawn "${defaultBrowser}"

      riverctl map normal Alt Tab zoom
      riverctl map normal Alt Backspace close
      riverctl map normal Super Escape exit

      riverctl default-layout rivertile
      rivertile
    '';
in

{
  environment = {
    systemPackages = [ riverNoX ];
    etc."river/init".source = init;
  };

  security.polkit.enable = true;
  hardware.opengl.enable = true;

  systemd.user.targets."wayland-instance@" = {
    description = "Wayland instance for WAYLAND_DISPLAY=%i";
    documentation = [ "man:systemd.special(7)" ];

    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
  };
}

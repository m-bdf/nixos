{ config, lib, pkgs, ... }:

let
  riverNoX = pkgs.river.override { xwaylandSupport = false; };

  init =
  let
    inherit (config.environment) defaultTerminal defaultBrowser;
  in
    pkgs.writeShellScript "init" ''
      target="wayland-instance@$WAYLAND_DISPLAY.target"
      trap "systemctl --user stop $target" TERM
      systemctl --user start $target

      riverctl map normal Alt Return spawn "${defaultTerminal}"
      riverctl map normal Super Return spawn "${defaultBrowser}"

      riverctl map normal Alt Tab zoom

      for i in $(seq 1 9); do
        tags=$((1 << ($i - 1)))
        riverctl map normal Alt $i set-focused-tags $tags
        riverctl map normal Super $i set-view-tags $tags
      done

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

  hardware.opengl.enable = true;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    #pulse.enable = true;
  };

  xdg.portal = {
    wlr.enable = true;
    #gtkUsePortal = true;
  };

  services = {
    localtimed.enable = true;
  };
  location.provider = "geoclue2";

  systemd.user.targets = {
    graphical-session = lib.mkForce {}; #26094

    "wayland-instance@" = {
      description = "Wayland instance for WAYLAND_DISPLAY=%i";
      documentation = [ "man:systemd.special(7)" ];

      bindsTo = [ "graphical-session.target" ];
      wants = [ "graphical-session-pre.target" ];
      after = [ "graphical-session-pre.target" ];
    };
  };
}

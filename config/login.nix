{ lib, pkgs, ... }:

{
  services = {
    kmscon = {
      enable = true;
      hwRender = true;
    };

    dbus.implementation = "broker";

    greetd = {
      enable = true;
      settings.default_session.command = lib.getExe pkgs.westonLite;
    };
  };

  environment.etc = {
    "xdg/weston/weston.ini".text = ''
      [core]
      shell=kiosk

      [libinput]
      enable-tap=true

      [autolaunch]
      path=${lib.getExe pkgs.greetd.gtkgreet}
      watch=true
    '';

    "greetd/environments".text = "niri-session";
  };

  programs.niri.bindings."Mod+Escape" = "quit";
}

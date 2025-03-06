{ lib, pkgs, ... }:

{
  services = {
    logind = {
      lidSwitch = "ignore";
      powerKey = "hybrid-sleep";
    };
    upower.enable = true;

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

  programs = {
    gtklock = {
      enable = true;
      modules = with pkgs; [
        gtklock-powerbar-module
        gtklock-playerctl-module
      ];
    };

    niri.bindings = {
      XF86AudioMedia = "spawn \"gtklock\"";
      "Mod+Escape" = "quit";
    };
  };

  xdg.dirs.state.fprint.persist = true;
}

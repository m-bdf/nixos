{ lib, pkgs, cage-kiosk, ... }:

{
  boot = {
    plymouth.enable = true;
    kernelParams = [ "quiet" ];
  };

  services = {
    kmscon = {
      enable = true;
      hwRender = true;
    };

    logind = {
      lidSwitch = "ignore";
      #powerKey = "hybrid-sleep";
    };
    upower.enable = true;

    dbus.implementation = "broker";
  };

  services.greetd = {
    enable = true;
    settings.default_session.command =
    let
      cage =
        (pkgs.cage.override {
          xwayland = null;
          wlroots = pkgs.wlroots_0_16;
        }).overrideAttrs (old: {
          src = cage-kiosk;
        });
    in
      "${lib.getExe cage} -s ${lib.getExe pkgs.greetd.regreet}";
  };
}

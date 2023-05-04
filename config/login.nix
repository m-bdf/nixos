{ lib, pkgs, ... }:

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
      powerKey = "hybrid-sleep";
    };
    upower.enable = true;

    dbus.implementation = "broker";

    greetd.settings.default_session.command =
    let
      cage = pkgs.cage.override { xwayland = null; };
    in
      "${lib.getExe cage} -sdm last ${lib.getExe pkgs.greetd.regreet}";
  };

  programs.regreet.enable = true;
  xdg.dirs.cache.regreet.persist = true;
}

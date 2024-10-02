{ config, lib, pkgs, ... }:

{
  boot = {
    plymouth.enable = true;
    kernelParams = [ "quiet" ];
  };

  services = {
    logind = {
      lidSwitch = "ignore";
      powerKey = "hybrid-sleep";
    };
    upower.enable = true;

    kmscon = {
      enable = true;
      hwRender = true;
    };

    greetd = {
      enable = true;
      settings.default_session.command =
        "${lib.getExe pkgs.cage} -sdm last ${lib.getExe pkgs.greetd.gtkgreet}";
    };
  };

  environment.etc."greetd/environments".text =
    lib.concatMapStrings (session: "uwsm start ${session}\n")
      config.services.displayManager.sessionData.sessionNames;

  systemd.user.services."wayland-wm-env@" = {
    path = config.services.displayManager.sessionPackages;
    overrideStrategy = "asDropin";
  };

  programs.uwsm = {
    enable = true;
    waylandCompositors = {};
  };
}

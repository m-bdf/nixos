{ config, lib, pkgs, ... }:

{
  console.enable = false;
  boot = {
    kernelParams = [ "quiet" "fbcon=map:null" ];

    plymouth = {
      enable = true;
      theme = "blahaj";
      themePackages = [ pkgs.plymouth-blahaj-theme ];
    };

    initrd.services.udev.packages = [
      (pkgs.writeTextDir "/etc/udev/rules.d/90-vconsole.rules" "")
    ];
  };

  services = {
    udev.packages = [
      (pkgs.writeTextDir "/etc/udev/rules.d/90-vconsole.rules" "")
    ];

    kmscon = {
      enable = true;
      hwRender = true;
    };

    greetd = {
      enable = true;
      settings.default_session = {
        user = config.users.users.user.name;
        command =
          "env MANAGERPID=$PPID ${lib.getExe pkgs.uwsm} aux exec ${
            config.services.displayManager.sessionData.autologinSession
          }.desktop";
      };
    };

    logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandlePowerKey = "hybrid-sleep";
    };
    upower.enable = true;
  };

  powerManagement.enable = false;
  users.manageLingering = false;
}

{ lib, pkgs, modulesPath, ... }:

{
  imports = [ /${modulesPath}/profiles/perlless.nix ];
  system.forbiddenDependenciesRegexes = lib.mkForce [];

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;

      systemd-boot = {
        enable = true;
        editor = false;
      };
      timeout = null;
    };

    plymouth.enable = true;
    kernelParams = [ "quiet" ];

    initrd = {
      systemd.emergencyAccess = true;
      includeDefaultModules = false;
    };

    kernelPackages = pkgs.linuxPackages_zen;
  };

  services = {
    fwupd.enable = true;
    dbus.implementation = "broker";

    kmscon = {
      enable = true;
      hwRender = true;
    };

    greetd = {
      enable = true;
      settings.default_session = {
        user = config.users.users.user.name;
        command = "niri-session";
      };
    };

    logind = {
      lidSwitch = "ignore";
      powerKey = "hybrid-sleep";
    };
    upower.enable = true;
  };
}

{ lib, pkgs, modulesPath, ... }:

{
  imports = [ /${modulesPath}/profiles/perlless.nix ];
  system.forbiddenDependenciesRegexes = lib.mkForce [];

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;

      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      timeout = null;
    };

    kernelPackages = pkgs.linuxPackages_zen;

    initrd = {
      includeDefaultModules = false;
      systemd.emergencyAccess = true;
    };
  };

  services.dbus.implementation = "broker";

  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
  preservation.preserveAt.state = {
    files = [{ file = "/etc/machine-id"; inInitrd = true; }];
    directories = [ "/var/log" ];
  };

  home.xdg.stateFile.systemd.persist = true;
}

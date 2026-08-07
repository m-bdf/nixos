{ lib, pkgs, modulesPath, ... }:

{
  imports = [ /${modulesPath}/profiles/perlless.nix ];
  system = {
    forbiddenDependenciesRegexes = lib.mkForce [];
    nixos-init.enable = true;
  };

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

    kernelParams = [ "systemd.machine_id=firmware" ];
  };

  home = {
    xdg.stateFile.systemd.persist = true;
    home.file."/var/log/journal".persist = true;
  };
}

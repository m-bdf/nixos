{ pkgs, ... }:

{
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;

      systemd-boot = {
        enable = true;
        configurationLimit = 3;
        editor = false;
      };
      timeout = null;
    };

    initrd = {
      systemd.emergencyAccess = true;
      includeDefaultModules = false;
    };

    plymouth.enable = true;
    kernelParams = [ "quiet" ];

    kernelPackages = pkgs.linuxPackages_zen;
  };

  services.fwupd.enable = true;
}

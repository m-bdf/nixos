{ pkgs, ... }:

{
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;

      systemd-boot = {
        enable = true;
        configurationLimit = 10;
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

  services.fwupd.enable = true;
}

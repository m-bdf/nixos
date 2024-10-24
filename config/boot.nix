{ pkgs, ... }:

{
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;

      systemd-boot = {
        enable = true;
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

{ pkgs, ... }:

{
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;

      systemd-boot = {
        enable = true;
        bootCounting.enable = true;
        editor = false;
      };
      timeout = null;
    };

    initrd = {
      systemd = {
        enable = true;
        emergencyAccess = true;
      };
      includeDefaultModules = false;
    };

    kernelPackages = pkgs.linuxPackages_zen;
  };

  services.fwupd.enable = true;
}

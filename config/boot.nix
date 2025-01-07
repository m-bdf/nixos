{ lib, pkgs, ... }:

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

    kernelPackages = pkgs.linuxPackagesFor
      (pkgs.linux_latest.override {
        # stdenv = pkgs.clangStdenv;
        extraMakeFlags = [ "LLVM=1" "KCFLAGS+=-O3" ];
        structuredExtraConfig.LTO_CLANG_FULL = lib.kernel.yes;
      });
  };

  services.fwupd.enable = true;
}

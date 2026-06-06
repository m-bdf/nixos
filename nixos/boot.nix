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
  };

  home.xdg.stateFile = {
    nixos = {
      persist = true;
      force = true;
    };
    systemd.persist = true;
  };

  preservation.preserveAt.state.directories = [ "/var/log" ];
}

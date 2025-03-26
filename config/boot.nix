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

    kernelPackages = pkgs.linuxPackages_latest;

    initrd = {
      includeDefaultModules = false;
      systemd.emergencyAccess = true;
      # verbose = false;
    };
    consoleLogLevel = 3; #0?
    kernelParams = [ "quiet" ];

    plymouth = {
      enable = true;
      theme = "blahaj";
      themePackages = [ pkgs.plymouth-blahaj-theme ];
    };
  };

  services = {
    fwupd.enable = true;
    dbus.implementation = "broker";
  };

  environment = {
    etc.machine-id.source = pkgs.runCommandLocal "machine-id" {
      nativeBuildInputs = [ pkgs.systemdMinimal ];
    } "systemd-machine-id-setup --root=/tmp --print > $out";

    persistence.storage.directories = [ "/var/log" ];
  };
}

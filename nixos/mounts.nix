{ config, lib, ... }:

let
  options = [ "nosuid" "nodev" "noexec" "noatime" ];
  buildDir = config.nix.settings.build-dir or "/nix/var/nix/builds";
in

{
  fileSystems = {
    "/" = {
      fsType = "tmpfs";
      options = options ++ [ "mode=755" ];
    };

    "/boot" = {
      label = "BOOT";
      fsType = "vfat";
      inherit options;
    };

    "/nix" = {
      label = "nixos";
      fsType = "ext4";
      inherit options;
    };

    ${buildDir} = {
      device = buildDir;
      fsType = "none";
      options = [ "bind" "exec" ];
    };
  };

  boot = {
    nixStoreMountOpts = [ "ro" "exec" ];
    tmp.useTmpfs = true;
  };

  preservation = {
    enable = true;
    preserveAt.state.persistentStoragePath = "/nix";
  };

  system.etc.overlay.mutable = false;

  systemd.mounts = [{
    where = config.home.xdg.configHome;
    what = "tmpfs";
    type = "tmpfs";
    options = lib.mkMerge options;
  }];

  swapDevices = [{ label = "swap"; }];
}

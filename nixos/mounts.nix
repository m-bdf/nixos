{ config, lib, ... }:

let
  options = [ "nosuid" "nodev" "noexec" "noatime" ];
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

    "/nix/var/nix/builds" = {
      fsType = "tmpfs";
      options = options ++ [ "exec" ];
    };
  };

  boot.nixStoreMountOpts = [ "exec" ];

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

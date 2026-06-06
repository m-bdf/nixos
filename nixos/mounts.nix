{ config, ... }:

{
  fileSystems =
  let
    options = [ "nosuid" "nodev" "noexec" "noatime" ];
  in
  {
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

    ${config.home.xdg.configHome} = {
      fsType = "tmpfs";
      inherit options;
    };
  };

  boot.nixStoreMountOpts = [ "exec" ];

  preservation = {
    enable = true;
    preserveAt.state.persistentStoragePath = "/nix";
  };

  system.etc.overlay.mutable = false;

  swapDevices = [{ label = "swap"; }];
}

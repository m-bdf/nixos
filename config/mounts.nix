{ config, ... }:

{
  fileSystems =
  let
    options = [ "nosuid" "nodev" "noexec" "noatime" ];
  in
    config.isWsl or
  {
    "/" = {
      fsType = "tmpfs";
      inherit options;
    };

    "/boot" = {
      label = "BOOT";
      inherit options;
    };

    "/nix" = {
      label = "nixos";
      fsType = "ext4";
      neededForBoot = true;
      options = options ++ [ "exec" ];
    };
  };

  boot.tmp.useTmpfs = true;

  swapDevices = [{ label = "swap"; }];
}

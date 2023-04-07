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
      neededForBoot = true;
      options = options ++ [ "exec" ];
    };
  };

  swapDevices = [{ label = "swap"; }];
}

{
  fileSystems =
  let
    options = [ "nosuid" "nodev" "noexec" "noatime" ];
  in
  {
    "/" = {
      fsType = "tmpfs";
      options = options ++ [ "size=1G" ];
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

  preservation = {
    enable = true;
    preserveAt.state.persistentStoragePath = "/nix";
  };

  boot = {
    devSize = "0";
    tmp = {
      useTmpfs = true;
      tmpfsSize = "100%";
    };
  };

  swapDevices = [{ label = "swap"; }];
}

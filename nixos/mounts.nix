{
  fileSystems =
  let
    options = [ "nosuid" "nodev" "noexec" "noatime" ];
  in
  {
    "/" = {
      fsType = "tmpfs";
      options = options ++ [ "size=1G" "mode=0755" ];
    };

    "/boot" = {
      label = "BOOT";
      inherit options;
    };

    "/nix" = {
      label = "nixos";
      fsType = "ext4";
      options = options ++ [ "exec" ];
    };
  };

  preservation = {
    enable = true;
    preserveAt.state = {
      persistentStoragePath = "/nix";
      commonMountOptions = [ "noexec" ];
    };
  };

  swapDevices = [{ label = "swap"; }];
}

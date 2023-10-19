{
  fileSystems =
  let
    options = [ "nosuid" "nodev" "noexec" "noatime" ];
  in
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

  environment.persistence.storage.persistentStoragePath = "/nix";

  boot.tmp.useTmpfs = true;

  swapDevices = [{ label = "swap"; }];
}

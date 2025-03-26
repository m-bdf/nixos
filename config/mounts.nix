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

  environment.persistence.storage.persistentStoragePath = "/nix";

  system.etc.overlay.mutable = false;

  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = "100%";
  };

  swapDevices = [{ label = "swap"; }];
}

{
    fileSystems = {
        "/".fsType = "tmpfs";
        "/boot".label = "BOOT";
        "/nix" = {
            label = "nixos";
            neededForBoot = true;
        };
    };

    swapDevices = [{ label = "swap"; }];

    boot.loader.systemd-boot.enable = true;
}

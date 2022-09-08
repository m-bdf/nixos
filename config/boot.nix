{
    fileSystems = {
        "/".fsType = "tmpfs";
        "/boot".label = "BOOT";
        "/nix".label = "nixos";
    };

    swapDevices = [{ label = "swap"; }];

    boot.loader.systemd-boot.enable = true;
}

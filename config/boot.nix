{
    fileSystems = {
        "/".fsType = "tmpfs";
        "/boot".label = "BOOT";
        "/nix".label = "nixos";
        "/home".label = "home";
    };

    swapDevices = [{ label = "swap"; }];

    boot.loader.systemd-boot.enable = true;
}

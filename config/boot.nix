{
    fileSystems = {
        "/".fsType = "tmpfs";
        "/boot".label = "BOOT";
        "/nix" = {
            label = "nixos";
            neededForBoot = true;
            options = [ "noatime" ];
        };
    };

    swapDevices = [{ label = "swap"; }];

    boot = {
        loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
        };
        initrd.includeDefaultModules = false;
    };
}

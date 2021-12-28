{
    fileSystems."/" = {
        device = "none";
        fsType = "tmpfs";
    };

    boot.loader.systemd-boot.enable = true;
}

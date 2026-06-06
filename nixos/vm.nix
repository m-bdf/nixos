{ options, lib, pkgs, ... }:

with lib;

let
  virt = options.virtualisation;
  interactive = virt.qemu.package.value != pkgs.qemu_test;
in

{
  config = optionalAttrs (virt ? qemu) {
    virtualisation = mkMerge [
      {
        cores = 4;
        memorySize = 4 * 1024;
        qemu.options = [
          "-machine memory-backend=mem"
          "-object memory-backend-memfd,id=mem,size=4G"
        ];

        diskImage = mkIf virt.directBoot.enable.value null;
        writableStoreUseTmpfs = false;
        msize = 500 * 1024;
      }

      (mkIf interactive {
        sharedDirectories.xchg = {
          source = mkForce ''"''${LOG_DIR:-xchg}"'';
          target = mkForce "/var/log";
        };
        fileSystems."/var/log".options = [ "cache=loose" ];

        qemu = {
          options = [
            "-display gtk,show-tabs=on,grab-on-hover=on,gl=on"
            "-device virtio-vga-gl,blob=on,hostmem=4G,venus=on"
            "-serial vc -parallel none"
          ];
          consoles = reverseList virt.qemu.consoles.default;
        };
      })
    ];

    system.etc.overlay.mutable = mkForce true;
    console.enable = mkForce true;
    boot.kernelParams = [
      "plymouth.ignore-serial-consoles"
      "plymouth.nolog"
    ];
  };
}

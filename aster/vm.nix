{ config, lib, ... }:

{
  virtualisation = {
    useEFIBoot = lib.mkForce true;
    efi.keepVariables = false;

    diskImage = null;
    useDefaultFilesystems = false;

    qemu = {
      drives = [{
        file = config.system.build.images.raw-efi + /nixos.img;

        driveExtraOpts = {
          readonly = "on";
          werror = "ignore";
        };
        deviceExtraOpts = {
          disable-legacy = "on";
          disable-modern = "off";
        };
      }];

      options = [
        "-display gtk,show-tabs=on,grab-on-hover=on -device virtio-vga"
        "-chardev stdio,id=mux,mux=on -serial chardev:mux -parallel none"
        "-device virtio-serial-pci -device virtconsole,chardev=mux"
        "-device isa-debug-exit,iobase=0xf4,iosize=0x04"
      ];
    };
  };
}

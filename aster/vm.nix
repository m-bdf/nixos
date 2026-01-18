{ inputs, options, lib, pkgs, ... }:

{
  virtualisation = lib.optionalAttrs (options.virtualisation ? qemu) {
    cores = 4;
    memorySize = 4 * 1024;

    writableStoreUseTmpfs = false;
    msize = 500 * 1024;

    qemu.options =
    let
      onlyModern = "disable-legacy=on,disable-modern=off";

      netOpts = pkgs.runCommandLocal "virtio-net-options" {} ''
        . ${inputs.asterinas}/tools/qemu_args.sh &>/dev/null
        echo ${onlyModern}$VIRTIO_NET_FEATURES > $out
      '';
    in
    [
      "-machine memory-backend=mem"
      "-object memory-backend-memfd,id=mem,size=4G"

      "-display gtk,show-tabs=on,grab-on-hover=on"
      "-device virtio-vga,${onlyModern}"

      "-chardev stdio,id=mux,mux=on"
      "-serial chardev:mux -parallel none"

      "-device virtio-serial-pci,${onlyModern}"
      "-device virtconsole,chardev=mux"

      "-netdev user,id=net"
      "-device virtio-net-pci,netdev=net,$(< ${netOpts})"

      "-device isa-debug-exit,iobase=0xf4,iosize=0x04"
    ];
  };
}

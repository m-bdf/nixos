{ systemd-boot, kmscon, waybar, playerctld, ... }:

{
  disabledModules = [
    "system/boot/loader/systemd-boot/systemd-boot.nix"
    "services/ttys/kmscon.nix"
    "programs/wayland/waybar.nix"
  ];

  imports = [
    (systemd-boot + /nixos/modules/system/boot/loader/systemd-boot/systemd-boot.nix)
    (kmscon + /nixos/modules/services/ttys/kmscon.nix)
    (waybar + /nixos/modules/programs/wayland/waybar.nix)
    (playerctld + /nixos/modules/services/desktops/playerctld.nix)
  ];

  nixpkgs.overlays = [
    (final: prev: {
      waybar = final.callPackage (waybar + /pkgs/by-name/wa/waybar/package.nix) {};
    })
  ];
}

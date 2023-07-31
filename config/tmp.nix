{ systemd-boot, kmscon, river, waybar, playerctld, github-desktop, sonic-pi, ... }:

{
  disabledModules = [
    "system/boot/loader/systemd-boot/systemd-boot.nix"
    "services/ttys/kmscon.nix"
    "programs/wayland/river.nix"
    "programs/wayland/waybar.nix"
  ];

  imports = [
    (systemd-boot + /nixos/modules/system/boot/loader/systemd-boot/systemd-boot.nix)
    (kmscon + /nixos/modules/services/ttys/kmscon.nix)
    (river + /nixos/modules/programs/wayland/river.nix)
    (waybar + /nixos/modules/programs/wayland/waybar.nix)
    (playerctld + /nixos/modules/services/desktops/playerctld.nix)
  ];

  nixpkgs.overlays = [
    (final: prev: {
      waybar = final.callPackage (waybar + /pkgs/applications/misc/waybar) {};
      github-desktop = final.callPackage (github-desktop + /pkgs/applications/version-management/github-desktop) {};
      sonic-pi = final.libsForQt5.callPackage (sonic-pi + /pkgs/applications/audio/sonic-pi) {};
    })
  ];
}

{ kmscon, waybar, ... }:

{
  disabledModules = [
    "programs/wayland/waybar.nix"
  ];

  imports = [
    (waybar + /nixos/modules/programs/wayland/waybar.nix)
  ];

  nixpkgs.overlays = [
    (final: prev: {
      libtsm = final.callPackage (kmscon + /pkgs/development/libraries/libtsm/default.nix) {};
      kmscon = final.callPackage (kmscon + /pkgs/os-specific/linux/kmscon/default.nix) {};
      waybar = final.callPackage (waybar + /pkgs/by-name/wa/waybar/package.nix) {};
    })
  ];
}

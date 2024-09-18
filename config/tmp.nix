{ kmscon, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      libtsm = final.callPackage (kmscon + /pkgs/development/libraries/libtsm/default.nix) {};
      kmscon = final.callPackage (kmscon + /pkgs/os-specific/linux/kmscon/default.nix) {};
    })
  ];
}

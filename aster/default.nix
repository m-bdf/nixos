{ inputs, lib, pkgs, ... }:

let
  aster = import ./aster.nix { inherit inputs lib pkgs; };

  copyPatches = from: to: to.overrideAttrs (prev: {
    patches = prev.patches ++ lib.takeEnd 3 from.patches;
    inherit (from) postInstall passthru;
  });

  patchedSystemd = copyPatches pkgs.aster_systemd
    (import inputs.nixpkgs-aster {}).systemdMinimal;

  makeDiskImage = pkgs.runCommandLocal "make-disk-image" {} ''
    sed 's/fsType == "ext4"/lib.hasPrefix "ext" fsType/' \
      ${pkgs.path}/nixos/lib/make-disk-image.nix > $out
  '';

  mkEfiImageModule = format:
    { config, ... }: {
      imports = [ aster ];

      system.build.image =
        import makeDiskImage {
          inherit format config lib pkgs;
          partitionTableType = "efi";
          fsType = "ext2";
          copyChannel = false;
        };
    };
in

{
  nixpkgs.overlays = [ inputs.rust-overlay.overlays.default ];

  systemd.package = lib.mkForce patchedSystemd;

  image.modules = {
    raw-efi = lib.mkForce (mkEfiImageModule "raw");
    qemu-efi = lib.mkForce (mkEfiImageModule "qcow2");
  };

  virtualisation.vmVariantWithBootLoader.imports = [ aster ./vm.nix ];
}

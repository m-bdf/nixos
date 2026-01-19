{ inputs, lib, pkgs, ... }@ self:

let
  pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };

  distro = pkgs.runCommandLocal "aster-distro" {} ''
    cp -R --no-preserve=mode ${inputs.asterinas}/distro $out

    sed -i 's|\.\./.*/.*|./.;|' \
      $out/aster_nixos_installer/default.nix

    sed -i '/systemBuilderCommands/i \
      system.build.initialRamdisk = initramfs;
    ' $out/etc_nixos/modules/core.nix

    sed -Ei 's|=(\w+)|="\1"|
      s|extraConfig =|settings.Manager = fromTOML|
    ' $out/etc_nixos/modules/systemd.nix
  '';

  installer = import (distro + /aster_nixos_installer) { inherit pkgs; };

  copyPatches = from: to: to.overrideAttrs (prev: {
    patches = prev.patches ++ lib.takeEnd 3 from.patches;
    inherit (from) postInstall passthru;
  });

  patchedSystemd = copyPatches self.pkgs.aster_systemd
    (import inputs.nixpkgs-aster { system = "x86_64-linux"; }).systemdMinimal;
in

{
  imports = [
    (installer + /etc_nixos/aster_configuration.nix)
  ];

  system.stateVersion = lib.trivial.release;

  systemd.package = lib.mkForce patchedSystemd;
}

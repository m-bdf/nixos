{ inputs, lib, pkgs, ... }:

let
  copyPatches = from: to: to.overrideAttrs (prev: {
    patches = prev.patches ++ lib.takeEnd 3 from.patches;
    inherit (from) postInstall passthru;
  });

  patchedSystemd = copyPatches pkgs.aster_systemd
    (import inputs.nixpkgs-aster {}).systemdMinimal;
in

{
  system.stateVersion = lib.trivial.release;

  systemd.package = lib.mkForce patchedSystemd;
}

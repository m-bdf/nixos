{ options, config, lib, ... }:

with lib;

let
  inherit (config.system) build;
in

{
  boot.loader.systemd-boot.enable = false;

  fileSystems."/" = mkForce { label = "nixos"; fsType = "ext2"; };

  virtualisation = optionalAttrs (options.virtualisation ? qemu) {
    useEFIBoot = mkForce true;
    efi.keepVariables = false;

    diskImage = null;
    diskSizeAutoSupported = mkForce true;

    fileSystems = mkForce {};
    useDefaultFilesystems = false;

    qemu = {
      drives = [{
        file = with build.images.raw-efi;
          "${outPath}/${passthru.filePath}";

        driveExtraOpts = {
          readonly = "on";
          werror = "ignore";
        };
        deviceExtraOpts = {
          disable-legacy = "on";
          disable-modern = "off";
        };
      }];

      options = mkIf config.virtualisation.directBoot.enable (mkAfter [
        ''-append "init=/bin/init $(< ${build.toplevel}/kernel-params)"''
      ]);
    };
  };
}

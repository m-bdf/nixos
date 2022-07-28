{ pkgs, ... }:

let
    hardware-configuration =
        pkgs.runCommandLocal "hardware-configuration" {} ''
            ${pkgs.nixos-install-tools}/bin/nixos-generate-config \
                --no-filesystems --show-hardware-config > $out
        '';

    impure-hardware-configuration = derivation ({
        __impureHostDeps = [ "/sys" ];
        requiredSystemFeatures = [ "recursive-nix" ];
    } // hardware-configuration.drvAttrs);

in { imports = [ impure-hardware-configuration.outPath ]; }

{
    inputs.nixpkgs.url = "github:m-bdf/nixpkgs/patch-1";

    outputs = { self, nixpkgs }: {
        nixosConfigurations.mae = nixpkgs.lib.nixosSystem rec {
            system = "x86_64-linux";
            modules = let
                pkgs = nixpkgs.legacyPackages.${system};

                hardware-configuration =
                    pkgs.runCommandLocal "hardware-configuration" {} ''
                        ${pkgs.nixos-install-tools}/bin/nixos-generate-config \
                            --no-filesystems --show-hardware-config > $out
                    '';

                impure-hardware-configuration = derivation ({
                    __impureHostDeps = [ "/sys" ];
                } // hardware-configuration.drvAttrs);

            in [ impure-hardware-configuration.outPath ]
                ++ nixpkgs.lib.filesystem.listFilesRecursive ./config;
        };
    };
}

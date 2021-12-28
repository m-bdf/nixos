{
    outputs = { self, nixpkgs }: {
        nixosConfigurations.mae = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [ ./hardware-configuration.nix ]
                ++ nixpkgs.lib.filesystem.listFilesRecursive ./config;
        };
    };
}

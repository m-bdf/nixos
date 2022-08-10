{
    outputs = { self, nixpkgs }:
    let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};

    in {
        nixosConfigurations.mae = nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [ ./hardware-configuration.nix ]
                ++ nixpkgs.lib.filesystem.listFilesRecursive ./config;
        };

        packages.${system}.default =
            pkgs.writeText "deploy.json" (builtins.toJSON {
                agents.mae = self.nixosConfigurations.mae.toplevel;
            });
    };
}

{
    outputs = { self, nixpkgs }:
    let
        system = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs.secrets = nixpkgs.lib.importTOML ./secrets;
            modules = [ ./hardware-configuration.nix ]
                ++ nixpkgs.lib.filesystem.listFilesRecursive ./config;
        };

    in { nixosConfigurations.${system.config.system.name} = system; };
}

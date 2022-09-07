{
    outputs = { self, nixpkgs }:
    let
        system = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [ ./hardware-configuration.nix ]
                ++ nixpkgs.lib.filesystem.listFilesRecursive ./config;
        };

    in { nixosConfigurations.${system.config.system.name} = system; };
}

{
    inputs.secrets.url = "templates";

    outputs = { self, nixpkgs, secrets }:
    let
        system = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit secrets; };
            modules = [ ./hardware-configuration.nix ]
                ++ nixpkgs.lib.filesystem.listFilesRecursive ./config;
        };

    in { nixosConfigurations.${system.config.system.name} = system; };
}

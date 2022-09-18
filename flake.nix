{
    inputs.impermanence.url = "github:nix-community/impermanence";

    outputs = { self, nixpkgs, impermanence }:
    let
        system = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = nixpkgs.lib.filesystem.listFilesRecursive ./config
                ++ [ ./hardware-configuration.nix impermanence.nixosModule ];
        };

    in { nixosConfigurations.${system.config.system.name} = system; };
}

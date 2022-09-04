{
    outputs = { self, nixpkgs, secrets ? {} }:
    let constants = import ./constants // nixpkgs.lib.traceVal secrets;
    in {
        nixosConfigurations.${constants.hostname} = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = constants;
            modules = [ ./hardware-configuration.nix ]
                ++ nixpkgs.lib.filesystem.listFilesRecursive ./config;
        };
    };
}

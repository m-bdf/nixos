{
    inputs.secrets.url = "templates";

    outputs = { self, nixpkgs, secrets ? {} }:
    let const = import ./constants.nix // nixpkgs.lib.traceVal secrets;
    in {
        nixosConfigurations.${const.hostname} = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit const; };
            modules = [ ./hardware-configuration.nix ]
                ++ nixpkgs.lib.filesystem.listFilesRecursive ./config;
        };
    };
}

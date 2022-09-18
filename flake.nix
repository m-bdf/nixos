{
    inputs.impermanence.url = "github:nix-community/impermanence";

    outputs = { self, nixpkgs, impermanence }:
    let
        listDir = dir: map (entry: dir + "/${entry}")
            (builtins.attrNames (builtins.readDir dir));

        system = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";

            modules = listDir ./config ++ [
                impermanence.nixosModule
                ./hardware-configuration.nix
            ];
        };

    in { nixosConfigurations.${system.config.system.name} = system; };
}

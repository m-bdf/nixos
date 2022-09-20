{
    inputs.impermanence.url = "github:nix-community/impermanence";

    outputs = { self, nixpkgs, nixos-hardware, impermanence }:
    let
        listDir = dir: map (entry: dir + "/${entry}")
            (builtins.attrNames (builtins.readDir dir));

        modules = listDir ./config ++ [ impermanence.nixosModule ];

    in {
        nixosConfigurations = {
            vbox = nixpkgs.lib.nixosSystem {
                modules = modules ++ [ ./hardware/vbox.nix ];
            };

            t480 = nixpkgs.lib.nixosSystem {
                modules = modules ++ [ ./hardware/t480.nix ] ++ (
                    with nixos-hardware.nixosModules; [
                        lenovo-thinkpad-t480
                        common-gpu-nvidia-disable
                        common-pc-ssd
                    ]
                );
            };
        };
    };
}

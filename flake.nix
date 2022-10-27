{
    inputs.impermanence.url = "github:nix-community/impermanence";

    outputs = { self, nixpkgs, nixos-hardware, impermanence }:
    let
        listDir = dir: map (entry: dir + "/${entry}")
            (builtins.attrNames (builtins.readDir dir));

        modules = listDir ./config ++ [ impermanence.nixosModule ];

    in {
        checks.x86_64-linux = with nixpkgs.lib;
        let
            makeTest = script:
            let
                name = removeSuffix ".py" (baseNameOf script);

            in nameValuePair name (nixos.runTest {
                inherit name;
                hostPkgs = nixpkgs.legacyPackages.x86_64-linux;
                nodes.machine.imports = modules;
                testScript = readFile script;
            });

        in mapAttrs (name: { config, ... }:
            assert config.warnings == [];
            config.system.build.toplevel
        ) self.nixosConfigurations //
            listToAttrs (map makeTest (listDir ./tests));

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

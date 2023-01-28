{
  inputs.impermanence.url = "github:nix-community/impermanence";

  outputs = { self, nixpkgs, nixos-hardware, impermanence }:
  let
    listDir = dir: map (entry: dir + "/${entry}")
      (builtins.attrNames (builtins.readDir dir));

    modules = listDir ./config ++ [ impermanence.nixosModule ];
  in
  {
    checks = with nixpkgs.lib;
    let
      configTests = foldl' recursiveUpdate {}
        (mapAttrsToList (name: { config, pkgs, ... }:
          assert config.warnings == [];
          setAttrByPath [ pkgs.system name ] config.system.build.toplevel
        ) self.nixosConfigurations);

      vmTests = genAttrs [ "x86_64-linux" "aarch64-linux" ]
        (platform: import ./tests.nix {
          lib = nixpkgs.lib // { inherit listDir; };
          pkgs = nixpkgs.legacyPackages.${platform};
          inherit modules;
        });
    in
      recursiveUpdate configTests vmTests;

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

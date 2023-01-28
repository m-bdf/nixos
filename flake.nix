{
  inputs.impermanence.url = "github:nix-community/impermanence";

  outputs = { self, nixpkgs, nixos-hardware, impermanence }:

  with nixpkgs.lib;

  let
    imports = [ impermanence.nixosModule ];

    listDir = dir: mapAttrs' (entry: type:
      nameValuePair (head (splitString "." entry)) /${dir}/${entry}
    ) (builtins.readDir dir);
  in

  {
    nixosModules = mapAttrs (name: path:
      setDefaultModuleLocation path path
    ) (listDir ./config);

    nixosConfigurations =
    let
      mkSystem = name: modules: nixosSystem {
        lib = extend (final: prev: {
          mkAliasOptionModule = mkRenamedOptionModule;
          mkAliasOptionModuleMD = mkRenamedOptionModule; #208407
        });
        modules = attrValues self.nixosModules ++
          imports ++ modules ++ [ ./hardware/${name}.nix ];
      };
    in
      mapAttrs mkSystem {
        vbox = [];
        qemu = [];

        t480 = with nixos-hardware.nixosModules; [
          lenovo-thinkpad-t480
          common-gpu-nvidia-disable
          common-pc-ssd
        ];
      };

    checks =
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
          modules = attrValues self.nixosModules ++ imports;
        });
    in
      recursiveUpdate configTests vmTests;
  };
}

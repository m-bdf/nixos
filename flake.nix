{
  nixConfig = {
    flake-registry = "";
    allow-import-from-derivation = false;

    extra-substituters = [
      "https://m-bdf.cachix.org"
      "https://install.determinate.systems"
    ];
    extra-trusted-public-keys = [
      "m-bdf.cachix.org-1:7Uae6pLA5GHDKSM1vvp0jX/8D5jRJOqXxL/dFIef55s="
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
    ];
  };

  inputs = {
    systems.url = "github:nix-systems/default-linux";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix.url = "https://flakehub.com/f/DeterminateSystems/nix-src/*";

    preservation.url = "github:nix-community/preservation";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, ... }@ inputs:

  with self.lib;

  {
    lib = nixpkgs.lib.extend (final: prev: {
      mkAliasOptionModule = mkRenamedOptionModule;

      listDir = dir: mapAttrs' (entry: type:
        nameValuePair (head (splitString "." entry)) /${dir}/${entry}
      ) (builtins.readDir dir);
    });

    nixosModules = mapAttrs (name: path:
      setDefaultModuleLocation path path
    ) (listDir ./config);

    nixosConfigurations =
    let
      mkSystem = name: modules: nixosSystem {
        specialArgs = self;
        modules = attrValues self.nixosModules;
        extraModules = modules ++ [
          ./hardware/${name}.nix {
            networking.hostName = name;
          }
        ];
      };
    in
      with inputs.nixos-hardware.nixosModules;
      mapAttrs mkSystem {
        fw13 = [
          framework-13-7040-amd {
            hardware.framework.laptop13.audioEnhancement.enable = true;
          }
        ];
      };

    checks = import ./tests.nix inputs;
  };
}

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

    impermanence.url = "github:nix-community/impermanence";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dracula-fuzzel = {
      url = "github:dracula/fuzzel";
      flake = false;
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, nixos-hardware, ... }@ inputs:

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
        extraModules = modules ++ [ ./hardware/${name}.nix ];
      };
    in
      mapAttrs mkSystem {
        qemu = [];

        t480 = with nixos-hardware.nixosModules; [
          lenovo-thinkpad-t480
          common-gpu-nvidia-disable
        ];

        fw13 = with nixos-hardware.nixosModules; [
          framework-13-7040-amd {
            hardware.framework.amd-7040.preventWakeOnAC = true;
          }
        ];
      };

    checks = import ./tests.nix inputs;
  };
}

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
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix = {
      url = "https://flakehub.com/f/DeterminateSystems/nix-src/*";
      inputs.git-hooks-nix.follows = "git-hooks";
    };

    preservation.url = "github:nix-community/preservation";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, ... }@ inputs:

  with nixpkgs.lib;

  let
    listDir = dir: concatMapAttrs (entry: type: {
      ${removeSuffix ".nix" entry} = /${dir}/${entry};
    }) (builtins.readDir dir);
  in

  {
    nixosModules = listDir ./config;
    nixosConfigurations =
    let
      mkSystem = name: modules: nixosSystem {
        specialArgs.inputs = inputs;
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

    checks = import ./checks.nix inputs;

    devShells =
      mapAttrs (platform: checks: {
        default = nixpkgs.legacyPackages.${platform}.mkShellNoCC {
          inherit (checks.git-hooks) name shellHook;
        };
      }) self.checks;
  };
}

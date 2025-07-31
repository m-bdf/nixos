{
  nixConfig = {
    flake-registry = "";
    trace-import-from-derivation = true;

    extra-substituters = [
      "https://m-bdf.cachix.org"
      "https://install.determinate.systems"
      "https://nix-on-droid.cachix.org"
    ];
    extra-trusted-public-keys = [
      "m-bdf.cachix.org-1:7Uae6pLA5GHDKSM1vvp0jX/8D5jRJOqXxL/dFIef55s="
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU="
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

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    preservation.url = "github:nix-community/preservation";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, home-manager, nix-on-droid, ... }@ inputs:

  with nixpkgs.lib;

  let
    listDir = dir: concatMapAttrs (entry: type: {
      ${removeSuffix ".nix" entry} = /${dir}/${entry};
    }) (builtins.readDir dir);

    pkgsConfig = {
      warnUndeclaredOptions = true;
      allowAliases = false;
      allowUnfree = true;
      checkMeta = true;
    };

    pkgsFor = platform:
      import nixpkgs {
        system = platform;
        config = pkgsConfig;
      };
  in

  {
    homeModules = listDir ./home;
    homeConfigurations =
      mapAttrs (platform: _:
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor platform;
          extraSpecialArgs.inputs = inputs;
          modules = attrValues self.homeModules;
        }
      ) home-manager.packages;

    nixOnDroidModules = listDir ./droid;
    nixOnDroidConfigurations =
      mapAttrs (platform: _:
        nix-on-droid.lib.nixOnDroidConfiguration {
          pkgs = pkgsFor platform;
          extraSpecialArgs.inputs = inputs;
          modules = attrValues self.nixOnDroidModules ++ [{
            home.imports = attrValues self.homeModules;
          }];
        }
      ) nix-on-droid.packages;

    nixosModules = listDir ./config;
    nixosConfigurations =
    let
      baseSystem = nixosSystem {
        specialArgs.inputs = inputs;
        modules = attrValues self.nixosModules ++ [{
          home.imports = attrValues self.homeModules;
        }];
      };

      mkSystem = name: modules:
        baseSystem.extendModules {
          modules = modules ++ [
            ./hardware/${name}.nix {
              networking.hostName = name;
              nixpkgs.config = pkgsConfig;
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

    packages =
      mapAttrs (platform: droidPkgs: {
        nixOnDroidBootstrapZips =
          (pkgsFor platform).symlinkJoin {
            name = "nix-on-droid-bootstrap-zips";
            paths = mapAttrsToList (targetPlatform: system:
              system.config.build.bootstrapZip.override droidPkgs
            ) self.nixOnDroidConfigurations;
          };
      }) nix-on-droid.packages;

    checks = import ./checks.nix inputs;

    devShells =
      mapAttrs (platform: checks: {
        default = (pkgsFor platform).mkShellNoCC {
          inherit (checks.git-hooks) name shellHook;
        };
      }) self.checks;
  };
}

{
  nixConfig = {
    flake-registry = "";
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
      url = "github:m-bdf/git-hooks.nix/no-config-file-symlink";
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

    preservation.url = "github:m-bdf/preservation/support-nondefault-username";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-on-droid = {
      url = "github:m-bdf/nix-on-droid";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    rustyscript = {
      url = "github:Foorack/rustyscript/upgrade-deno";
      flake = false;
    };

    rusty-v8-releases = {
      url = "https://api.github.com/repos/denoland/rusty_v8/releases";
      flake = false;
    };

    highlightjs = {
      url = "https://esm.sh/highlight.js/esnext/highlight.bundle.mjs";
      flake = false;
    };

    github-textmate-theme = {
      url = "github:primer/github-textmate-theme";
      flake = false;
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    resolved.url = "github:Rua/nixpkgs/systemd-resolved-mdns";

    dnshack = {
      url = "github:ettom/dnshack";
      flake = false;
    };

    fprintd.url = "github:adisbladis/nixpkgs/security.pam.fprintd";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    airgorah = {
      url = "github:m-bdf/airgorah";
      flake = false;
    };
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
      # checkMeta = true;
    };

    nixOverlay = final: prev: {
      nix = inputs.nix.packages.${final.stdenv.system}.nix-cli;
    };

    pkgsFor = platform:
      import nixpkgs {
        system = platform;
        config = pkgsConfig;
        overlays = [ nixOverlay ];
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
      ) inputs.nix.packages;

    nixOnDroidModules = listDir ./droid;
    nixOnDroidConfigurations =
      mapAttrs (platform: _:
        nix-on-droid.lib.nixOnDroidConfiguration {
          pkgs = pkgsFor platform;
          extraSpecialArgs.inputs = inputs;
          modules = attrValues self.nixOnDroidModules ++ [{
            home-manager.extraSpecialArgs.inputs = inputs;
            home.imports = attrValues self.homeModules;
          }];
        }
      ) nix-on-droid.packages;

    nixosModules = listDir ./nixos;
    nixosConfigurations =
    let
      baseSystem = nixosSystem {
        specialArgs.inputs = inputs;
        modules = attrValues self.nixosModules ++ [{
          home-manager.extraSpecialArgs.inputs = inputs;
          home.imports = attrValues self.homeModules;
        }];
      };

      mkSystem = name: modules:
        baseSystem.extendModules {
          modules = modules ++ [
            ./hardware/${name}.nix {
              networking.hostName = name;
              nixpkgs = {
                config = pkgsConfig;
                overlays = [ nixOverlay ];
              };
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
            paths = mapAttrsToList (_: system:
              (system.extendModules {
                specialArgs = { inherit droidPkgs; };
              }).config.build.bootstrapZip
            ) self.nixOnDroidConfigurations;
          };
      }) nix-on-droid.packages;

    checks = import ./checks.nix inputs;

    devShells =
      mapAttrs (platform: checks: {
        default = with pkgsFor platform;
          (stdenvNoCC.override {
            setupScript = emptyFile;
          }).mkDerivation {
            inherit (checks.git-hooks) name shellHook;
          };
      }) self.checks;
  };
}

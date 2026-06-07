{
  nixConfig = {
    flake-registry = "";
    extra-substituters = [
      "https://m-bdf.cachix.org"
      "https://install.determinate.systems"
      "https://nix-on-droid.cachix.org"
      "https://aster-nixos-dev.cachix.org"
    ];
    extra-trusted-public-keys = [
      "m-bdf.cachix.org-1:7Uae6pLA5GHDKSM1vvp0jX/8D5jRJOqXxL/dFIef55s="
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU="
      "aster-nixos-dev.cachix.org-1:xrCbE2flfliFTQCY/2HeJoT2tCO+5kMTZeLIUH9lnIA="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-aster.url = "github:NixOS/nixpkgs/release-25.05";

    git-hooks = {
      url = "github:m-bdf/git-hooks.nix/no-config-file-symlink";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix = {
      url = "https://flakehub.com/f/DeterminateSystems/nix-src/*";
      inputs.git-hooks-nix.follows = "git-hooks";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
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

    termux-packages = {
      url = "github:termux/termux-packages";
      flake = false;
    };

    asterinas = {
      url = "github:asterinas/asterinas";
      flake = false;
    };

    linux-vdso = {
      url = "github:asterinas/linux_vdso";
      flake = false;
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    eza-themes = {
      url = "github:eza-community/eza-themes";
      flake = false;
    };

    highlightjs = {
      url = "https://esm.sh/v135/highlight.js/node/highlight.bundle.mjs";
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

    niri = {
      url = "github:m-bdf/niri/spawn-wait-scope-before-exec";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
      };
    };

    sylveon-garden = {
      url = "https://weasyl.com/api/submissions/1182575/view";
      flake = false;
    };

    dnshack = {
      url = "github:ettom/dnshack";
      flake = false;
    };

    # fprintd.url = "github:adisbladis/nixpkgs/security.pam.fprintd";

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser-hm = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    airgorah = {
      url = "github:martin-olivier/airgorah";
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
      # allowAliases = false;
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
    asterModules = listDir ./aster;
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

      nixpkgs-aster-source = with pkgsFor "x86_64-linux";
        runCommand "source" {} ''
          cp -R ${nixpkgs} $out && chmod +w $out/nixos/lib
          sed -i $out/nixos/lib/make-disk-image.nix \
            -e 's|fsType == "ext4"|lib.hasPrefix "ext" fsType|' \
            -e 's|"ext4"|config.fileSystems."/".fsType or &|'
        '';

      nixpkgs-aster = builtins.getFlake nixpkgs-aster-source.outPath;
    in
      with inputs.nixos-hardware.nixosModules;
      mapAttrs mkSystem {
        fw13 = [
          framework-13-7040-amd {
            hardware.framework.laptop13.audioEnhancement.enable = true;
          }
        ];
      } // optionalAttrs (!inPureEvalMode) {
        aster = nixpkgs-aster.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs.inputs = inputs;
          modules = attrValues self.asterModules ++ [{
            nixpkgs = {
              config = pkgsConfig;
              overlays = [ nixOverlay ];
            };
          }];
        };
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

{ self, nixpkgs, git-hooks, nixcov, ... }:

with nixpkgs.lib;

let
  hooks = {
    no-crlf-line-breaks = {
      enable = true;
      language = "pygrep";
      entry = "\r";
    };

    no-flake-lock = {
      enable = true;
      language = "fail";
      files = "flake.lock";
      entry = "flake.lock must not be committed";
    };

    no-amended-commits = {
      enable = true;
      stages = [ "pre-push" ];
      pass_filenames = false;
      entry = ''
        sh -c '
          ! echo %H %{a,c}{n,e,d} |
          git log --format="$(cat)" |
          grep -Po "^.{40}(?!(.+)\1)"
        '
      '';
    };
  };

  gitHooks =
    mapAttrs (platform: lib: {
      git-hooks = lib.run {
        src = self;
        configPath = ".git/hooks/config.json";
        inherit hooks;
      };
    }) git-hooks.lib;

  assertsTests = mapAttrs (platform: pkgs: {
    asserts-coverage = seq
      (pkgs.callPackage ./asserts/tests.nix {})
      (pkgs.callPackage ./asserts/coverage.nix {
        inherit (nixcov.packages.${platform}) nixcov;
      });

    asserts-mutation = seq
      (pkgs.callPackage ./asserts/tests.nix {})
      (pkgs.callPackage ./asserts/mutation.nix {
        inherit (nixcov.packages.${platform}) nixcov;
      });
  }) nixpkgs.legacyPackages;

  homeTests =
    mapAttrs (platform: system: {
      home-config =
        (system.extendModules {
          specialArgs.modules =
            attrValues self.homeModules;
          modules = [ ./asserts ];
        }).activationPackage;
    }) self.homeConfigurations;

  droidTests =
    mapAttrs (platform: system: {
      droid-config =
        (system.extendModules {
          specialArgs.modules =
            attrValues self.nixOnDroidModules;
          modules = [ ./asserts ];
        }).activationPackage;
    }) self.nixOnDroidConfigurations;

  nixosTests =
    mapAttrsToList (name: system: {
      ${if name == "aster" then "x86_64-linux"
      else system.pkgs.stdenv.system} = {
        "nixos-config-${name}" =
          (system.extendModules {
            specialArgs.modules =
              attrValues self.nixosModules;
            modules = [ ./asserts ];
          }).config.system.build.toplevel;
      };
    }) self.nixosConfigurations;
in

foldl' recursiveUpdate gitHooks
  ([ assertsTests homeTests droidTests ] ++ nixosTests)

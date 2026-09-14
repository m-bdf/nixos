{ self, nixpkgs, nixcov, ... }:

with nixpkgs.lib;

let
  futilityChecks =
    mapAttrs (platform: nixcovPkgs: let
      pkgs = nixpkgs.legacyPackages.${platform}.extend
        (final: prev: { inherit (nixcovPkgs) nixcov; });
    in {
      futility-tests-coverage = pkgs.callPackage ./coverage.nix {};
      futility-tests-mutations = pkgs.callPackage ./mutations {};
    }) nixcov.packages;

  mkConfigCheck = system: modules:
    assert system.config.warnings == [];
    system.extendModules {
      specialArgs.modules = attrValues modules;
      modules = [ ./futility.nix ];
    };

  homeChecks =
    mapAttrs (platform: system: {
      home-config = (
        mkConfigCheck system self.homeModules
      ).activationPackage;
    }) self.homeConfigurations;

  droidChecks =
    mapAttrs (platform: system: {
      droid-config = (
        mkConfigCheck system self.nixOnDroidModules
      ).activationPackage;
    }) self.nixOnDroidConfigurations;

  nixosChecks =
    mapAttrsToList (name: system: {
      ${if name == "aster" then "x86_64-linux"
      else system.pkgs.stdenv.system} = {
        "nixos-config-${name}" = (
          mkConfigCheck system self.nixosModules
        ).config.system.build.toplevel;
      };
    }) self.nixosConfigurations;
in

foldl' recursiveUpdate futilityChecks
  ([ homeChecks droidChecks ] ++ nixosChecks)

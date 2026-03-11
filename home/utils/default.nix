{ config, nixosConfig, lib, pkgs, ... }:

with lib;

let
  replaceDirectDependencies = args:
    pkgs.replaceDirectDependencies (args // {
      replacements = map (r: r // {
        oldDependency = substring 0 43 r.oldDependency +
          strings.replicate (stringLength r.newDependency - 43) ".";
      }) args.replacements;
    });

  mkReplacement = oldName: newDep: rec {
    oldDependency =
      pkgs.${oldName} or pkgs."gnu${oldName}";

    newDependency = pkgs.symlinkJoin {
      inherit (oldDependency) name;
      paths = [ newDep oldDependency ];
    };
  };

  glibcIsattyPager = pkgs.callPackage ./glibc.nix {};

  uutilsReplacements =
    mapAttrs' (n: nameValuePair {
      uutils-coreutils = "coreutils-prefixed";
      uutils-coreutils-noprefix = "coreutils";
    }.${n} or (removePrefix "uutils-" n))
      (filterAttrs (n: pkg: hasPrefix "uutils-" n && !hasInfix "-unstable-" pkg.version) pkgs);
in

{
  options.home.activationPackage = config.lib.mkToplevelOption;

  config.lib.mkToplevelOption = mkOption {
    apply = drv:
      pkgs.replaceDependencies.override {
        inherit replaceDirectDependencies;
      } rec {
        inherit drv;
        replacements = mapAttrsToList mkReplacement
          ({ glibc = glibcIsattyPager; } // uutilsReplacements);
        cutoffPackages = catAttrs "newDependency" replacements ++
          [ nixosConfig.system.build.initialRamdisk or "" ];
        verbose = false;
      };
  };
}

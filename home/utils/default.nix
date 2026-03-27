{ config, lib, pkgs, ... }:

with lib;

let
  mkReplacement = oldName: newDep: rec {
    oldDependency =
      pkgs.${oldName} or pkgs."gnu${oldName}";
    newDependency = pkgs.runCommandLocal
      oldDependency.name {} "ln -s ${newDep} $out";
  };

  uutilsReplacements =
    mapAttrs' (n: nameValuePair {
      uutils-coreutils = "coreutils-prefixed";
      uutils-coreutils-noprefix = "coreutils";
    }.${n} or (removePrefix "uutils-" n))
      (filterAttrs (n: pkg: hasPrefix "uutils-" n && !hasInfix "-unstable-" pkg.version) pkgs);

  replacements = mapAttrsToList mkReplacement uutilsReplacements;
  oldDeps = concatLines (catAttrs "oldDependency" replacements);

  replaceDirectDependencies = args:
  let
    drv = pkgs.replaceDirectDependencies args;

    leftover = pkgs.runCommandLocal "leftover" {
      inherit oldDeps;
      passAsFile = [ "oldDeps" ];
      exportReferencesGraph = [ "graph" drv ];
    } ''
      grep -f $oldDepsPath graph > $out || true
    '';
  in
    if readFile leftover == "" then drv
    else drv.overrideAttrs {
      __structuredAttrs = true;
      unsafeDiscardReferences.out = true;
    };
in

{
  options.home = {
    activationPackage = config.lib.mkToplevelOption;
    path = config.lib.mkPathOption;
  };

  config = {
    lib = {
      mkToplevelOption = mkOption {
        apply = drv:
          pkgs.replaceDependencies.override {
            inherit replaceDirectDependencies;
          } {
            inherit drv replacements;
            verbose = false;
          };
      };

      mkPathOption = mkOption {
        apply = drv: drv.override (prev: {
          paths = prev.paths ++ concatLists
            (catAttrs "propagatedBuildInputs" prev.paths);
        });
      };
    };

    home.sessionVariables.LD_PRELOAD =
      pkgs.zigStdenv.mkDerivation {
        name = "isatty_pager.so";
        buildCommand = ''
          $CC ${./isatty.c} -Os -shared -o $out
        '';
      };
  };
}

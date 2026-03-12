{ config, lib, pkgs, ... }:

with lib;

let
  mkReplacement = oldName: newDep: rec {
    oldDependency =
      pkgs.${oldName} or pkgs."gnu${oldName}";

    newDependency = pkgs.symlinkJoin {
      inherit (oldDependency) name;
      paths = [newDep];
    };
  };

  uutilsReplacements =
    mapAttrs' (n: nameValuePair {
      uutils-coreutils = "coreutils-prefixed";
      uutils-coreutils-noprefix = "coreutils";
    }.${n} or (removePrefix "uutils-" n))
      (filterAttrs (n: pkg: hasPrefix "uutils-" n && !hasInfix "-unstable-" pkg.version) pkgs);
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
          pkgs.replaceDependencies {
            inherit drv;
            replacements = mapAttrsToList mkReplacement uutilsReplacements;
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

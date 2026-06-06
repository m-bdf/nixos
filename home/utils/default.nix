{ config, lib, pkgs, ... }:

with lib;

let
  uutils = attrValues (filterAttrs (n: pkg: hasPrefix "uutils-" n) pkgs);
  uutilsStable = reverseList (filter (pkg: !hasInfix "-unstable-" pkg) uutils);

  mkReplacement = pkg: rec {
    oldDependency =
      let oldName = removePrefix "uutils-" pkg.pname;
      in getDev pkgs.${oldName} or pkgs."gnu${oldName}" or pkg;

    newDependency =
      let newName = substring 44 (-1) oldDependency;
      in pkgs.runCommandLocal newName {} "ln -s ${pkg} $out";
  };
in

{
  options.home.activationPackage = config.lib.mkToplevelOption;

  config = {
    lib.mkToplevelOption = mkOption {
      apply = drv:
        pkgs.replaceDependencies {
          inherit drv;
          replacements = map mkReplacement uutilsStable;
          verbose = false;
        };
    };

    home = {
      packages = catAttrs "oldDependency" (map mkReplacement uutils);

      sessionVariables.LD_PRELOAD =
        pkgs.zigStdenv.mkDerivation {
          name = "isatty_pager.so";
          buildCommand = ''
            $CC ${./isatty.c} -Os -static -shared -o $out
          '';
        };
    };
  };
}

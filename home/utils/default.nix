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
      paths = [newDep];
    };
  };

  glibcIsatty = pkgs.glibc.overrideAttrs (prev: {
    pname = prev.pname + "-isatty";
    prePatch = ''
      sed -i '/weak_alias/d' sysdeps/posix/isatty.c
      cat ${./isatty.c} >> sysdeps/posix/isatty.c
    '';
    makeFlags = prev.makeFlags ++ [ "--silent" ];
  });

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
      } {
        inherit drv;
        replacements = mapAttrsToList mkReplacement
          ({ glibc = glibcIsatty; } // uutilsReplacements);
        cutoffPackages = optional (nixosConfig != null)
          nixosConfig.system.build.initialRamdisk;
        verbose = false;
      };
  };
}

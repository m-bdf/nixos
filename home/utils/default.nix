{ config, nixosConfig, lib, pkgs, ... }:

let
  replaceDirectDependencies = args:
    pkgs.replaceDirectDependencies (args // {
      replacements = map (r: r // {
        oldDependency = with lib.strings;
          substring 0 43 r.oldDependency +
          replicate (stringLength r.oldDependency - 43) ".";
      }) args.replacements;
    });

  mkReplacement = old: new: rec {
    oldDependency = pkgs.${old};
    newDependency =
      if oldDependency.name == new.name then new
      else pkgs.symlinkJoin {
        name = lib.substring 44 (-1) oldDependency;
        paths = [new];
      };
  };

  replacements = with pkgs;
    lib.mapAttrsToList mkReplacement {
      glibc = glibc.overrideAttrs {
        prePatch = ''
          sed -i '/weak_alias/d' sysdeps/posix/isatty.c
          cat ${./isatty.c} >> sysdeps/posix/isatty.c
        '';
      };

      coreutils = uutils-coreutils-noprefix;
      diffutils = uutils-diffutils.overrideAttrs {
        postInstall = ''
          ln -s diffutils $out/bin/diff
          ln -s diffutils $out/bin/cmp
        '';
      };
      findutils = uutils-findutils;
    };
in

{
  options.home.activationPackage = config.lib.mkToplevelOption;

  config.lib.mkToplevelOption = lib.mkOption {
    apply = drv:
      pkgs.replaceDependencies.override {
        inherit replaceDirectDependencies;
      } {
        inherit drv replacements;
        cutoffPackages = lib.optional (nixosConfig != null)
          nixosConfig.system.build.initialRamdisk;
      };
  };
}

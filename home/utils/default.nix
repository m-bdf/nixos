{ config, lib, pkgs, ... }:

let
  mkReplacement = old: new: rec {
    oldDependency = pkgs.${old};
    newDependency = pkgs.symlinkJoin {
      inherit (oldDependency) name;
      paths = [new];
    };
  };

  replacements = with pkgs;
    lib.mapAttrsToList mkReplacement {
      coreutils = uutils-coreutils-noprefix;
      coreutils-full = uutils-coreutils-noprefix;
      diffutils = uutils-diffutils;
      findutils = uutils-findutils;

      glibc = glibc.overrideAttrs {
        postPatch = ''
          sed -i '/weak_alias/d' sysdeps/posix/isatty.c
          cat ${./isatty.c} >> sysdeps/posix/isatty.c
        '';
      };
    };
in

{
  options.home.path = config.lib.mkPathOption;

  config = {
    lib.mkPathOption = lib.mkOption {
      apply = drv: drv //
        pkgs.replaceDependencies {
          inherit drv replacements;
        };
    };

    home.packages = with pkgs; [ curl ];

    programs = {
      fd.enable = true;
      ripgrep.enable = true;

      man.generateCaches = false;
    };
  };
}

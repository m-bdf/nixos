{ config, lib, pkgs, ... }:

let
  getStoreHash = lib.substring 0 43;
  getNameVersion = lib.substring 44 (-1);

  mkRegexReplacement = r:
    with lib.strings; rec {
      oldDependency = "${
        getStoreHash r.oldDependency
      }[-${
        replaceString "-" "" (getNameVersion r.oldDependency)
      }]{00,${
        toString (stringLength (getNameVersion r.oldDependency))
      }}";

      newDependency = pkgs.runCommand (
        getNameVersion r.newDependency + replicate (
          stringLength oldDependency - stringLength r.newDependency
        ) "-"
      ) {} ''
        cp -R ${r.newDependency} $out
      '';
    };

  mkReplacement = old: new: rec {
    oldDependency = pkgs.${old};
    newDependency =
      if oldDependency.name == new.name then new
      else pkgs.symlinkJoin {
        name = getNameVersion oldDependency;
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
        prePatch = ''
          sed -i '/weak_alias/d' sysdeps/posix/isatty.c
          cat ${./isatty.c} >> sysdeps/posix/isatty.c
        '';
      };
    };
in

{
  # options.home.path = config.lib.mkPathOption;
  options.home.activationPackage = config.lib.mkToplevelOption;

  config = {
    lib.mkToplevelOption = lib.mkOption {
      apply = drv:
        pkgs.replaceDependencies.override {
          replaceDirectDependencies = args:
            pkgs.replaceDirectDependencies (args // {
              replacements = map mkRegexReplacement args.replacements;
            });
        } {
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

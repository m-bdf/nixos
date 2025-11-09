{ config, lib, pkgs, ... }:

let
  replaceDirectDependencies = args:
    pkgs.replaceDirectDependencies (args // {
      replacements = with lib.strings;
        map (r: rec {
          oldDependency = "${substring 0 43 r.oldDependency}[-${
            replaceString "-" "" (substring 44 (-1) r.oldDependency)
          }]{00,${toString (stringLength r.oldDependency - 43)}}";

          newDependency = pkgs.runCommand (
            substring 44 (-1) r.newDependency + replicate (
              stringLength oldDependency - stringLength r.newDependency
            ) "-"
          ) {} ''
            cp -R ${r.newDependency} $out
          '';
        }) args.replacements;
    });

  mkReplacement = old: new: {
    oldDependency = old;
    newDependency =
      if old.name == new.name then new
      else pkgs.symlinkJoin {
        name = lib.substring 44 (-1) old;
        paths = [new];
      };
  };

  mkReplacements = old: new: map (o:
    mkReplacement pkgs.${old}.${o} (lib.getOutput o new)
  ) pkgs.${old}.outputs;

  replacements = with pkgs;
    lib.concatLists (
      lib.mapAttrsToList mkReplacements {
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
      }
    );
in

{
  # options.home.path = config.lib.mkPathOption;
  options.home.activationPackage = config.lib.mkToplevelOption;

  config = {
    lib.mkToplevelOption = lib.mkOption {
      apply = drv:
        pkgs.replaceDependencies.override {
          inherit replaceDirectDependencies;
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

{ config, lib, pkgs, ... }:

let
  mkReplacement = old: new: {
    oldDependency = old;
    newDependency = pkgs.symlinkJoin {
      inherit (old) name;
      paths = [new];
    };
  };

  replacements = with pkgs; [
    (mkReplacement coreutils uutils-coreutils-noprefix)
    (mkReplacement coreutils-full uutils-coreutils-noprefix)
    # (mkReplacement diffutils uutils-diffutils)
    (mkReplacement findutils uutils-findutils)
    {
      oldDependency = glibc;
      newDependency = glibc.overrideAttrs {
        postPatch = ''
          sed -i '/weak_alias/d' sysdeps/posix/isatty.c
          cat ${./isatty.c} >> sysdeps/posix/isatty.c
        '';
      };
    }
  ];
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

      helix = {
        enable = true;
        defaultEditor = true;
        settings.theme = "github_dark";
      };

      man.generateCaches = false;
    };
  };
}

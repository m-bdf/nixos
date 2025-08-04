{ lib, pkgs, ... }:

let
  isatty = pkgs.writeCBin "isatty" ''
    #define CAPSH "${pkgs.libcap}/bin/capsh"
    ${lib.fileContents ./isatty.c}
  '';
in

{
  environment = {
    systemPackages = with pkgs; [
      isatty uutils-coreutils-noprefix
      fd ripgrep difftastic moar helix
    ];

    variables = {
      PAGER = "moar";
      SYSTEMD_PAGERSECURE = 1;
      LD_PRELOAD = lib.getExe
        (isatty.overrideAttrs {
          env.NIX_CFLAGS_LINK = "-shared";
        });

      EDITOR = "hx";
    };
  };

  programs = {
    less.enable = lib.mkForce false;
    nano.enable = false;
  };

  preservation.preserveAt.state.users.user.directories = [
    { directory = "Documents"; mountOptions = [ "exec" ]; }
    "Downloads"
  ];

  xdg.dirs.cache.helix.create = true;
}

{ lib, pkgs, ... }:

let
  ghostty = pkgs.applyPatches {
    src = pkgs.ghostty;
    patchPhase = ''
      sed -i 's/--gtk-single-instance=true/+new-window/' \
        share/applications/*
    '';
  };

  xdg-terminal-exec = pkgs.xdg-terminal-exec.overrideAttrs (prev: {
    postFixup = ''
      ${lib.trim prev.postFixup} --prefix PATH : ${
        with pkgs; lib.makeBinPath [ findutils gawk ]
      }
    '';
  });
in

{
  systemd.oomd.enableUserSlices = true;

  nixpkgs.overlays = [
    (final: prev: {
      xdg-utils = final.writeShellScriptBin "xdg-open" ''
        cmd="cd ''${PWD@Q} && ${final.glib}/bin/gio open ''${@@Q}"
        elephant activate "runner;generic;run;sh;-c ''${cmd@Q}"
      '';
    })
  ];

  environment = {
    systemPackages = with pkgs; [
      (symlinkJoin {
        inherit (nautilus) name meta;
        paths = [ nautilus nautilus-python ];
      })
    ];
    pathsToLink = [ "/share/nautilus-python/extensions" ];
  };

  programs.niri.keybinds."Mod+Return" = "walker";
  home = {
    services = {
      walker.enable = true;
      elephant = {
        enable = true;
        package = pkgs.elephant.override {
          enabledProviders = [
            "desktopapplications" "runner"
            "files" "clipboard" "websearch"
          ];
        };
      };
    };
    systemd.user.services.elephant = {
      Unit.After = [ "graphical-session.target" ];
    };

    programs.ghostty = {
      enable = true;
      package = ghostty;
      settings = {
        resize-overlay = "never";
        app-notifications = false;
        confirm-close-surface = false;
      };
    };

    xdg = {
      terminal-exec = {
        enable = true;
        package = xdg-terminal-exec;
      };

      cacheFile.elephant.persist = true;
    };
  };
}

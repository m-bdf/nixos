{ inputs, config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [ inputs.niri.overlays.default ];
  programs.niri.enable = true;

  home-manager.sharedModules = [{
    options.wayland.startup = lib.mkOption {
      type = with lib.types;
        coercedTo nonEmptyStr lib.singleton (listOf nonEmptyStr);
    };
  }];

  home = {
    services.wl-clip-persist.enable = true;

    wayland.startup =
    let
      metadata = lib.importJSON inputs.sylveon-garden;
      wallpaper = pkgs.fetchurl rec {
        inherit (lib.head metadata.media.submission) url;
        sha256 = lib.head (lib.match ".*/(.*)/.*" url);
      };
    in
      "${lib.getExe pkgs.swaybg} --image ${wallpaper} --mode fill";

    xdg.configFile."niri/config.kdl".text = ''
      input {
        disable-power-key-handling
        touchpad { natural-scroll; tap; }
      }

      output "eDP-1" { scale 1; }

      layer-rule {
        match namespace="^wallpaper$"
        place-within-backdrop true
      }

      layout {
        empty-workspace-above-first
        preset-column-widths {
          proportion 0.5
          proportion 1.0
        }

        background-color "transparent"
        focus-ring { off; }
        shadow { on; }
      }

      ${lib.concatMapStringsSep "\n" (cmd:
        ''spawn-sh-at-startup "${cmd}"''
      ) config.home.wayland.startup}
    '';
  };
}

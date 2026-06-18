{ inputs, config, lib, pkgs, ... }:

{
  options.programs.niri.startup = lib.mkOption {
    type = with lib.types;
      coercedTo nonEmptyStr lib.singleton (listOf nonEmptyStr);
  };

  config = {
    nixpkgs.overlays = [ inputs.niri.overlays.default ];

    programs.niri = {
      enable = true;

      startup = "${lib.getExe pkgs.swaybg} --image ${pkgs.fetchurl rec {
        passthru.submission = lib.importJSON inputs.sylveon-garden;
        inherit (lib.head passthru.submission.media.submission) url;
        sha256 = lib.head (lib.match ".*/(.*)/.*" url);
      }} --mode fill";
    };

    home = {
      services.wl-clip-persist.enable = true;

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
        ) config.programs.niri.startup}
      '';
    };
  };
}

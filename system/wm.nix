{ config, lib, pkgs, ... }:

{
  options.programs.niri.startup = lib.mkOption {
    type = with lib.types;
      coercedTo nonEmptyStr lib.singleton (listOf nonEmptyStr);
  };

  config = {
    programs.niri = {
      enable = true;
      startup = "${lib.getExe pkgs.swaybg} --image ${pkgs.fetchurl rec {
        name = "melynx-sylveon-garden.png";
        url = "https://cdn.weasyl.com/~melynx/submissions/1182575/${sha256}/${name}";
        sha256 = "a5be4ca16b57a2232cd11fd5897ad453ae2eda554826e8efd02533b3f59cfd35";
      }} --mode fill";
    };

    environment = {
      systemPackages = [ pkgs.wl-clipboard-rs ];
      variables.NIXOS_OZONE_WL = "1";

      etc."xdg/niri/config.kdl".text = ''
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

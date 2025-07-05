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
        url = "https://weasyl.com/~melynx/submissions/1182575/${name}";
        hash = "sha256-pb5MoWtXoiMs0R/ViXrUU64u2lVIJujv0CUzs/Wc/TU=";
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
          background-color "transparent"
          empty-workspace-above-first

          focus-ring { off; }
          shadow { on; }
        }

        ${lib.concatMapStringsSep "\n" (cmd:
          ''spawn-at-startup "sh" "-c" "${cmd}"''
        ) config.programs.niri.startup}
      '';
    };
  };
}

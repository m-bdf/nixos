{ config, lib, pkgs, ... }:

{
  imports = [ ./binds.nix ];

  options.programs.niri.startup = lib.mkOption {
    type = with lib.types;
      coercedTo nonEmptyStr lib.singleton (listOf nonEmptyStr);
  };

  config = {
    programs.niri = {
      enable = true;
      startup = "${lib.getExe pkgs.swaybg} --image ${builtins.fetchurl {
        url = "weasyl.com/~melynx/submissions/1182575/melynx-sylveon-garden.png";
        sha256 = "0dgxkksv6cr5s3pyh9j8apd2xbjksix8km8zs4n278jpdfhlrgm5";
      }} --mode fill";
    };

    environment = {
      systemPackages = with pkgs;
        [ wl-clipboard-rs qt5.qtwayland qt6.qtwayland ];
      variables.NIXOS_OZONE_WL = "1";

      etc."xdg/niri/config.kdl".text = ''
        input {
          disable-power-key-handling
          touchpad { natural-scroll; tap; }
        }
        output "eDP-1" { scale 1; }

        layout {
          focus-ring { off; }
          shadow { on; }

          empty-workspace-above-first
          preset-column-widths {
            proportion 0.3
            proportion 0.5
            proportion 0.7
            proportion 1.0
          }
        }

        ${lib.concatMapStringsSep "\n" (cmd:
          "spawn-at-startup \"sh\" \"-c\" \"${cmd}\""
        ) config.programs.niri.startup}
      '';
    };
  };
}

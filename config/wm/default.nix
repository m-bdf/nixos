{ config, lib, pkgs, ... }:

{
  imports = [ ./binds.nix ];

  programs.niri.enable = true;

  environment = {
    systemPackages = with pkgs; [ wl-clipboard-rs qt5.qtwayland qt6.qtwayland ];
    variables.NIXOS_OZONE_WL = "1";

    etc."xdg/niri/config.kdl".text = ''
      input {
        disable-power-key-handling
        touchpad { natural-scroll; tap; }
      }
      output "eDP-1" { scale 1; }

      spawn-at-startup "${lib.getExe pkgs.swaybg}" "--image" "${builtins.fetchurl {
        url = "weasyl.com/~melynx/submissions/1182575/melynx-sylveon-garden.png";
        sha256 = "0dgxkksv6cr5s3pyh9j8apd2xbjksix8km8zs4n278jpdfhlrgm5";
      }}" "--mode" "fill"

      prefer-no-csd
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

      binds {${
        lib.concatStrings (
          lib.mapAttrsToList (keys: cmd:
            "\n  ${keys} { ${cmd}; }"
          ) config.programs.niri.bindings
        )}
      }
      hotkey-overlay { skip-at-startup; }
      screenshot-path "~/Downloads/Screenshot %c.png"
    ''; # TODO: KDL v2: unquote strings, r"…" -> #"…"#
  };
}

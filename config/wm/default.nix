{ config, lib, pkgs, ... }:

{
  imports = [ ./binds.nix ];

  nixpkgs.overlays = [
    (final: prev: {
      xwayland = null;
      wlroots_0_17 = prev.wlroots_0_17.override { enableXWayland = false; };
      wlroots_0_18 = prev.wlroots_0_18.override { enableXWayland = false; };
    })
  ];

  programs.niri.enable = true;

  environment = {
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

      layout {
        empty-workspace-above-first
        preset-column-widths {
          proportion 0.3
          proportion 0.5
          proportion 0.7
          proportion 1.0
        }
      }

      binds {
        ${lib.concatStringsSep "\n  " (lib.mapAttrsToList
          (keys: cmd: "${keys} { spawn \"sh\" \"-c\" r\"${cmd}\"; }")
        config.programs.niri.bindings)}
      }
      hotkey-overlay { skip-at-startup; }
      screenshot-path "~/Downloads/Screenshot %c.png"
    ''; # TODO: KDL v2: unquote strings, r"…" -> #"…"#

    systemPackages = with pkgs; [ wl-clipboard-rs qt5.qtwayland qt6.qtwayland ];
    variables.NIXOS_OZONE_WL = "1";
  };

  xdg.dirs.cache = {
    mesa_shader_cache.create = true;
    mesa_shader_cache_db.create = true;
  };
}

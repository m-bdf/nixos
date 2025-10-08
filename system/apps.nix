{ lib, pkgs, ... }:

let
  wrapSpawn = name: cmd: pkgs.writeShellScriptBin name ''
    niri msg action spawn -- ${pkgs.writeShellScript name cmd} "$@"
  '';
in

{
  # nixpkgs.overlays = [
  #   (final: prev: {
  #     niri = prev.niri.overrideAttrs {
  #       prePatch = ''
  #         sed -i 's/0 => ()/0 => \
  #           if let Some(pipe) = pipe_wait_read { \
  #             let raw = pipe.as_raw_fd() as u32; \
  #             let _ = close_range(0, raw - 1, 0); \
  #             let _ = close_range(raw + 1, !0, 0); \
  #             let _ = read_all(pipe, \&mut [0]); \
  #           }/' src/utils/spawning.rs
  #       '';
  #     };
  #   })
  # ];

  environment = {
    systemPackages = with pkgs;
    let
      xdg-open = wrapSpawn "xdg-open" ''${pkgs.glib}/bin/gio open "$@"'';
    in
      [ xdg-open ghostty nautilus brave ];

    etc."xdg/ghostty/config".text = ''
      resize-overlay = never
      app-notifications = false
      confirm-close-surface = false
    '';
  };

  systemd.oomd.enableUserSlices = true;

  programs = {
    niri.keybinds."Mod+Return" = lib.getExe pkgs.walker;

    nautilus-open-any-terminal.enable = true;
    dconf.profiles.user.databases = [{
      settings."com.github.stunkymonkey.nautilus-open-any-terminal" = {
        terminal = "custom";
        custom-local-command = "xdg-terminal-exec";
      };
      lockAll = true;
    }];
  };

  xdg.terminal-exec = {
    enable = true;
    package = wrapSpawn "xdg-terminal-exec" ''
      ${lib.getExe pkgs.xdg-terminal-exec} --dir="$PWD" "''${@-:$SHELL}"
    '';
  };

  home.xdg = {
    cacheFile.walker.persist = true;
    configFile = {
      walker.persist = true;
      "BraveSoftware/Brave-Browser".persist = true;
    };
  };
}

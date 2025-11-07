{ lib, pkgs, ... }:

{
  systemd.oomd.enableUserSlices = true;

  home = {
    services.walker = {
      enable = true;
      systemd.enable = true;
    };

    programs.ghostty = {
      enable = true;
      settings = {
        resize-overlay = "never";
        app-notifications = false;
        confirm-close-surface = false;
      };
    };

    home.packages = with pkgs;
    let
      wrapSpawn = name: cmd: writeShellScriptBin name ''
        niri msg action spawn -- sh -c 'cd "$0" && ${cmd}' "$PWD" "$@"
      '';

      xdg-open = wrapSpawn "xdg-open" ''
        sleep 1 && ${glib}/bin/gio open "$@"
      '';

      xdg-terminal-exec = wrapSpawn "xdg-terminal-exec" ''
        ${lib.getExe xdg-terminal-exec-mkhl} "''${@:-$SHELL}"
      '';
    in
      [ xdg-open xdg-terminal-exec nautilus brave ];
  };

  programs = {
    niri.keybinds."Mod+Return" = "walker";

    nautilus-open-any-terminal.enable = true;
    dconf.profiles.user.databases = [{
      settings."com.github.stunkymonkey.nautilus-open-any-terminal" = {
        terminal = "custom";
        custom-local-command = "xdg-terminal-exec";
      };
      lockAll = true;
    }];
  };

  home.xdg = {
    cacheFile.walker.persist = true;
    configFile = {
      walker.persist = true;
      "BraveSoftware/Brave-Browser".persist = true;
    };
  };
}

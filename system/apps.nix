{ lib, pkgs, ... }:

let
  wrapSpawn = name: cmd: pkgs.writeShellScriptBin name ''
    niri msg action spawn -- sh -c 'cd "$0" && ${cmd}' "$PWD" "$@"
  '';
in

{
  environment = {
    systemPackages = with pkgs;
    let
      xdg-open = wrapSpawn "xdg-open" ''
        sleep 1 && ${pkgs.glib}/bin/gio open "$@"
      '';
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
      ${lib.getExe pkgs.xdg-terminal-exec-mkhl} "''${@:-$SHELL}"
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

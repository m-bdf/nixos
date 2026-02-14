{ lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs;
  let
    wrapSpawn = name: cmd: writeShellScriptBin name ''
      niri msg action spawn -- sh -c 'cd "$0" && ${cmd}' "$PWD" "$@"
    '';
    xdg-open = wrapSpawn "xdg-open" ''
      sleep 1 && ${glib}/bin/gio open "$@"
    '';
    xdg-term = wrapSpawn "xdg-terminal-exec" ''
      ${lib.getExe xdg-terminal-exec} "''${@:-$SHELL}"
    '';
  in
    [ xdg-open xdg-term nautilus ];

  systemd = {
    oomd.enableUserSlices = true;
    user.services.elephant.path = lib.mkForce [];
  };
  services.elephant.enable = true;

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

  home = {
    programs.ghostty = {
      enable = true;
      settings = {
        resize-overlay = "never";
        app-notifications = false;
        confirm-close-surface = false;
      };
    };

    xdg = {
      cacheFile.walker.persist = true;
      configFile.walker.persist = true;
    };
  };
}

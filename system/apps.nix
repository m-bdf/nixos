{ lib, pkgs, ... }:

let
  wrapSpawn = name: cmd: pkgs.writeShellScriptBin name ''
    niri msg action spawn -- ${lib.removeSuffix "\n" cmd} "$@"
  '';
in

{
  environment = {
    systemPackages = with pkgs;
    let
      xdg-open = wrapSpawn "xdg-open" "${pkgs.glib}/bin/gio open";
    in
      [ xdg-open ghostty nautilus ];

    etc."xdg/ghostty/config".text = ''
      resize-overlay = never
      app-notifications = false
      confirm-close-surface = false
    '';
  };

  systemd.oomd.enableUserSlices = true;

  programs = {
    niri.keybinds."Mod+Return" = lib.getExe pkgs.walker;

    nautilus-open-any-terminal = {
      enable = true;
      command = "xdg-terminal-exec";
    };
  };

  xdg.terminal-exec = {
    enable = true;
    package = wrapSpawn "xdg-terminal-exec" ''
      ${lib.getExe pkgs.xdg-terminal-exec} --dir="$PWD"
    '';
  };

  home.xdg = {
    cacheFile.walker.persist = true;
    configFile.walker.persist = true;
  };
}

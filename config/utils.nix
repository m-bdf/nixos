{ lib, pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs;
    let
      wrapSpawn = name: { pkg ? pkgs.${name}, arg ? "" }:
        writeShellScriptBin name
          "niri msg action spawn -- ${pkg}/bin/${name} ${arg} \"$@\"";

      xdg-open = symlinkJoin {
        name = "xdg-open";
        paths = lib.mapAttrsToList wrapSpawn {
          xdg-open.pkg = xdg-utils;
          xdg-terminal-exec.arg = "--dir=\"$(pwd)\"";
        };
      };
    in
      [ uutils-coreutils-noprefix fd ripgrep xdg-open helix ghostty brave ];

    variables.EDITOR = "hx";

    etc."xdg/ghostty/config".text = ''
      resize-overlay = never
      app-notifications = false
      confirm-close-surface = false
    '';
  };

  programs.niri.bindings."Mod+Return" = "spawn \"${lib.getExe pkgs.walker}\"";

  xdg = {
    terminal-exec.enable = true;

    dirs = {
      config = {
        walker.create = true;
        "BraveSoftware/Brave-Browser".persist = true;
      };
      cache = {
        helix.create = true;
        walker.create = true;
        ghostty.create = true;
        "BraveSoftware/Brave-Browser".create = true;
      };
    };
  };
}

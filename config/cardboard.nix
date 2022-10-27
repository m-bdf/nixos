{ config, lib, pkgs, ... }:

let
  rc =
  let
    inherit (config.environment) defaultTerminal defaultBrowser;
  in
    pkgs.writeShellScript "cardboardrc" ''
      target="wayland-instance@$WAYLAND_DISPLAY.target"
      #trap "systemctl --user stop $target" TERM
      systemctl --user start $target

      cutter bind alt+Return exec "${defaultTerminal}"
      cutter bind super+Return exec "${defaultBrowser}"

      cutter bind alt+Left focus left
      cutter bind alt+Right focus right
      cutter bind super+Left move -10 0
      cutter bind super+Right move 10 0

      for i in $(seq 1 9); do
        workspace=$((i - 1))
        cutter bind alt+$i workspace switch $workspace
        cutter bind super+$i workspace move $workspace
      done

      cutter bind alt+Backspace close
      cutter bind super+Escape quit
    '';
in

{
  environment = {
    systemPackages = [ pkgs.cardboard ];
    etc."cardboard/cardboardrc".source = rc;
  };
}

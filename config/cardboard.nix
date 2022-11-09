{ config, pkgs, ... }:

let
  rc =
  let
    inherit (config.environment) defaultTerminal defaultBrowser;
  in
    pkgs.writeShellScript "cardboardrc" ''
      export PATH+=:${pkgs.cardboard}/bin XDG_CURRENT_DESKTOP=cardboard
      variables="WAYLAND_DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP"
      systemctl --user is-active graphical-session.target && cutter quit
      trap "
        systemctl --user unset-environment $variables
        systemctl --user stop graphical-session.target
      " EXIT
      systemctl --user import-environment $variables
      systemctl --user start graphical-session.target

      cutter bind alt+Return exec ${defaultTerminal}
      cutter bind super+Return exec ${defaultBrowser}

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

      sleep infinity
    '';
in

{
  environment = {
    systemPackages = [ pkgs.cardboard ];
    shellAliases.cardboard = "session-run cardboard";
    etc."cardboard/cardboardrc".source = rc;
  };
}

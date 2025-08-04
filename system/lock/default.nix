{ lib, pkgs, ... }:

{
  environment.etc."xdg/hypr/hyprlock.conf".text =
  let
    mkPowerButton = i: { icon, cmd }: ''
      label {
        halign = right
        valign = top
        position = ${toString ((1 - i) * 33)}, -7

        font_size = 11
        text = cmd[] echo ' ${icon}  '
        onclick = ${cmd}
      }
    '';
  in
    lib.readFile ./config.conf +
    lib.concatImapStrings mkPowerButton [
      { icon = ""; cmd = "systemctl reboot"; }
      { icon = "⏻"; cmd = "systemctl poweroff"; }
      { icon = ""; cmd = "niri msg action quit --skip-confirmation"; }
    ];

  programs.niri = {
    startup = lib.getExe pkgs.hyprlock;
    keybinds.XF86AudioMedia = lib.getExe pkgs.hyprlock;
  };

  security.pam = {
    services.hyprlock.nodelay = true;
    fprintd.enable = false;
  };

  xdg.dirs.state.fprint.persist = true;
}

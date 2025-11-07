{ inputs, lib, pkgs, ... }:

{
  disabledModules = [ "security/pam.nix" ];
  imports = [
    (inputs.fprintd + /nixos/modules/security/pam.nix)
  ];

  home.programs.hyprlock = {
    enable = true;
    extraConfig = lib.readFile ./config.conf;

    settings.label =
    let
      mkPowerButton = i: { icon, cmd }: {
        halign = "right";
        valign = "top";
        position = "${toString ((1 - i) * 33)}, -7";

        font_size = 11;
        text = "cmd[] echo ' ${icon}  '";
        onclick = cmd;
      };
    in
      lib.imap mkPowerButton [
        { icon = ""; cmd = "systemctl reboot"; }
        { icon = "⏻"; cmd = "systemctl poweroff"; }
        { icon = ""; cmd = "niri msg action quit --skip-confirmation"; }
      ];
  };

  programs.niri = {
    startup = lib.getExe pkgs.hyprlock;
    keybinds.XF86AudioMedia = lib.getExe pkgs.hyprlock;
  };

  security.pam = {
    services.hyprlock.nodelay = true;
    fprintd.enable = false;
  };

  home.xdg.stateFile.fprint.persist = true;
}

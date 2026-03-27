{ lib, pkgs, ... }:

let
  wvkbd = pkgs.wvkbd.overrideAttrs {
    patchPhase = ''
      sed -i 's/NumLayouts - 1/NumLayouts/' main.c keyboard.c
    '';
  };
in

{
  i18n.defaultLocale = "en_IE.UTF-8";

  services = {
    automatic-timezoned.enable = true;
    geoclue2.submitData = true;

    xserver.xkb.layout = "eu";
    kmscon.useXkbConfig = true;
  };

  programs.niri = {
    startup = "${lib.getExe wvkbd} -L 250 --hidden --landscape-layers index";
    keybinds = {
      "Win+Space" = "${pkgs.uutils-procps}/bin/pkill wvkbd -RTMIN";

      XF86MonBrightnessUp = "xbacklight -inc 5";
      XF86MonBrightnessDown = "xbacklight -dec 5";
    };
  };

  hardware.acpilight.enable = true;
  users.users.user.extraGroups = [ "video" ];

  home.services.gammastep = {
    enable = true;
    provider = "geoclue2";
  };

  systemd.user.services.geoclue-agent.enable = false;
}

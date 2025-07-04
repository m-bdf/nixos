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

  systemd.globalEnvironment.XKB_DEFAULT_LAYOUT = "eu";
  programs = {
    niri = {
      startup = "${lib.getExe wvkbd} -L 250 --hidden --landscape-layers index";
      keybinds."Win+Space" = "pkill wvkbd -RTMIN";
    };

    light = {
      enable = true;
      brightnessKeys.enable = true;
    };
  };

  systemd = {
    packages = [
      (pkgs.gammastep.override {
        withRandr = false;
        withDrm = false;
        withVidmode = false;
        withAppIndicator = false;
      })
    ];

    user.services = {
      gammastep.wantedBy = [ "graphical-session.target" ];
      geoclue-agent.enable = false;
    };
  };

  services = {
    automatic-timezoned.enable = true;
    geoclue2.submitData = true;
  };
}

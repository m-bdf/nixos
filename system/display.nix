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
      (pkgs.sunsetr.overrideAttrs {
        postInstall = ''
          substituteInPlace sunsetr.service --replace-fail /usr $out
          install -Dm644 sunsetr.service $out/lib/systemd/user/sunsetr.service
        '';
        doCheck = false; # tmp
      })
    ];

    user.services = {
      sunsetr.wantedBy = [ "graphical-session.target" ];
      geoclue-agent.enable = false;
    };
  };
}

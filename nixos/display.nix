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

  systemd = {
    services.systemd-timedated = {
      serviceConfig.StateDirectory = "systemd";
      environment.SYSTEMD_ETC_LOCALTIME = "%S/systemd/localtime";
    };
    paths.systemd-localtime = {
      pathConfig.PathChanged = "%S/systemd";
      wantedBy = [ "systemd-timedated.service" ];
    };
    services.systemd-localtime.serviceConfig = {
      Type = "oneshot";
      ExecSearchPath = lib.makeBinPath [ pkgs.util-linuxMinimal ];
      ExecStartPre = "-umount %E/%J";
      ExecStart = "mount %S/%P %E/%J -Bro X-mount.nocanonicalize";
    };
  };

  time.timeZone = lib.mkForce "UTC";
  services = {
    automatic-timezoned.enable = true;
    geoclue2.submitData = true;

    xserver.xkb.layout = "eu";
    kmscon.useXkbConfig = true;
  };

  programs.niri = {
    startup = "${lib.getExe wvkbd} -L 250 --hidden --landscape-layers index";
    keybinds = {
      "Win+Space" = "pkill wvkbd -RTMIN";

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
}

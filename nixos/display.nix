{ lib, pkgs, ... }:

{
  hardware.acpilight.enable = true;
  users.users.user.extraGroups = [ "video" ];
  home = {
    wayland.keybinds = {
      XF86MonBrightnessUp = "xbacklight -inc 5";
      XF86MonBrightnessDown = "xbacklight -dec 5";
    };

    services.gammastep = {
      enable = true;
      provider = "geoclue2";
    };
  };
  services = {
    geoclue2.submitData = true;
    automatic-timezoned.enable = true;
  };
  time.timeZone = lib.mkForce "UTC";

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
}

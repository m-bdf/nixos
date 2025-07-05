{ lib, pkgs, ... }:

{
  i18n.defaultLocale = "en_IE.UTF-8";

  systemd.globalEnvironment.XKB_DEFAULT_LAYOUT = "eu";
  programs = {
    niri = {
      startup = "${lib.getExe pkgs.wvkbd} -L 250 --hidden --landscape-layers index";
      keybinds."Win+Space" = "spawn \"pkill\" \"wvkbd\" \"-RTMIN\"";
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

  xdg.dirs.cache = {
    mesa_shader_cache.create = true;
    mesa_shader_cache_db.create = true;
    radv_builtin_shaders.create = true;
  };
}

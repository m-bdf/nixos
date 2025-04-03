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
  users.users.user.extraGroups = [ "video" ];

  services = {
    redshift = {
      enable = true;
      package = pkgs.gammastep;
      executable = "/bin/gammastep";
    };

    localtimed.enable = true;
  };
  location.provider = "geoclue2";

  xdg.dirs.cache = {
    mesa_shader_cache.create = true;
    mesa_shader_cache_db.create = true;
    radv_builtin_shaders.create = true;
  };
}

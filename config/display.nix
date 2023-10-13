{ pkgs, ... }:

{
  i18n.defaultLocale = "en_IE.UTF-8";

  environment.variables.XKB_DEFAULT_LAYOUT = "eu";
  systemd.globalEnvironment.XKB_DEFAULT_LAYOUT = "eu";

  programs.light = {
    enable = true;
    brightnessKeys.enable = true;
  };

  services = {
    redshift = {
      enable = true;
      package = pkgs.gammastep;
      executable = "/bin/gammastep";
    };

    localtimed.enable = true;
  };
  location.provider = "geoclue2";
}

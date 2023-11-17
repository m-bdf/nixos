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

    automatic-timezoned.enable = true;
    geoclue2.geoProviderUrl =
      "https://www.googleapis.com/geolocation/v1/geolocate?key="
        + "AIzaSyDwr302FpOSkGRpLlUpPThNTDPbXcIn_FM"; # Arch Linux key
  };
  location.provider = "geoclue2";
  environment.etc.localtime.source = "/etc/zoneinfo/UTC";
}

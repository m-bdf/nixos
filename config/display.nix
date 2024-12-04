{ pkgs, ... }:

{
  i18n.defaultLocale = "en_IE.UTF-8";

  environment.variables.XKB_DEFAULT_LAYOUT = "eu";
  systemd.globalEnvironment.XKB_DEFAULT_LAYOUT = "eu";

  programs.light = {
    enable = true;
    brightnessKeys.enable = true;
  };
  users.users.user.extraGroups = [ "video" ];

  services = {
    redshift = {
      enable = true;
      package = pkgs.gammastep;
      executable = "/bin/gammastep";
    };

    automatic-timezoned.enable = true;
    geoclue2 = {
      geoProviderUrl = "https://api.beacondb.net/v1/geolocate";
      submissionUrl = "https://api.beacondb.net/v2/geosubmit";
      submitData = true;
    };
  };
  location.provider = "geoclue2";
}

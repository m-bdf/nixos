{ config, pkgs, ... }:

{
  console.enable = false;
  boot = {
    kernelParams = [ "quiet" "fbcon=map:null" ];

    plymouth = {
      enable = true;
      theme = "blahaj";
      themePackages = [ pkgs.plymouth-blahaj-theme ];
    };
  };

  services = {

    kmscon = {
      enable = true;
      hwRender = true;
    };

    greetd = {
      enable = true;
      settings.default_session = {
        user = config.users.users.user.name;
        command = "niri-session";
      };
    };

    logind = {
      lidSwitch = "ignore";
      powerKey = "hybrid-sleep";
    };
    upower.enable = true;
  };
}

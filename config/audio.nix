{ lib, pkgs, musnix, ... }:

{
  imports = [ musnix.nixosModules.musnix ];

  environment = {
    systemPackages = with pkgs; [ vcv-rack sonic-pi zrythm ];
    sessionVariables = {
      RACK_USER_DIR = "/usr/share/Rack2";
      SONIC_PI_HOME = "/usr/share/SonicPi";
    };
  };

  musnix.enable = true;
  security.rtkit.enable = true;
  users.users.user.extraGroups = [ "audio" ];

  services = {
    pipewire = {
      enable = true;
      pulse.enable = true;
      jack.enable = true;
    };

    playerctld.enable = true;
  };

  sound = {
    enable = true;
    mediaKeys.enable = true;
  };

  hardware.bluetooth.enable = true;

  xdg.dirs = {
    data = {
      Rack2.persist = true;
      SonicPi.persist = true;
      zrythm.persist = true;
    };
    state = {
      wireplumber.create = true;
      bluetooth.persist = true;
    };
  };
}

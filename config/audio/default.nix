{ pkgs, ... }:

{
  imports = [ ./binds.nix ];

  environment = {
    systemPackages = with pkgs; [ sonic-pi ];
    sessionVariables.SONIC_PI_HOME = "/usr/share/SonicPi";
  };

  services = {
    pipewire = {
      enable = true;
      pulse.enable = true;
      jack.enable = true;
    };

    playerctld.enable = true;
  };

  hardware.bluetooth.enable = true;

  xdg.dirs = {
    data.SonicPi.persist = true;
    state = {
      wireplumber.create = true;
      bluetooth.persist = true;
    };
  };
}

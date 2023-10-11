{
  services = {
    pipewire = {
      enable = true;
      pulse.enable = true;
    };

    playerctld.enable = true;
  };

  sound = {
    enable = true;
    mediaKeys.enable = true;
  };

  hardware.bluetooth.enable = true;

  xdg.dirs.state = {
    wireplumber.create = true;
    bluetooth.persist = true;
  };
}

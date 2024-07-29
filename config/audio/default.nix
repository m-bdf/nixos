{
  imports = [ ./binds.nix ];

  services = {
    pipewire = {
      enable = true;
      pulse.enable = true;
    };

    playerctld.enable = true;
  };

  hardware.bluetooth.enable = true;

  xdg.dirs.state = {
    wireplumber.create = true;
    bluetooth.persist = true;
  };
}

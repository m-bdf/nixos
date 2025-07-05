{
  users = {
    mutableUsers = false;

    users.user = {
      name = "mae";
      home = "/home";
      createHome = false;

      isNormalUser = true;
      password = "mae";
      group = "wheel";
    };
  };

  security.sudo-rs = {
    enable = true;
    execWheelOnly = true;
  };

  nix.settings.trusted-users = [ "@wheel" ];

  xdg.dirs.state.nixos.persist = true; # UIDs GIDs
}

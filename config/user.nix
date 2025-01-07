{ config, ... }:

{
  users = {
    mutableUsers = false;

    users.user = {
      name = "mae";
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      home = "/home";
      password = "";
    };
  };

  security.sudo-rs = {
    enable = true;
    execWheelOnly = true;
  };

  nix.settings.trusted-users = [ config.users.users.user.name ];

  xdg.dirs = {
    state.nixos.persist = true; # UIDs GIDs
    home = {
      Documents.persist = true;
      Downloads.persist = true;
    };
  };
}

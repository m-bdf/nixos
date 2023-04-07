{ config, ... }:

{
  users = {
    mutableUsers = false;

    users.user = {
      name = "mae";
      isNormalUser = config.isWsl or true;
      extraGroups = [ "wheel" ];
      home = "/home";
      password = "";
    };
  };

  xdg.dirs = {
    state.nixos.persist = true; # UIDs GIDs
    home = {
      Documents.persist = true;
      Downloads.persist = true;
    };
  };
}

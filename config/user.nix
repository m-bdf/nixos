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

  xdg.basedirs.state.nixos.persist = true;
}

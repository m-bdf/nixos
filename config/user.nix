{ inputs, lib, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    (lib.mkAliasOptionModule [ "home" ] [ "home-manager" "users" "user" ])
  ];

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

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  xdg.dirs.state.nixos.persist = true; # UIDs GIDs
}

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

  systemd.services.home-manager-mae.environment =
    { HOME = "/"; SKIP_SANITY_CHECKS = "1"; };

  home.xdg.stateFile.nixos.persist = true; # UIDs GIDs
}

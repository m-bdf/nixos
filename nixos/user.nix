{ inputs, lib, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    (lib.mkAliasOptionModule [ "home" ] [ "home-manager" "users" "user" ])
  ];

  users = {
    mutableUsers = false;

    users.user = {
      name = "mae";
      group = "wheel";
      password = "mae";
      isNormalUser = true;

      home = "/home";
      createHome = false;
      shell = pkgs.fish;
    };
  };

  security = {
    sudo-rs = {
      enable = true;
      execWheelOnly = true;
    };
    soteria.enable = true;
  };

  programs.fish = {
    enable = true;
    useBabelfish = true;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs.inputs = inputs;
  };

  home.xdg.stateFile.nixos.persist = true; # UIDs GIDs
}

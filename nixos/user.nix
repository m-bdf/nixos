{ pkgs, ... }:

{
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

  nix.settings.trusted-users = [ "@wheel" ];

  programs.fish = {
    enable = true;
    useBabelfish = true;
  };

  home.xdg.stateFile.nixos.persist = true; # UIDs GIDs
}

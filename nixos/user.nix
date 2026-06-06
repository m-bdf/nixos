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
      ignoreShellProgramCheck = true;
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
}

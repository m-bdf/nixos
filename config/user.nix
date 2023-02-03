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
}

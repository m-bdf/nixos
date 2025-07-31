{ lib, ... }:

{
  home = {
    username = "mae";
    homeDirectory = lib.mkDefault "/home/mae";
    preferXdgDirectories = true;
    stateVersion = lib.trivial.release;
  };
}

{ config, lib, ... }:

{
  nix = {
    channel.enable = false;
    extraOptions = config.home.nix.extraOptions;
  };

  system = {
    disableInstallerTools = true;
    stateVersion = lib.trivial.release;
  };
}

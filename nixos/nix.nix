{ config, lib, ... }:

{
  nix = {
    channel.enable = false;
    inherit (config.home.nix) extraOptions;
  };

  system = {
    disableInstallerTools = true;
    stateVersion = lib.trivial.release;
  };
}

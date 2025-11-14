{ lib, ... }:

{
  nix.channel.enable = false;

  system = {
    disableInstallerTools = true;
    stateVersion = lib.trivial.release;
  };
}

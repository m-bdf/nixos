{ config, lib, ... }:

{
  options.system.path = config.home.lib.mkPathOption;

  config.programs = {
    less.enable = lib.mkForce false;
    nano.enable = false;
  };
}

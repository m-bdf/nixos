{ config, lib, ... }:

{
  options.system.build.toplevel = config.home.lib.mkToplevelOption;

  config = {
    programs = {
      less.enable = lib.mkForce false;
      nano.enable = false;
    };

    documentation.man.generateCaches = false;
  };
}

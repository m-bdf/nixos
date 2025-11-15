{ config, lib, ... }:

{
  options.system = {
    build.toplevel = config.home.lib.mkToplevelOption;
    path = config.home.lib.mkPathOption;
  };

  config = {
    environment.corePackages = lib.mkForce [];
    programs = {
      less.enable = lib.mkForce false;
      nano.enable = false;
    };

    documentation.man.generateCaches = false;
  };
}

{ config, lib, ... }:

{
  options.system = {
    build.toplevel = config.home.lib.mkToplevelOption;

    path = lib.mkOption {
      apply = drv: drv.override {
        includeClosures = true;
        ignoreCollisions = true;
      };
    };
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

{ config, lib, ... }:

{
  options.system.build.toplevel = config.home.lib.mkToplevelOption;

  config = {
    # prevent uutils-coreutils' mv from asking for confirmation
    system.activationScripts.binsh.text = lib.mkBefore "exec <&-";

    programs = {
      bash.enable = false;
      less.enable = lib.mkForce false;
      nano.enable = false;
    };
    environment = {
      sessionVariables = {
        PATH = "/bin";
        SYSTEMD_PAGERSECURE = "1";
      };
      corePackages = lib.mkForce [];
    };
  };
}

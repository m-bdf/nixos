{ inputs, config, lib, ... }:

{
  imports = [ inputs.preservation.nixosModules.preservation ];

  home.xdg = {
    cacheHome = "/var/cache";
    configHome = "/etc/xdg";
    dataHome = "/usr/share";
    stateHome = "/var/lib";
  };

  environment.sessionVariables =
    config.home.systemd.user.sessionVariables;

  preservation.preserveAt.state.directories = with lib;
    concatMap (f: optional f.persist ({
      directory = f.target;
      inInitrd = mkIf f.force true;
      mountOptions = mkIf (f.executable == true) [ "exec" ];
    } // optionalAttrs (!f.force) rec {
      user = config.users.users.user.name;
      group = config.users.users.user.group;
      parent = { inherit user group; };
      configureParent = true;
    })) (attrValues config.home.home.file);
}

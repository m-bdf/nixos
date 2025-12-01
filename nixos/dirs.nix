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
    concatMap (f: optional f.persist rec {
      directory = f.target;
      mountOptions = mkIf (f.executable == true) [ "exec" ];

      user = config.users.users.user.name;
      group = config.users.users.user.group;
      parent = { inherit user group; };
      configureParent = true;
    }) (attrValues config.home.home.file);
}

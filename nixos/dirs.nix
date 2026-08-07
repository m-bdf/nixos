{ inputs, config, lib, ... }:

rec {
  imports = [ inputs.preservation.nixosModules.preservation ];

  home.xdg = {
    cacheHome = "/var/cache";
    configHome = "/etc/xdg";
    dataHome = "/usr/share";
    stateHome = "/var/lib";
  };

  systemd = {
    tmpfiles.rules =
      map (d: "d ${d} 1777") (lib.attrValues home.xdg);

    user.services.home-manager.environment =
      { HOME = ""; SKIP_SANITY_CHECKS = ""; };
  };

  environment.sessionVariables =
    config.home.systemd.user.sessionVariables;

  preservation.preserveAt.state.directories = with lib;
    concatMap (d: optional d.persist {
      directory = d.target;
      user = config.users.users.user.name;
      group = config.users.users.user.group;
      mountOptions = mkIf (d.executable == true) [ "exec" ];
    }) (attrValues config.home.home.file);
}

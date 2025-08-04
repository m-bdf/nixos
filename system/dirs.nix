{ inputs, config, lib, ... }:

with lib;

let
  user = config.users.users.user.name;
in

rec
{
  imports = [ inputs.preservation.nixosModules.preservation ];

  home.xdg = {
    cacheHome = "/var/cache";
    configHome = "/etc/xdg";
    dataHome = "/usr/share";
    stateHome = "/var/lib";
  };

  environment.sessionVariables = config.home.systemd.user.sessionVariables;

  systemd.tmpfiles.rules =
    map (path: "d ${path} - ${user}") (attrValues home.xdg);

  preservation.preserveAt.state.directories =
    concatMap (f: optional f.persist {
      directory = f.target;
      inherit user;
      mountOptions = optional (f.executable == true) "exec";
    }) (attrValues config.home.home.file);
}

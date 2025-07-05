{ inputs, config, lib, ... }:

with lib;

let
  basedirs = {
    data = "/usr/share";
    config = "/etc/xdg";
    state = "/var/lib";
    cache = "/var/cache";
  };

  dirs = basedirs // { home = "/home"; };
in

{
  imports = [ inputs.preservation.nixosModules.preservation ];

  options.xdg.dirs =
  let
    type = with types; attrsOf (submodule {
      options = {
        create = mkEnableOption "automatic creation of this directory";
        persist = mkEnableOption "persistence for this directory";
      };
    });
  in
    mapAttrs (name: path: mkOption { inherit type; default = {}; }) dirs;

  config =
  let
    filterMapEnabledSubdirs = attr: fn: dir: subdirs:
      map (subdir: fn (dir + "/${subdir}"))
        (attrNames (filterAttrs (path: cfg: cfg.${attr}) subdirs));

    filterMapSubdirs = attr: fn:
      concatLists (mapAttrsToList (dir:
        filterMapEnabledSubdirs attr fn dirs.${dir}
      ) config.xdg.dirs);

    inherit (config.users.users) user;
  in
  {
    environment.sessionVariables = mapAttrs' (name: path:
      nameValuePair "XDG_${toUpper name}_HOME" path
    ) basedirs;

    systemd.tmpfiles.rules = filterMapSubdirs "create"
      (path: "d ${path} - ${user.name} ${user.group}");

    preservation.preserveAt.state.directories = filterMapSubdirs "persist"
      (path: { directory = path; user = user.name; group = user.group; });
  };
}

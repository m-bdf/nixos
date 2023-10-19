{ config, lib, impermanence, ... }:

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
  imports = [ impermanence.nixosModules.impermanence ];

  options.xdg.dirs =
  let
    type = types.attrsOf (types.submodule {
      options = {
        create = mkEnableOption "automatic creation of this directory";
        persist = mkEnableOption "persistence for this directory";
      };
    });
  in
    mapAttrs (name: path: mkOption { inherit type; default = {}; }) dirs;

  config =
  let
    filterMapSubdirs = attr: fn: dir: subdirs:
      map (subdir: fn (dir + "/${subdir}"))
        (attrNames (filterAttrs (path: cfg: cfg.${attr}) subdirs));

    filterMapEnabledSubdirs = attr: fn:
      concatLists (mapAttrsToList (dir:
        filterMapSubdirs attr fn dirs.${dir}
      ) config.xdg.dirs);

    inherit (config.users.users) user;
  in
  {
    environment = {
      sessionVariables = mapAttrs' (name: path:
        nameValuePair "XDG_${toUpper name}_HOME" path
      ) basedirs;

      persistence.storage.directories = filterMapEnabledSubdirs "persist"
        (path: { directory = path; user = user.name; group = user.group; });
    };

    systemd.tmpfiles.rules = filterMapEnabledSubdirs "create"
      (path: "d ${path} - ${user.name} ${user.group}");
  };
}

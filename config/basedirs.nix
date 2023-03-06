{ config, lib, impermanence, ... }:

with lib;

let
  basedirs = {
    config = "/etc";
    cache = "/var/cache";
    data = "/usr/share";
    state = "/var/lib";
  };
in

{
  imports = [ impermanence.nixosModules.impermanence ];

  options.xdg.basedirs =
  let
    type = types.attrsOf (types.submodule {
      options = {
        create = mkEnableOption "automatic creation of this directory";
        persist = mkEnableOption "persistence for this directory";
      };
    });
  in
    mapAttrs (name: path: mkOption { inherit type; default = {}; }) basedirs;

  config =
  let
    filterMapSubdirs = attr: fn: dir: subdirs:
      map (subdir: fn (dir + "/${subdir}"))
        (attrNames (filterAttrs (path: cfg: cfg.${attr}) subdirs));

    filterMapEnabledSubdirs = attr: fn:
      concatLists (mapAttrsToList (basedir:
        filterMapSubdirs attr fn basedirs.${basedir}
      ) config.xdg.basedirs);

    inherit (config.users.users) user;
  in
  {
    environment = {
      sessionVariables = mapAttrs' (name: path:
        nameValuePair "XDG_${toUpper name}_HOME" path
      ) basedirs;

      persistence."/nix".directories = filterMapEnabledSubdirs "persist"
        (path: { directory = path; user = user.name; group = user.group; });
    };

    systemd.tmpfiles.rules = filterMapEnabledSubdirs "create"
      (path: "d ${path} - ${user.name} ${user.group}");
  };
}

{ inputs, config, lib, ... }:

with lib;

let
  basedirs = {
    data = "/usr/share";
    config = "/etc/xdg";
    state = "/var/lib";
    cache = "/var/cache";
  };
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
    mapAttrs (name: path: mkOption { inherit type; default = {}; }) basedirs;

  config =
  let
    mapSubdirs = attr: fn:
      flatten (mapAttrsToList (name: mapAttrsToList (subdir: cfg:
        optional cfg.${attr} (fn "${basedirs.${name}}/${subdir}")
      )) config.xdg.dirs);

    user = config.users.users.user.name;
  in
  {
    environment.sessionVariables = mapAttrs' (name: path:
      nameValuePair "XDG_${toUpper name}_HOME" path
    ) basedirs;

    systemd.tmpfiles.rules =
      mapSubdirs "create" (path: "d ${path} - ${user}");

    preservation.preserveAt.state.directories =
      mapSubdirs "persist" (path: { directory = path; inherit user; });
  };
}

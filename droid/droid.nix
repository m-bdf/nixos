{ options, lib, ... }:

{
  imports = [
    (lib.mkAliasOptionModule [ "home" ] [ "home-manager" "config" ])
  ];

  user.userName = "mae";

  system.stateVersion = lib.last
    options.system.stateVersion.type.functor.payload.values;

  home-manager.useGlobalPkgs = true;
}

{ lib, pkgs, ... }:

let
  config = {
    globalSection = {};
    sections = {};
  };
in

{
  environment = {
    systemPackages = [ pkgs.foot ];
    etc."foot/foot.ini".text =
      lib.generators.toINIWithGlobalSection {} config;
  };

  systemd = {
    packages = [ pkgs.foot ];

    user.sockets."foot-server@" = {
      wantedBy = [ "wayland-instance@.target" ]; #81138
      partOf = [ "wayland-instance@.target" ];
      after = [ "wayland-instance@.target" ];
    };
  };
}

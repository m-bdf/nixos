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
    defaultTerminal =
      "env --unset=WAYLAND_DISPLAY ${pkgs.foot}/bin/footclient";

    etc."foot/foot.ini".source = pkgs.writeTextFile {
      name = "foot/foot.ini";
      text = lib.generators.toINIWithGlobalSection {} config;
      checkPhase =
        "${pkgs.foot}/bin/foot --config=$target --check-config";
    };
  };

  systemd.user = {
    services.foot-server = {
      description = "Foot terminal server";
      documentation = [ "man:foot(1)" ];
      serviceConfig.ExecStart = "${pkgs.foot}/bin/foot --server=3";
      requires = [ "%N.socket" ];
    };

    sockets.foot-server = {
      listenStreams = [ "%t/foot.sock" ];
      unitConfig.DefaultDependencies = false;
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
    };
  };
}

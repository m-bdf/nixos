{ lib, pkgs, ... }:

let
  wayvnc = pkgs.wayvnc.overrideAttrs {
    patches = [
      (pkgs.fetchpatch {
        url = "https://github.com/any1/wayvnc/pull/396.patch";
        hash = "sha256-IEfHVhWj075DQ+HRnGL8zhsVaj813UWEOiYnOUYS/50=";
      })
    ];
  };
in

{
  networking.firewall.allowedTCPPorts = [ 5900 ];

  systemd.user = {
    sockets.wayvnc = {
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      socketConfig.ListenStream = 5900;
    };

    services.wayvnc = {
      requires = [ "wayvnc.socket" ];
      serviceConfig.ExecStart = toString [
        (lib.getExe wayvnc)
        "--external-listener-fd 3"
        "--exit-on-disconnect"
        "--log-level info"
      ];
    };
  };

  environment.etc."xdg/wayvnc/config".text = ''
    enable_auth=true
    enable_pam=true
    relax_encryption=true
  '';

  security.pam.services.wayvnc = {};
}

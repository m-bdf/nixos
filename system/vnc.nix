{ lib, pkgs, ... }:

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
        (lib.getExe pkgs.wayvnc)
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

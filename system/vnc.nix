{ lib, pkgs, ... }:

{
  programs.wayvnc.enable = true;

  environment.etc."xdg/wayvnc/config".text = ''
    enable_auth=true
    enable_pam=true
    relax_encryption=true
  '';


  systemd.user = {
    services.wayvnc = {
      serviceConfig.ExecStart = toString [
        (lib.getExe pkgs.wayvnc)
        "--external-listener-fd 3"
        "--exit-on-disconnect"
        "--log-level info"
      ];
      requires = [ "wayvnc.socket" ];
    };

    sockets.wayvnc = {
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      socketConfig.ListenStream = 5900;
    };
  };

  networking.firewall.allowedTCPPorts = [ 5900 ];
}

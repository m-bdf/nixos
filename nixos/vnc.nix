{ lib, pkgs, ... }:

{
  programs.wayvnc.enable = true;

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 5900 ];

  home = {
    systemd.user = {
      sockets.wayvnc = {
        Socket.ListenStream = 5900;
        Unit = {
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      services.wayvnc = {
        Service.ExecStart = toString [
          (lib.getExe pkgs.wayvnc)
          "--external-listener-fd 3"
          "--exit-on-disconnect"
          "--log-level info"
        ];
        Unit.Requires = [ "wayvnc.socket" ];
      };
    };

    xdg.configFile."wayvnc/config".text = ''
      enable_auth=true
      enable_pam=true
      relax_encryption=true
    '';
  };
}

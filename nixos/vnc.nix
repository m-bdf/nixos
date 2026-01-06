{ inputs, lib, pkgs, ... }:

let
  wayvnc = pkgs.wayvnc.overrideAttrs {
    version = "git";
    src = inputs.wayvnc;
  };
in

{
  programs.wayvnc.enable = true;
  programs.wayvnc.package = wayvnc;

  home.xdg.configFile."wayvnc/config".text = ''
    enable_auth=true
    enable_pam=true
    relax_encryption=true
  '';

  systemd.user = {
    services.wayvnc = {
      serviceConfig.ExecStart = toString [
        (lib.getExe wayvnc)
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

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 5900 ];
}

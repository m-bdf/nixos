{ lib, pkgs, ... }:

{
  networking = {
    useNetworkd = true;

    wireless.iwd = {
      enable = true;
      settings.General = {
        EnableNetworkConfiguration = true;
        AddressRandomization = "network";
        DisableANQP = false;
      };
    };

    firewall.allowedTCPPorts = [ 5900 ];
  };

  systemd = {
    targets.network-online.wantedBy = lib.mkForce []; #86273

    user.services.wayvnc = {
      inherit (pkgs.wayvnc.meta) description;
      serviceConfig.ExecStart =
        "${lib.getExe pkgs.wayvnc} 0.0.0.0";

      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
    };
  };

  services = {
    avahi = {
      enable = true;
      ipv6 = true;
      nssmdns4 = true;
      nssmdns6 = true;
    };
    printing.enable = true;
  };

  xdg.dirs.state.iwd.persist = true; # networks
}

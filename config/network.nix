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

    nftables.enable = true;
    # firewall.allowedTCPPorts = [ 5555 ];
  };

  systemd = {
    targets.network-online.wantedBy = lib.mkForce []; #86273

    user.services.wayvnc = {
      inherit (pkgs.wayvnc.meta) description;
      serviceConfig = {
        ExecStart = lib.getExe pkgs.wayvnc;
        Restart = "always";
      };

      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
    };
  };

  services = {
    softether = {
      # enable = true;
      vpnserver.enable = true;
    };

    # avahi = {
    #   enable = true;
    #   nssmdns4 = true;
    #   nssmdns6 = true;
    # };
    # printing.enable = true;
  };

  xdg.dirs.state = {
    iwd.persist = true; # networks
    softether.create = true;
  };
}

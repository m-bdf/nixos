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
  };

  services = {
    avahi.enable = true;
    printing.enable = true;
    openssh.enable = true;
  };

  systemd.user.services.wayvnc = {
    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.wayvnc} --log-level=info";
      Restart = "always";
    };

    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
  };

  xdg.dirs.state.iwd.persist = true; # networks
}

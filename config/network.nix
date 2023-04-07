{ config, lib, ... }:

{
  networking = config.isWsl or {
    useNetworkd = true;

    wireless.iwd = {
      enable = true;
      settings.General = {
        EnableNetworkConfiguration = true;
        AddressRandomization = "network";
        DisableANQP = false;
      };
    };
  };

  services.resolved.dnssec = "false";

  systemd = {
    targets.network-online.wantedBy = lib.mkForce []; #86273
    network.wait-online.anyInterface = true;
  };

  xdg.dirs.state.iwd.persist = true; # networks
}

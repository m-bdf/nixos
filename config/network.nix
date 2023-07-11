{ lib, ... }:

{
  networking = {
    useNetworkd = true;

    wireless.iwd = {
      enable = true;
      settings = {
        General = {
          EnableNetworkConfiguration = true;
          AddressRandomization = "network";
          DisableANQP = false;
        };
        Network.EnableIPv6 = false;
      };
    };
  };

  systemd.targets.network-online.wantedBy = lib.mkForce []; #86273

  xdg.dirs.state.iwd.persist = true; # networks
}

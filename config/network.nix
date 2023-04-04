{ lib, ... }:

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
  };

  systemd.targets.network-online.wantedBy = lib.mkForce []; #86273

  xdg.basedirs.state.iwd.persist = true; # networks
}

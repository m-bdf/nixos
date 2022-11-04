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
        };
        Network.EnableIPv6 = true;
      };
    };
  };

  systemd = {
    targets.network-online.wantedBy = lib.mkForce []; #86273
    network.wait-online.anyInterface = true;
  };

  environment.persistence."/nix".directories = [ "/var/lib/iwd" ];
}

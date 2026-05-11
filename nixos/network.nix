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
          Country = "FR";
        };
        DriverQuirks.DefaultInterface = "*";
      };
    };

    nftables = {
      enable = true;
      flushRuleset = true;
    };
    firewall.allowedUDPPorts = [ 53 ];
  };

  services = {
    resolved.settings.Resolve = {
      DNSStubListenerExtra = "0.0.0.0";
      MulticastDNS = false;
      LLMNR = false;
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
    };
    printing.enable = true;
  };

  home.xdg.stateFile.iwd.persist = true; # networks
}

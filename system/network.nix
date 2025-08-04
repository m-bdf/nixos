{
  networking = {
    usePredictableInterfaceNames = false;
    useNetworkd = true;

    wireless.iwd = {
      enable = true;
      settings.General = {
        AddressRandomization = "network";
        DisableANQP = false;
      };
    };

    nftables = {
      enable = true;
      flushRuleset = true;
    };
  };

  services = {
    resolved = {
      mdns.enable = false;
      llmnr.enable = false;
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
    };
    printing.enable = true;
  };

  home.xdg.stateFile.iwd.persist = true; # networks
}

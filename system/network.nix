{ inputs, ... }:

{
  disabledModules = [ "system/boot/resolved.nix" ];
  imports = [
    (inputs.resolved + /nixos/modules/system/boot/resolved.nix)
  ];

  networking = {
    usePredictableInterfaceNames = false;
    useNetworkd = true;

    wireless.iwd = {
      enable = true;
      settings.General = {
        EnableNetworkConfiguration = true;
        AddressRandomization = "network";
        DisableANQP = false;
        Country = "FR";
      };
    };

    nftables = {
      enable = true;
      flushRuleset = true;
    };
    firewall.allowedUDPPorts = [ 53 ];
  };

  services = {
    resolved = {
      extraConfig = ''
        DNSStubListenerExtra=0.0.0.0
      '';

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

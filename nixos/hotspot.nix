{ config, lib, pkgs, ... }:

let
  ssid = "Maëlys' ${config.networking.hostName}";

  configDir = pkgs.writeTextDir "${ssid}.ap"
    (lib.generators.toINI {} {
      General.Channel = 36; # 5GHz
      Security.Passphrase = "Schmetterling";
      IPv4 = rec {
        Address = "192.168.250.1";
        Gateway = Address;
        DNSList = Address;
      };
    });
in

{
  networking.nat = {
    enable = true;
    internalInterfaces = [ "wlan0" ];
  };

  services.networkd-dispatcher = {
    enable = true;
    rules.hotspot = {
      onState = [ "routable" "off" ];
      script = ''
        PATH+=:${pkgs.iwd}/bin

        case "$IFACE-$STATE" in
          eth0-routable)
            ln -Tsf "${configDir}" \
              ${config.home.xdg.stateHome}/iwd/ap

            iwctl device wlan0 set-property Mode ap
            iwctl ap wlan0 start-profile "${ssid}"
            ;;

          eth0-off)
            iwctl device wlan0 set-property Mode station
            ;;

          wlan0-routable)
            networkctl reconfigure eth0
            ;;
        esac
      '';
    };
  };
}

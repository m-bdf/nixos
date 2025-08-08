{ config, lib, pkgs, ... }:

{
  services = {
    networkd-dispatcher.rules.tailscale = {
      onState = [ "routable" ];
      script = ''
        ${lib.getExe pkgs.ethtool} -K "$IFACE" \
          rx-udp-gro-forwarding on rx-gro-list off
      '';
    };

    tailscale = {
      enable = true;
      useRoutingFeatures = "server";
      extraSetFlags = [
        "--accept-dns=false"
        "--advertise-exit-node=true"
        "--advertise-routes=192.168.0.0/16"
        "--ssh=true"
        "--stateful-filtering=true"

        "--operator=${config.users.users.user.name}"
      ];
    };
  };

  systemd.services.tailscaled-set.serviceConfig.ExecStartPre =
    "-${lib.getExe pkgs.tailscale} up --reset --timeout=1s";

  home.xdg.stateFile.tailscale.persist = true;
}

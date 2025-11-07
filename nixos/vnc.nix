{ pkgs, ... }:

let
  wayvnc = pkgs.wayvnc.overrideAttrs {
    patches = [
      (pkgs.fetchpatch {
        url = "https://github.com/any1/wayvnc/pull/396.patch";
        hash = "sha256-IEfHVhWj075DQ+HRnGL8zhsVaj813UWEOiYnOUYS/50=";
      })
    ];
  };
in

{
  home.services.wayvnc = {
    enable = true;
    package = wayvnc;
    autoStart = true;

    settings = {
      address = "0.0.0.0";
      port = 5900;

      enable_auth = true;
      enable_pam = true;
      relax_encryption = true;
    };
  };

  programs.wayvnc.enable = true;

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 5900 ];
}

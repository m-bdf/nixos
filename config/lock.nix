{ lib, pkgs, ... }:

{
  services = {
    logind = {
      lidSwitch = "ignore";
      powerKey = "hybrid-sleep";
    };
    upower.enable = true;
  };

  security.pam.services.gtklock = {};

  programs.river.bindings = [{
    key = "XF86AudioMedia";
    cmd = lib.getExe pkgs.gtklock;
  }];
}

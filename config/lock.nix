{ lib, pkgs, ... }:

{
  services = {
    logind = {
      lidSwitch = "ignore";
      powerKey = "hybrid-sleep";
    };
    upower.enable = true;
  };

  programs.niri.bindings.XF86AudioMedia = ''
    ${lib.getExe pkgs.gtklock} \
      --modules ${pkgs.gtklock-powerbar-module}/lib/gtklock/* \
      --modules ${pkgs.gtklock-playerctl-module}/lib/gtklock/*
  '';

  security.pam.services.gtklock = {};
}

{ lib, pkgs, ... }:

let
  pkg = pkgs.river.override { xwaylandSupport = false; };

  init = pkgs.writeShellScript "river.init" ''
    riverctl map normal Alt Return spawn ${lib.getExe pkgs.foot}

    riverctl map normal Alt Backspace close
    riverctl map normal Super Escape exit

    riverctl default-layout rivertile
    rivertile
  '';
in

{
  environment = {
    systemPackages = [ pkg ];
    etc."river/init".source = init;
  };

  services.xserver.displayManager.sessionPackages = [ pkg ];
}

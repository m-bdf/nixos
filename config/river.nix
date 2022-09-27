{ pkgs, ... }:

let
  init = pkgs.writeShellScript "init" ''
    yambar &
    rivertile &
    foot --server &

    riverctl default-layout rivertile

    riverctl map normal Alt Return spawn footclient
    riverctl map normal Super Return spawn brave

    riverctl map normal Alt Tab zoom
    riverctl map normal Alt Backspace close
    riverctl map normal Super Escape exit
  '';
in

{
  environment = {
    systemPackages = [ pkgs.river pkgs.foot ];
    etc."river/init".source = init;
  };

  security.polkit.enable = true;
  hardware.opengl.enable = true;
}

{ config, lib, pkgs, ... }:

let
  pkg = config.programs.hyprland.package;

  conf = pkgs.writeText "hyprland.conf" ''
    bind = ALT, Return, exec, ${lib.getExe pkgs.alacritty}

    bind = ALT, Backspace, killactive
    bind = SUPER, Escape, exit
  '';

  wrapper = pkgs.writeShellScriptBin "Hyprland"
    "WLR_RENDERER_ALLOW_SOFTWARE=1 ${lib.getExe pkg} --config ${conf}";
in

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = false;
  };

  environment.systemPackages = [ wrapper ];
}

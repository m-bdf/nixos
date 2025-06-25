{ lib, pkgs, ... }:

let
  spawn = pkg: "${lib.getExe pkgs.niri} msg action spawn -- ${lib.getExe pkg}";
in

{
  layer = "top";
  height = 32;

  modules-left = [ "niri/workspaces" ];
  modules-center = [ "clock" ];
  modules-right = [ "network" "bluetooth" "wireplumber" "battery" ];

  clock = {
    interval = 1;
    format = "{:%A %d %B %Y %X}";
    tooltip = false;
    on-click = spawn pkgs.walker;
  };

  network = {
    format = "󰤭  Disconnected";
    format-ethernet = "󰈀  {ifname}";
    format-wifi = "{icon}  {essid}";
    format-icons = [ "󰤟" "󰤢" "󰤥" "󰤨" ];
    tooltip-format = "{ipaddr}";
    on-click = spawn pkgs.iwgtk;
    on-click-right = spawn pkgs.trayscale;
  };

  bluetooth = {
    format = "󰂲  Disconnected";
    format-connected = "󰂱  {device_alias}";
    on-click = spawn pkgs.overskride;
  };

  wireplumber = {
    format-muted = "󰝟  {volume}%";
    format = "{icon}  {volume}%";
    format-icons = [ "󰕿" "󰖀" "󰕾" ];
    on-click = spawn pkgs.pwvucontrol;
  };

  battery = {
    format = "{icon}  {capacity}%";
    format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
    states.critical = 5;
    on-click = spawn pkgs.hyprlock;
  };
}

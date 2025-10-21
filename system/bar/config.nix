{ lib, niri, pkgs }:

let
  spawn = pkg:
    "${lib.getExe niri} msg action spawn -- ${lib.getExe pkgs.${pkg}}";
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
    on-click = spawn "walker";
  };

  network = {
    format = "󰤭  Disconnected";
    format-ethernet = "󰈀  {ifname}";
    format-wifi = "{icon}  {essid}";
    format-icons = [ "󰤟" "󰤢" "󰤥" "󰤨" ];
    tooltip-format = "{ipaddr}";
    on-click = spawn "iwgtk";
    on-click-right = spawn "trayscale";
  };

  bluetooth = {
    format = "󰂲  Disconnected";
    format-connected = "󰂱  {device_alias}";
    on-click = spawn "overskride";
  };

  wireplumber = {
    format-muted = "󰝟  {volume}%";
    format = "{icon}  {volume}%";
    format-icons = [ "󰕿" "󰖀" "󰕾" ];
    on-click = spawn "pwvucontrol";
    on-click-right = spawn "helvum";
  };

  battery = {
    format = "{icon}  {capacity}%";
    format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
    states.critical = 5;
    on-click = spawn "hyprlock";
  };
}

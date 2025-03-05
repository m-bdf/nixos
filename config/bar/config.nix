{ config, lib, pkgs, ... }:

let
  spawn = pkg: "${lib.getExe pkgs.niri} msg action spawn -- ${lib.getExe pkg}";
  launch = pkg:
    "${lib.getExe config.programs.uwsm.package} app -- ${lib.getExe pkg}";
in

{
  modules-left = [ "niri/workspaces" ];
  modules-center = [ "clock" ];
  modules-right = [ "network" "bluetooth" "wireplumber" "battery" ];

  clock = {
    interval = 1;
    format = "{:%c}";
    tooltip = false;
    on-click = spawn pkgs.walker;
  };

  network = {
    format = "󰤭  Disconnected";
    format-ethernet = "󰈀  {ifname}";
    format-wifi = "{icon}  {essid}";
    format-icons = [ "󰤟" "󰤢" "󰤥" "󰤨" ];
    tooltip-format = "{ipaddr}";
    on-click = launch pkgs.iwgtk;
  };

  bluetooth = {
    format = "󰂲  Disconnected";
    format-connected = "󰂱  {device_alias}";
    on-click = launch pkgs.overskride;
  };

  wireplumber = {
    format-muted = "󰝟  {volume}%";
    format = "{icon}  {volume}%";
    format-icons = [ "󰕿" "󰖀" "󰕾" ];
    on-click = launch pkgs.pwvucontrol;
  };

  battery = {
    format = "{icon}  {capacity}%";
    format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
    states.critical = 5;
  };
}

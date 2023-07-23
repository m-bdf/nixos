{ lib, pkgs, ... }:

{
  modules-left = [ "river/tags" ];
  modules-center = [ "clock" ];
  modules-right = [ "network" "bluetooth" "wireplumber" "battery" ];

  clock = {
    interval = 1;
    format = "{:%c}";
  };

  network = {
    format = "󰤭 Disconnected";
    format-ethernet = "󰈀 {ifname}";
    format-wifi = "{icon} {essid}";
    format-icons = [ "󰤟" "󰤢" "󰤥" "󰤨" ];
    tooltip-format = "{ipaddr}";
    on-click = lib.getExe pkgs.iwgtk;
  };

  bluetooth = {
    format = "󰂲 Disconnected";
    format-connected = "󰂱 {device_alias}";
    on-click = lib.getExe pkgs.overskride;
  };

  wireplumber = {
    format-muted = "󰝟 {volume}%";
    format = "{icon} {volume}%";
    format-icons = [ "󰕿" "󰖀" "󰕾" ];
    on-click = lib.getExe pkgs.pwvucontrol;
  };

  battery = {
    format = "{icon} {capacity}%";
    format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
    states.critical = 5;
  };
}

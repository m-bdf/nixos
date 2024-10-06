{ pkgs, ... }:

{
  services = {
    logind = {
      lidSwitch = "ignore";
      powerKey = "hybrid-sleep";
    };
    upower.enable = true;
  };

  programs = {
    gtklock = {
      enable = true;
      modules = with pkgs; [
        gtklock-powerbar-module
        gtklock-playerctl-module
      ];
    };

    river.bindings = [{
      key = "XF86AudioMedia";
      cmd = "gtklock";
    }];
  };
}

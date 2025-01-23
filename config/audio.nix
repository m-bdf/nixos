{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [ sonic-pi ];
    sessionVariables.SONIC_PI_HOME = "/usr/share/SonicPi";
  };

  hardware.bluetooth.enable = true;
  services.playerctld.enable = true;

  programs.niri.bindings = {
    XF86AudioMute = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
    XF86AudioLowerVolume = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-";
    XF86AudioRaiseVolume = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+";
    XF86AudioMicMute = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
    XF86AudioPrev = "playerctl previous";
    XF86AudioPlay = "playerctl play-pause";
    XF86AudioNext = "playerctl next";
  };

  xdg.dirs = {
    data.SonicPi.persist = true;
    state = {
      wireplumber.create = true;
      bluetooth.persist = true;
    };
  };
}

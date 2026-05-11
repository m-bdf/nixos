{
  security.rtkit.enable = true;
  hardware.bluetooth.enable = true;
  home.services.playerctld.enable = true;

  programs.niri.keybinds = {
    XF86AudioMute = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
    XF86AudioLowerVolume = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-";
    XF86AudioRaiseVolume = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%+";
    XF86AudioMicMute = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
    XF86AudioPrev = "playerctl previous";
    XF86AudioPlay = "playerctl play-pause";
    XF86AudioNext = "playerctl next";
  };

  home.xdg = {
    stateFile = {
      wireplumber.persist = true;
      bluetooth.persist = true;
    };
  };
}

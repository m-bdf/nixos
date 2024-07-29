{
  programs.river.bindings = [
    {
      key = "XF86AudioMute";
      cmd = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
    }
    {
      key = "XF86AudioLowerVolume";
      cmd = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-";
      rep = true;
    }
    {
      key = "XF86AudioRaiseVolume";
      cmd = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+";
      rep = true;
    }
    {
      key = "XF86AudioMicMute";
      cmd = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
    }
    {
      key = "XF86AudioPrev";
      cmd = "playerctl previous";
    }
    {
      key = "XF86AudioPlay";
      cmd = "playerctl play-pause";
    }
    {
      key = "XF86AudioNext";
      cmd = "playerctl next";
    }
  ];
}

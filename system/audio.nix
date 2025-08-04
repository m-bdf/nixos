{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [ sonic-pi ];
    variables.SONIC_PI_HOME = "$XDG_DATA_HOME/SonicPi";
  };

  security.rtkit.enable = true;
  hardware.bluetooth.enable = true;
  services.playerctld.enable = true;

  programs.niri.keybinds = {
    XF86AudioMute = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
    XF86AudioLowerVolume = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-";
    XF86AudioRaiseVolume = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%+";
    XF86AudioMicMute = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
    XF86AudioPrev = "playerctl previous";
    XF86AudioPlay = "playerctl play-pause";
    XF86AudioNext = "playerctl next";
  };

  xdg.dirs = {
    data.SonicPi.persist = true;
    state = {
      wireplumber.persist = true;
      bluetooth.persist = true;
    };
    cache.obexd.create = true;
  };
}

{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [ sonic-pi ];
    variables.SONIC_PI_HOME = "$XDG_DATA_HOME/SonicPi";
  };

  security.rtkit.enable = true;
  hardware.bluetooth.enable = true;
  services.playerctld.enable = true;

  services.pipewire.extraConfig.pipewire = {
    default-output."context.modules" = [{
      name = "libpipewire-module-loopback";
      args = {
        "node.description" = "Default Output";
        "audio.position" = [ "FL" "FR" ];
        "capture.props" = {
          "node.name" = "alsa_output.loopback";
          "media.name" = "Default Output";
          "media.class" = "Audio/Sink";
        };
        "playback.props" = {
          "node.name" = "alsa_input.loopback";
          "media.name" = "Default Output";
          "node.passive" = true;
        };
      };
    }];
  };

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
    dataFile.SonicPi.persist = true;
    stateFile = {
      wireplumber.persist = true;
      bluetooth.persist = true;
    };
  };
}

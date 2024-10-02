{ pkgs, ... }@ inputs:

{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar.override {
      cavaSupport = false;
      evdevSupport = false;
      experimentalPatches = false;
      hyprlandSupport = false;
      inputSupport = false;
      jackSupport = false;
      mpdSupport = false;
      mprisSupport = false;
      niriSupport = false;
      pulseSupport = false;
      sndioSupport = false;
      swaySupport = false;
      traySupport = false;
      udevSupport = false;
      upowerSupport = false;
    };
  };

  environment.etc = {
    "xdg/waybar/config".text = builtins.toJSON (import ./config.nix inputs);

    "xdg/waybar/style.css".text = ''
      label { font-family: monospace }

      window { border-radius: 0 }
      button { padding: 0 }
      label { padding: 5px 10px }

      #tags > .focused { background: @selected_bg_color }
      #tags > :not(.occupied) { color: @insensitive_fg_color }

      @keyframes blink { from { background: @error_color } }
      .critical:not(.charging) { animation: blink .5s infinite }
    '';
  };
}

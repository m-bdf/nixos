{ pkgs, ... }@ args:

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
      pipewireSupport = false;
      pulseSupport = false;
      sndioSupport = false;
      swaySupport = false;
      traySupport = false;
      udevSupport = false;
      upowerSupport = false;
    };
  };

  environment.etc = {
    "xdg/waybar/config".text = builtins.toJSON (import ./config.nix args);

    "xdg/waybar/style.css".text = ''
      button { padding: 0 }
      label { padding: 5px 10px }

      #workspaces > .active {
        color: @theme_selected_fg_color;
        background: @theme_selected_bg_color;
      }

      @keyframes blink { from { background: @error_color } }
      .critical:not(.charging) { animation: blink .5s infinite }
    '';
  };
}

{ inputs, pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [ dracula-theme adwaita-icon-theme ];
    sessionVariables.GTK_THEME = "Dracula";

    etc = {
      "xdg/niri/config.kdl".text = ''
        prefer-no-csd
        hotkey-overlay { skip-at-startup; }
      '';

      "xdg/fuzzel/fuzzel.ini".text = ''
        include = ${inputs.dracula-fuzzel}/fuzzel.ini
        font = sans
        dpi-aware = no
      '';

      "xdg/ghostty/config".text = ''
        theme = Dracula
        window-decoration = false
        resize-overlay = never
        # adw-toast = false
        font-family = mono
        font-size = 11
      '';

      "xdg/helix/config.toml".text = ''
        theme = "github_dark"
      '';
    };
  };

  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      nerd-fonts.fira-code
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];

    fontconfig.defaultFonts =
    let
      fonts = [ "FiraCode Nerd Font" "Noto Color Emoji" ];
    in
    {
      sansSerif = [ "Noto Sans" ] ++ fonts;
      serif = [ "Noto Serif" ] ++ fonts;
      monospace = fonts;
      emoji = fonts;
    };
  };

  xdg.dirs.cache = {
    mesa_shader_cache.create = true;
    fontconfig.create = true;
  };
}

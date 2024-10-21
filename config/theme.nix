{ pkgs, dracula-fuzzel, dracula-kitty, ... }:

{
  environment = {
    systemPackages = with pkgs; [ dracula-theme adwaita-icon-theme ];
    sessionVariables.GTK_THEME = "Dracula";

    etc = {
      "xdg/fuzzel/fuzzel.ini".text = ''
        include = ${dracula-fuzzel}/fuzzel.ini
        font = sans
        dpi-aware = no
      '';

      "xdg/kitty/kitty.conf".text = ''
        include ${dracula-kitty}/dracula.conf
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

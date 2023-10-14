{ pkgs, dracula-fuzzel, dracula-kitty, ... }:

{
  environment = {
    systemPackages = with pkgs; [ dracula-theme gnome.adwaita-icon-theme ];
    sessionVariables.GTK_THEME = "Dracula";

    etc = {
      fuzzel.source = dracula-fuzzel;
      "helix/config.toml".text = "theme = \"github_dark\"";
      "kitty/kitty.conf".text = "include ${dracula-kitty}/dracula.conf";
    };
  };

  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs;
    let
      fira-code = nerdfonts.override { fonts = [ "FiraCode" ]; };
    in
      [ fira-code noto-fonts noto-fonts-cjk-sans noto-fonts-color-emoji ];

    fontconfig.defaultFonts = {
      sansSerif = [ "Noto Sans" "FiraCode Nerd Font" "Noto Color Emoji" ];
      serif = [ "Noto Serif" "FiraCode Nerd Font" "Noto Color Emoji" ];
      monospace = [ "FiraCode Nerd Font" "Noto Color Emoji" ];
      emoji = [ "FiraCode Nerd Font" "Noto Color Emoji" ];
    };
  };

  xdg.dirs.cache = {
    mesa_shader_cache.create = true;
    fontconfig.create = true;
  };
}

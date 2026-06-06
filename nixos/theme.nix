{ pkgs, ... }:

{
  home = {
    gtk = {
      enable = true;
      gtk2.enable = false;

      theme = {
        name = "Colloid-Dark-Compact-Dracula";
        package = pkgs.colloid-gtk-theme.override {
          colorVariants = [ "dark" ];
          sizeVariants = [ "compact" ];
          tweaks = [ "dracula" ];
        };
      };

      iconTheme = {
        name = "Colloid-Dracula-Dark";
        package = pkgs.colloid-icon-theme.override {
          schemeVariants = [ "dracula" ];
        };
      };

      cursorTheme = {
        name = "phinger-cursors-dark";
        package = pkgs.phinger-cursors;
      };
    };

    dconf.settings = {
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
      "org/gnome/desktop/wm/preferences".button-layout = "";
    };

    xdg.configFile."niri/config.kdl".text = ''
      cursor { xcursor-theme "phinger-cursors-dark"; }
      prefer-no-csd
    '';

    programs.ghostty.settings.theme = "Dracula";
  };
}

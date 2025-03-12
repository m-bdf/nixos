{ pkgs, ... }:

{
  environment = {
    etc = {
      "xdg/helix/config.toml".text = ''
        theme = "github_dark"
      '';

      "xdg/niri/config.kdl".text = ''
        cursor { xcursor-theme "phinger-cursors-dark"; }
        prefer-no-csd
      '';

      "xdg/ghostty/config".text = ''
        theme = Dracula
      '';
    };

    systemPackages = with pkgs; [
      (colloid-gtk-theme.override {
        colorVariants = [ "dark" ];
        sizeVariants = [ "compact" ];
        tweaks = [ "dracula" ];
      })

      (colloid-icon-theme.override {
        schemeVariants = [ "dracula" ];
      })

      phinger-cursors
    ];

    variables.GTK_THEME = "Colloid-Dark-Compact-Dracula";
  };

  programs.dconf.profiles.user.databases = [{
    settings = {
      "org/gnome/desktop/interface" = {
        gtk-theme = "Colloid-Dark-Compact-Dracula";
        icon-theme = "Colloid-Dracula-Dark";
        cursor-theme = "phinger-cursors-dark";
        color-scheme = "prefer-dark";
      };
      "org/gnome/desktop/wm/preferences".button-layout = "";
    };
    lockAll = true;
  }];
}

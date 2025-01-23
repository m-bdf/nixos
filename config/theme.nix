{ inputs, pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [ dracula-theme dracula-icon-theme ];
    variables.GTK_THEME = "Dracula";

    etc = {
      "xdg/niri/config.kdl".text = ''
        cursor { xcursor-theme "Dracula-cursors"; }
        prefer-no-csd
        hotkey-overlay { skip-at-startup; }
      '';

      "xdg/fuzzel/fuzzel.ini".text = ''
        include = ${inputs.dracula-fuzzel}/fuzzel.ini
        icon-theme = Dracula
      '';

      "xdg/ghostty/config".text = ''
        theme = Dracula
        window-decoration = false
        resize-overlay = never
        # adw-toast = false
      '';

      "xdg/helix/config.toml".text = ''
        theme = "github_dark"
      '';
    };
  };

  programs.dconf.profiles.user.databases = [{
    settings."org/gnome/desktop/interface" = {
      gtk-theme = "Dracula";
      icon-theme = "Dracula";
      cursor-theme = "Dracula-cursors";
      color-scheme = "prefer-dark";
    };
  }];
}

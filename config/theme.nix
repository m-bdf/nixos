{ pkgs, ... }:

{
  environment = {
    etc = {
      "xdg/helix/config.toml".text = ''
        theme = "catppuccin_mocha"
      '';

      "xdg/niri/config.kdl".text = ''
        cursor { xcursor-theme "catppuccin-mocha-dark-cursors"; }
      '';

      "xdg/ghostty/config".text = ''
        theme = catppuccin-mocha
      '';
    };

    systemPackages = with pkgs; [
      (colloid-gtk-theme.override {
        colorVariants = [ "dark" ];
        sizeVariants = [ "compact" ];
        tweaks = [ "catppuccin" "normal" ];
      })

      (colloid-icon-theme.override {
        schemeVariants = [ "catppuccin" ];
      })

      catppuccin-cursors.mochaDark
    ];

    sessionVariables.GTK_THEME = "Colloid-Dark-Compact-Catppuccin";
  };

  programs.dconf.profiles.user.databases = [{
    settings."org/gnome/desktop/interface" = {
      gtk-theme = "Colloid-Dark-Compact-Catppuccin";
      icon-theme = "Colloid-Catppuccin-Dark";
      cursor-theme = "catppuccin-mocha-dark-cursors";
      color-scheme = "prefer-dark";
    };
  }];

  xdg.dirs.cache = {
    mesa_shader_cache.create = true;
    mesa_shader_cache_db.create = true;
    radv_builtin_shaders.create = true;
  };
}

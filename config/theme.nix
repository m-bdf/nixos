{ inputs, pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [ dracula-theme adwaita-icon-theme ];
    sessionVariables.GTK_THEME = "Dracula";

    etc = {
      "xdg/fuzzel/fuzzel.ini".text = ''
        include = ${inputs.dracula-fuzzel}/fuzzel.ini
      '';

      "xdg/kitty/kitty.conf".text = ''
        include ${inputs.dracula-kitty}/dracula.conf
      '';

      "xdg/helix/config.toml".text = ''
        theme = "github_dark"
      '';
    };
  };

  xdg.dirs.cache = {
    mesa_shader_cache.create = true;
    mesa_shader_cache_db.create = true;
    radv_builtin_shaders.create = true;
  };
}

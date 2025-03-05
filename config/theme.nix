{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [ dracula-theme adwaita-icon-theme ];
    sessionVariables.GTK_THEME = "Dracula";

    etc = {
      "xdg/ghostty/config".text = ''
        theme = Dracula
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

{ pkgs, ... }:

let
  pkg = pkgs.catppuccin-gtk.override {
    accents = [ "lavender" ];
    #size = "compact";
    #tweaks = [ "rimless" "black" ];
    variant = "mocha";
  };

  theme = with builtins;
    head (attrNames (readDir "${pkg}/share/themes"));

  fira = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
in

{
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  environment = {
    variables.GTK_THEME = theme;
    systemPackages = [ pkg ];
  };

/*
  environment.etc."dconf/user".source =
  let
    conf = pkgs.writeTextDir "conf" ''
      [org/gnome/desktop/interface]
      color-scheme='prefer-dark'
      #gtk-color-scheme='prefer-dark'
    '';
  in
    pkgs.runCommand "db" {}
      "${lib.getExe pkgs.dconf} compile $out ${conf}";
*/

  fonts = {
    fonts = [ fira ];

    fontconfig.defaultFonts = {
      monospace = [ "FiraCode Nerd Font" ];
      sansSerif = [ "FiraCode Nerd Font" ];
    };
  };

  xdg.dirs.cache = {
    mesa_shader_cache.create = true;
    fontconfig.create = true;
  };
}

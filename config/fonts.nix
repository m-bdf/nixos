{ pkgs, ... }:

{
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

  environment.etc."xdg/fuzzel/fuzzel.ini".text = ''
    font = sans
    use-bold = true
    dpi-aware = no
  '';

  xdg.dirs.cache.fontconfig.create = true;
}

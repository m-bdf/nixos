{ config, pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      nerd-fonts.fira-code
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];

    fontconfig = {
      includeUserConf = false;
      allowBitmaps = false;
      defaultFonts =
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
  };

  boot.plymouth.font = pkgs.runCommandLocal "plymouth-font" {
    FONTCONFIG_FILE = pkgs.makeFontsConf {
      fontDirectories = [];
      impureFontDirectories = [];
      includes = config.environment.etc.fonts.source + "conf.d";
    };
  } ''
    ln -s $(${pkgs.fontconfig}/bin/fc-match monospace -f %{file}) $out
  '';

  home.programs.ghostty.settings.font-family = [ "monospace" "emoji" ];
}

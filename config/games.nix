{ pkgs, ... }:

{
  environment.systemPackages =
  let
    lutris-with-wayland = pkgs.lutris.override {
      extraPkgs = pkgs: [ pkgs.wineWowPackages.waylandFull ];
    };

    lutris = pkgs.buildFHSEnv
      (lutris-with-wayland.args // {
        extraBwrapArgs = [
          "--bind /usr/share /usr/share"
          "--bind /var /var"
        ];
      });
  in
    [ lutris pkgs.prismlauncher ];

  xdg.dirs = {
    data = {
      icons.create = true;
      lutris.persist = true;
      PrismLauncher.persist = true;
    };
    config.lutris.persist = true;
    cache = {
      winetricks.create = true;
      lutris.create = true;
    };
    home.Games.persist = true;
  };
}

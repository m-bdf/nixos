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
          "--bind /etc/xdg /etc/xdg"
          "--bind /var /var"
        ] ++ map (exe:
          "--bind ${exe} /var/cache/winetricks/corefonts/${exe.name}"
        ) pkgs.corefonts.exes;
      });
  in
    [ lutris pkgs.prismlauncher ];

  xdg.dirs = {
    data = {
      lutris.persist = true;
      icons.create = true;
      PrismLauncher.persist = true;
    };
    config.lutris.persist = true;
    cache = {
      lutris.create = true;
      winetricks.create = true;
    };
    home.Games.persist = true;
  };
}

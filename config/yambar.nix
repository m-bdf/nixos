{ lib, pkgs, ... }:

let
  yambarNoX = pkgs.yambar.override { x11Support = true; }; #FIXME

  mkMap = with lib;
    foldr (cond: res: {
      map.conditions =
        assert length (attrNames cond) == 1;
        cond // optionalAttrs (res != null) {
          "~(${head (attrNames cond)})" = res;
        };
    });

  config.bar = {
    height = 26;
    location = "top";
    background = "000000ff";
    margin = 5;

    left = [{
      river.content =
      let
        mkTag = foreground: {
          string = {
            text = "{id}";
            margin = 5;
            inherit foreground;
          };
        };
      in
        mkMap null [
          { focused = mkTag "ffffffff"; }
          { occupied = mkTag "aaaaaaaa"; }
          { "id < 10" = mkTag "00000000"; }
        ];
    }];

    center = [{
      clock.content.string.text = "{time}";
    }];
  };
in

{
  environment = {
    systemPackages = [ yambarNoX ];

    etc."yambar/config.yml".source = pkgs.writeTextFile {
      name = "yambar/config.yml";
      text = builtins.toJSON config;
      checkPhase =
        "${yambarNoX}/bin/yambar --config=$target --validate";
    };
  };

  systemd.user.services.yambar = {
    description = "Yambar status panel";
    documentation = [ "man:yambar(1)" ];
    serviceConfig.ExecStart = "${yambarNoX}/bin/yambar";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
  };
}

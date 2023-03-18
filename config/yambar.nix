{ lib, pkgs, ... }:

let
  yambarNoX = pkgs.yambar.override { x11Support = true; }; #FIXME

  mkOrderedMapParticle = with lib;
    foldl' (res: { condition, particle }: {
      map.conditions = {
        "${condition}" = particle;
      } // optionalAttrs (res != null) {
        "~(${condition})" = res;
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
        mkOrderedMapParticle null [
          { condition = "focused"; particle = mkTag "ffffffff"; }
          { condition = "occupied"; particle = mkTag "aaaaaaaa"; }
          { condition = "id < 10"; particle = mkTag "00000000"; }
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

{ pkgs, ... }:

let
  config.bar = {
    height = 26;
    location = "top";
    background = "000000ff";

    center = [{
      clock.content = [{
        string.text = "{time}";
      }];
    }];
  };
in

{
  environment = {
    systemPackages = [ pkgs.yambar ];
    etc."yambar/config.yml".text = builtins.toJSON config;
  };

  systemd.user.services.yambar = {
    description = "Yambar status panel";
    documentation = [ "man:yambar(1)" ];
    serviceConfig.ExecStart = "${pkgs.yambar}/bin/yambar";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
  };
}

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

  systemd.user.services."yambar@" = {
    description = "Yambar instance for WAYLAND_DISPLAY=%i";
    documentation = [ "man:yambar(1)" ];

    script = "${pkgs.yambar}/bin/yambar";
    environment.WAYLAND_DISPLAY = "%i";

    wantedBy = [ "wayland-instance@.target" ];
    partOf = [ "wayland-instance@.target" ];
    after = [ "wayland-instance@.target" ];
  };
}

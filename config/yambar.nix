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
}

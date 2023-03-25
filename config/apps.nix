{ lib, pkgs, ... }:

{
  options.environment = with lib.types; {
    defaultTerminal = lib.mkOption {
      default = "";
      type = str;
    };
    defaultBrowser = lib.mkOption {
      default = "";
      type = str;
    };
  };

  config.environment = {
    defaultPackages = [];
    systemPackages = with pkgs; [ git kakoune htop ];

    sessionVariables.NIXOS_OZONE_WL = toString true;
  };
}

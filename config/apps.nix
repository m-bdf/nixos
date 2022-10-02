{ lib, pkgs, ... }:

let
  update = pkgs.writeShellScriptBin "update" ''
    sudo nixos-rebuild $1 --flake github:m-bdf/nixos/$2 --no-write-lock-file
  '';
in

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
    systemPackages = [ update ];

    sessionVariables.NIXOS_OZONE_WL = toString true;
  };
}

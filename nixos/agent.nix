{ lib, pkgs, ... }:

{
  home.programs = {
    zed-editor = {
      enableMcpIntegration = true;
      extensions = [ "mcp-server-sequential-thinking" ];
    };

    mcp = {
      enable = true;
      servers.NixOS.command = lib.getExe pkgs.mcp-nixos;
    };
  };
}

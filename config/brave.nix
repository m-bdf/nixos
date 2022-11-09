{ pkgs, ... }:

{
  environment = {
    systemPackages = [ pkgs.brave ];
    defaultBrowser = "${pkgs.brave}/bin/brave";
  };

  xdg.basedirs.config."BraveSoftware/Brave-Browser".persist = true;
}

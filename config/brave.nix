{ pkgs, ... }:

{
  environment = {
    systemPackages = [ pkgs.brave ];
    defaultBrowser = "brave";
  };

  xdg.basedirs.config."BraveSoftware/Brave-Browser".persist = true;
}

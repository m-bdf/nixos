{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.brave ];
  xdg.basedirs.config."BraveSoftware/Brave-Browser".persist = true;
}

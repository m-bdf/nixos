{ lib, pkgs, ... }:

let
  patchLayout = pkgs.writers.writePerlBin "patch-layout.pl" {} ''
    BEGIN { $/ = ";\n" }

    /(.+) = {(.+)\n.+EndRow},\n+(.+)};/s or next;
    my ($decl, $body, $tail) = ($1, $2, $3);

    if ($body =~ /Layout/) {
      $_ = "$decl = {$tail};\n";
    }
    elsif ($tail =~ /NextLayer/) {
      $body =~ s/.+BACKSPACE.+\n*//;

      my ($shift) = $tail =~ /(.+Mod, Shift.+)/;
      $body =~ s/.+EndRow},\n/$&\n$shift/s if $shift;

      $tail =~ s/(.+?\n).*\n(.+)/$1$2/s;
      $_ = "$decl = {$body$tail};\n";
    }
  '';

  wvkbd = pkgs.wvkbd.overrideAttrs {
    patchPhase = ''
      ${patchLayout.interpreter} -pi \
        ${lib.getExe patchLayout} layout.mobintl.h
      sed -i '/Landscape/c Index,' config.mobintl.h
    '';
  };
in

{
  i18n.defaultLocale = "en_IE.UTF-8";
  services = {
    speechd.enable = false;
    xserver.xkb.layout = "eu";
  };

  home.wayland = {
    startup = "${lib.getExe wvkbd} -L 250 --fn 'sans 20' --hidden";
    keybinds."Win+Space" = "pkill wvkbd -RTMIN";
  };
}

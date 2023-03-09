{ pkgs, ... }:

{
  programs.xonsh = {
    enable = true;
    config = ''
      exec($(${pkgs.carapace}/bin/carapace _carapace))
      execx($(${pkgs.starship}/bin/starship init xonsh))
      #xontrib load --full ${pkgs.coconut}/...
    '';
  };

  #users.users.user.shell = pkgs.xonsh;
}

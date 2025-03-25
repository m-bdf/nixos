{ inputs, lib, ... }:

{
  imports = [ inputs.nixos-facter-modules.nixosModules.facter ];

  facter.reportPath =
  let
    pkgs = import inputs.nixpkgs {};
  in
    pkgs.runCommandLocal "report-${toString builtins.currentTime}.json" {
      __noChroot = true; # TODO: __impure and remove currentTime
      nativeBuildInputs = [ pkgs.systemdMinimal ];
    } "${lib.getExe pkgs.nixos-facter} > $out";
}

{ lib, pkgs, modules }:

with lib;

let
  mkTest = name: script:
  let
    test = nixos.runTest {
      inherit name;
      hostPkgs = pkgs;

      nodes.machine = {
        imports = modules;
        virtualisation.writableStore = false;
      };

      testScript = ''
        machine.wait_for_unit("default.target")
        ${readFile script}
      '';
    };
  in
    nameValuePair test.name test;
in

mapAttrs' mkTest (listDir ./tests)

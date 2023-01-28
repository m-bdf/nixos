{ lib, pkgs, modules }:

with lib;

let
  mkTest = script:
  let
    test = nixos.runTest {
      name = head (splitString "." script);
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

listToAttrs (map mkTest (listDir ./tests))

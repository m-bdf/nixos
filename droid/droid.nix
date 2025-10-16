{ inputs, options, config, lib, pkgs, ... }:

let
  nixpkgs = pkgs.runCommand "pkgs.nix" {
    nativeBuildInputs = [ config.home.programs.nix-index.package ];
  } ''
    echo with builtins\; { $(while read pkg _ _ path; do
      echo \"''${pkg//./\".\"}\" = storePath \"$path\"\;
    done < <(nix-locate --at-root --whole-name ''')) } > $out
  '';
in

{
  imports = [
    (lib.mkAliasOptionModule [ "home" ] [ "home-manager" "config" ])
  ];

  options.environment.path = config.home.lib.mkPathOption;

  config = {
    user = {
      userName = "mae";
      shell = pkgs.fish;
    };

    system.stateVersion = lib.last
      options.system.stateVersion.type.functor.payload.values;

    home-manager = {
      useGlobalPkgs = true;
      extraSpecialArgs.inputs = inputs // { inherit nixpkgs; };
    };

    home = {
      nix.settings = {
        use-xdg-base-directories = lib.mkForce false;
        auto-optimise-store = lib.mkForce false;
      };
      programs.nh.enable = lib.mkForce false;
    };

    environment.sessionVariables =
    let
      dnshack = pkgs.callPackage inputs.dnshack {};
    in {
      DNSHACK_RESOLVER_CMD = "${dnshack}/bin/dnshackresolver";
      LD_PRELOAD = "${dnshack}/lib/libdnshackbridge.so";
    };
  };
}

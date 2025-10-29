{ inputs, options, config, lib, pkgs, ... }:

let
  nixpkgs = pkgs.runCommand "source" {
    nativeBuildInputs = [ config.home.programs.nix-index.package ];
  } ''
    cd ${inputs.nixpkgs}
    mkdir -p $out/pkgs/stdenv

    cp --recursive --parents default.nix lib \
      pkgs/top-level pkgs/stdenv/{adapters,booter}.nix \
      pkgs/build-support/trivial-builders/default.nix $out

    { echo with builtins\; {; while read pkg _ _ path
        do echo \"''${pkg//./\".\"}\" = storePath \"$path\"\;
      done < <(nix-locate --at-root --whole-name '''); echo }
    } > $out/pkgs/store-paths.nix

    echo 'args: [ (_: rec {
      inherit (args) config;
      stdenv = (import ../store-paths.nix).stdenvNoCC;
      overlays = [ (_: _: import ../store-paths.nix) ];
    }) ]' > $out/pkgs/stdenv/default.nix
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
      extraSpecialArgs.inputs = inputs;
    };

    home = {
      nix = {
        settings = {
          use-xdg-base-directories = lib.mkForce false;
          # auto-optimise-store = lib.mkForce false;
        };
        registry.nixpkgs.flake = lib.mkForce nixpkgs;
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

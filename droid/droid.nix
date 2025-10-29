{ inputs, options, config, lib, pkgs, ... }:

let
  storePaths = pkgs.runCommand "store-paths.nix" {
    nativeBuildInputs = [ config.home.programs.nix-index.package ];
  } ''
    { echo {
      nix-locate --at-root --whole-name ''' |
      while read pkg _ _ path; do
        echo \"''${pkg//./\".\"}\" = \"$path\"\;
      done
      echo }
    } > $out
  '';

  default = pkgs.writeText "default.nix" ''
    { config ? {}, overlays ? [], ... }@ args:

    import ./pkgs/top-level/impure.nix (args // {
      config = ${
        with lib; generators.toPretty { indent = "  "; }
          (filterAttrs (_: v: !isFunction v) pkgs.config)
      } // config;

      overlays = overlays ++ [
        (_: prev: prev.lib.mapAttrsRecursiveCond (v: !v ? out)
          (_: d: prev.lib.toDerivation d.out // d) (import ${storePaths})
        )
      ];

      stdenvStages = args: [
        (_: { __raw = true; cc = null; })
      ] ++ builtins.tail (import ./pkgs/stdenv/native args);
    })
  '';

  nixpkgs = pkgs.runCommand "source" {} ''
    mkdir -p $out/pkgs
    cp ${default} $out/default.nix
    cd ${inputs.nixpkgs}
    cp --recursive --parents lib \
      pkgs/{top-level,stdenv,build-support} $out
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

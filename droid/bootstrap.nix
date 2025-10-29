{ inputs, config, lib, pkgs, ... }:

with lib;

let
  arch = removeSuffix "-linux" pkgs.stdenv.system;

  initialLoginInner = pkgs.writeText "login-inner" ''
    set -o allexport -o errexit
    ${toShellVars config.environment.sessionVariables}
    unset HOME LD_PRELOAD

    NIX_CONFIG='${
      concatMapAttrsStringSep "\n"
        (opt: val: "${opt} = ${toString val}")
        (import (inputs.self + /flake.nix)).nixConfig
    }'

    PATH+=:${pkgs.nix}/bin
    nix build --no-link ${config.build.activationPackage}
    exec ${config.build.activationPackage}/activate
  '';

  overrideBootstrap = prev: rec {
    nixDirectory = prev.nixDirectory.overrideAttrs {
      src =
        let release = inputs.nix.packages."${arch}-linux".binaryTarball;
        in release + /nix-${getVersion release}-${arch}-linux.tar.xz;
    };

    initialPackageInfo =
      import "${nixDirectory}/nix-support/package-info.nix";

    config = recursiveUpdate prev.config {
      environment.files.loginInner = initialLoginInner;
    };
  };

  exportBootstrap = droidPkgs:
    pkgs.runCommand "bootstrapZip-${arch}" {
      bootstrap = droidPkgs."bootstrap-${arch}".override overrideBootstrap;
    } ''
      mkdir $out && ln -s ${initialLoginInner} $out/activate-${arch}.sh
      cd $bootstrap && ${getExe pkgs.zip} -r9q $out/bootstrap-${arch} .
    '';
in

{
  options.build.bootstrapZip = mkOption {
    default = makeOverridable exportBootstrap {};
  };

  config.environment.packages = [
    (pkgs.writeScriptBin "nod-update" ''
      curl -s "https://m-bdf.github.io/nixos/activate-${arch}.sh" | sh
    '')
  ];
}

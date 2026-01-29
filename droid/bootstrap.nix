{ inputs, config, lib, pkgs, droidPkgs, extendModules, ... }:

with lib;

let
  arch = removeSuffix "-linux" pkgs.stdenv.system;

  initialLoginInner = pkgs.writeText "login-inner" ''
    NIX_CONFIG='${
      concatMapAttrsStringSep "\n"
        (opt: val: "${opt} = ${toString val}")
        (import (inputs.self + /flake.nix)).nixConfig
    }'

    PATH+=:${pkgs.nix}/bin
    nix build --refresh --no-link ${config.build.activationPackage}
    exec ${config.build.activationPackage}/activate
  '';

  overrideBootstrap = prev: rec {
    nixDirectory = prev.nixDirectory.overrideAttrs {
      src =
        let release = inputs.nix.packages."${arch}-linux".binaryTarball;
        in release + /nix-${getVersion release}-${arch}-linux.tar.xz;
    };

    initialPackageInfo =
      import (nixDirectory + /nix-support/package-info.nix);

    config = recursiveUpdate (extendModules {
      modules = [{
        home-manager.useUserPackages = false;
      }];
    }).config {
      environment.files.loginInner = initialLoginInner;
    };
  };
in

{
  options.build.bootstrapZip = mkOption {
    default = pkgs.runCommand "bootstrap-zip" {
      bootstrap = droidPkgs."bootstrap-${arch}".override overrideBootstrap;
    } ''
      mkdir $out && ln -s ${initialLoginInner} $out/activate-${arch}.sh
      cd $bootstrap && ${getExe pkgs.zip} -r9q $out/bootstrap-${arch} .
    '';
  };

  config.environment.packages = [
    (pkgs.writeScriptBin "nod-update" ''
      ${getExe pkgs.xh} https://m-bdf.github.io/nixos/activate-${arch}.sh | sh
    '')
  ];
}

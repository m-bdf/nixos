{ lib, pkgs, ... }:

let
  rustixUseLibcOverlay = _: prev: {
    rustPlatform = prev.rustPlatform.overrideScope (_: prev: {
      buildRustPackage = args:
        (prev.buildRustPackage args).overrideAttrs (final: _: {
          passthru.dev = prev.buildRustPackage args;

          NIX_RUSTFLAGS = with lib;
            optionalDrvAttr (
              elem "command-line-utilities" (
                importTOML (final.src + /Cargo.toml)
              ).package.categories or []
            &&
              any (d: d.name == "rustix") (
                importTOML (final.src + /Cargo.lock)
              ).package
            ) "--cfg=rustix_use_libc";
        });
    });
  };
in

{
  options = {
    _module.args = lib.mkOption {
      apply = args: args // {
        pkgs = args.pkgs.extend rustixUseLibcOverlay;
      };
    };

    home.path = lib.mkOption {
      apply = drv: drv.override {
        includeClosures = true;
        ignoreCollisions = true;
      };
    };
  };

  config = {
    home.packages = with pkgs; [ curl ];

    programs = {
      fd.enable = true;
      ripgrep.enable = true;

      man.generateCaches = false;
    };
  };
}

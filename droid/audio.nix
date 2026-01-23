{ inputs, config, pkgs, ... }:

let
  pkgsCross = import inputs.nixpkgs
    (with config.environment.files.prootStatic.stdenv; {
      inherit (buildPlatform) system;
      crossSystem = hostPlatform // {
        androidSdkVersion = hostPlatform.sdkVer;
      };
      inherit (pkgs) config overlays;
    });

  cc = pkgsCross.buildPackages.androidndkPkgs.clang.override (prev: rec {
    bintools = prev.bintools.override { inherit libc; };

    libc = prev.libc.overrideAttrs (prev: {
      buildCommand = prev.buildCommand + ''
        ln -s ${pkgs.glibc}/lib/lib{pthread,rt}.so $out/lib
      '';
    });
  });

  jack = pkgs.jack2.override {
    stdenv = pkgs.clangStdenv.override { inherit cc; };
    dbus = null;
  };

  jackWithOpenSLES = jack.overrideAttrs (prev: {
    patches = prev.patches ++ [
      (inputs.termux-packages + /packages/jack2/0001-fix-android-build.patch)
      (inputs.termux-packages + /packages/jack2/0003-opensles-driver.patch)
      (inputs.termux-packages + /packages/jack2/0004-remove-su-features.patch)
    ];

    postPatch = ''
      sed -i '1i #include <string.h>' android/opensl_io.c
    '';
  });
in

{
  environment.sessionVariables.LD_LIBRARY_PATH = [ "${jackWithOpenSLES}/lib" ];
}

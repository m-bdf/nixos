{ inputs, config, lib, pkgs, ... }:

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

  jack = pkgs.libjack2.override {
    stdenv = pkgs.overrideCC pkgsCross.stdenv cc;
    inherit (pkgsCross.buildPackages) python3Packages;
    dbus = null;
  };

  jackOpenSL = jack.overrideAttrs (prev: {
    pname = prev.pname + "-opensl";

    patches = prev.patches ++ [
      (inputs.termux-packages + /packages/jack2/0001-fix-android-build.patch)
      (inputs.termux-packages + /packages/jack2/0003-opensles-driver.patch)
      (inputs.termux-packages + /packages/jack2/0004-remove-su-features.patch)
    ];

    postPatch = ''
      sed -i '1i #include <string.h>' android/opensl_io.c
    '';

    NIX_LDFLAGS = [ "-ldl" ];

    preFixup = ''
      patchelf $out/lib/libjack.so --set-rpath ${
        lib.makeLibraryPath [ pkgs.libsamplerate cc.cc.out ]
      }
    '';
  });
in

{
  environment.sessionVariables.LD_LIBRARY_PATH = [ "${jackOpenSL}/lib" ];
}

{ inputs, pkgs, ... }:

let
  pkgsAndroid = inputs.nixpkgs.legacyPackages.aarch64-linux;
  pkgsCross = pkgs.pkgsCross.aarch64-android.buildPackages;

  cc = pkgsCross.androidndkPkgs.clang.override (prev: rec {
    bintools = prev.bintools.override { inherit libc; };

    libc = prev.libc.overrideAttrs (prev: {
      buildCommand = prev.buildCommand + ''
        ln -s ${pkgsAndroid.glibc}/lib/lib{pthread,rt}.so $out/lib
      '';
    });
  });

  jack = pkgs.jack2.override {
    stdenv = pkgs.clangStdenv.override { inherit cc; };
    inherit (pkgsAndroid) libsamplerate dbus libffado alsa-lib;
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

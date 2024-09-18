{ inputs, lib, ... }:

{
  nixpkgs.overlays = import ./reset-attrs.nix lib ++ lib.singleton (final: prev:
    # lib.optionalAttrs (prev.config ? replaceStdenv) (import ./reset-zig.nix lib final prev) //
  {
    zigPackages = final.recurseIntoAttrs (final.callPackage (inputs.zig + /pkgs/development/compilers/zig) {});
    zig = final.zigPackages."0.13";
    zigStdenv = if final.stdenv.cc.isZig then final.stdenv else final.lowPrio final.zig.passthru.stdenv;

    aroccPackages = final.recurseIntoAttrs (final.callPackage (inputs.zig + /pkgs/development/compilers/arocc) {});
    arocc = final.aroccPackages.latest;
    aroccStdenv = if final.stdenv.cc.isArocc then final.stdenv else final.lowPrio final.arocc.cc.passthru.stdenv;

    meson = final.callPackage (inputs.zig + /pkgs/by-name/me/meson/package.nix) {};

    libtsm = final.callPackage (inputs.kmscon + /pkgs/by-name/li/libtsm/package.nix) {};
    kmscon = final.callPackage (inputs.kmscon + /pkgs/by-name/km/kmscon/package.nix) {};
  });
}

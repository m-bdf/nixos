{ inputs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      substituteAll = args: (prev.substituteAll args).overrideAttrs { __structuredAttrs = false; };
      buildRubyGem = args: (prev.buildRubyGem args).overrideAttrs { __structuredAttrs = false; };

      zigPackages = final.recurseIntoAttrs (final.callPackage (inputs.zig + /pkgs/development/compilers/zig) {});
      zig = final.zigPackages."0.13";
      zigStdenv = if final.stdenv.cc.isZig then final.stdenv else final.lowPrio final.zig.passthru.stdenv;

      aroccPackages = final.recurseIntoAttrs (final.callPackage (inputs.zig + /pkgs/development/compilers/arocc) {});
      arocc = final.aroccPackages.latest;
      aroccStdenv = if final.stdenv.cc.isArocc then final.stdenv else final.lowPrio final.arocc.cc.passthru.stdenv;

      libtsm = final.callPackage (inputs.kmscon + /pkgs/by-name/li/libtsm/package.nix) {};
      kmscon = final.callPackage (inputs.kmscon + /pkgs/by-name/km/kmscon/package.nix) {};
    })
  ];
}

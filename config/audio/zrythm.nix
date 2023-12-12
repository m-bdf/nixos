{ lib, pkgs, ... }:

let
  gtk4136 = pkgs.gtk4.overrideAttrs (oldAttrs: rec {
    version = "4.13.6";

    src = pkgs.fetchurl {
      url = "mirror://gnome/sources/gtk/${lib.versions.majorMinor version}/gtk-${version}.tar.xz";
      sha256 = "mtw4bKogVyT8Xkhmd1eXkC/26tfSs3INYT3YDC9qrnc=";
    };

    patches = [];
    postPatch = builtins.replaceStrings [ "gen-demo-header.py" ] [ "gen-profile-conf.py" ] oldAttrs.postPatch;

    buildInputs = oldAttrs.buildInputs ++ [ pkgs.vulkan-loader pkgs.shaderc pkgs.libdrm ];
  });

  gtk4 = pkgs.gtk4.overrideAttrs (oldAttrs: rec {
    version = "4.13.4";

    src = pkgs.fetchurl {
      url = "mirror://gnome/sources/gtk/${lib.versions.majorMinor version}/gtk-${version}.tar.xz";
      sha256 = "sxx1EQI6LOClFEs7a3IiH+tWPiO+Fk7N3Uh8qFm5xA8=";
    };

    patches = [];

    buildInputs = oldAttrs.buildInputs ++ [ pkgs.libdrm ];
  });

  rtaudio = pkgs.rtaudio.overrideAttrs (oldAttrs: rec{
    version = "6.0.1";

    src = pkgs.fetchFromGitHub {
      owner = "thestk";
      repo = "rtaudio";
      rev = version;
      sha256 = "sha256-Acsxbnl+V+Y4mKC1gD11n0m03E96HMK+oEY/YV7rlIY=";
    };
  });
in

(pkgs.zrythm.override { inherit gtk4 rtaudio; }).overrideAttrs (oldAttrs: rec {
  version = "1.0.0-beta.6.3.1";

  src = pkgs.fetchFromGitLab {
    domain = "gitlab.zrythm.org";
    owner = "zrythm";
    repo = "zrythm";
    rev = "v${version}";
    hash = "sha256-nsDuxVYOG8REZRuuWY2T+1eVonkb/qicYHoG4gQZoiM=";
  };

  buildInputs = oldAttrs.buildInputs ++ [ pkgs.soxr pkgs.yyjson ];
})

{ glibc }:

glibc.overrideAttrs (prev: {
  pname = prev.pname + "-isatty-pager";

  outputs = [ "out" ];
  separateDebugInfo = false;

  makeFlags = [
    "module-cppflags="
    "link-libc-deps="
    "link-libc-args=$(LDFLAGS-rpath-ORIGIN)"
  ];

  buildFlags = [ "csu/others" ];

  preInstall = ''
    ln -s ${./isatty.c} isatty_pager.c
    patchelf ${glibc}/lib/libc.so.* \
      --set-soname ''' --output libc.so
  '';

  installFlags = [
    "extra-libs=libc_isatty_pager"
    "libc_isatty_pager-routines+=isatty"
    "libc_isatty_pager-routines+=isatty_pager"
    "libc_isatty_pager-map=$(common-objpfx)libc.map"
  ];

  installTargets = "install-lib-nosubdir";

  postInstall = ''
    ln -s ${glibc}/lib/libc.so.* $out/lib/libc.so
    ln -s ${glibc}/lib/libc.so.* $out/lib
    ln -sf libc_isatty_pager.so $out/lib/libc.so.*
  '';
})

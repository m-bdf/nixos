{ inputs, rustPlatform, grub2, xorriso }:

rustPlatform.buildRustPackage (final: {
  pname = "aster-kernel";
  version = "git";

  src = inputs.asterinas;
  cargoLock = {
    lockFile = final.src + /Cargo.lock;
    allowBuiltinFetchGit = true;
  };

  patchPhase = ''
    v=' *= *"[^"]+"'
    sed -Ei $(find .. -name Cargo.toml) \
      -e "s/git$v, rev$v, (version$v)/\1/" \
      -e "s/git$v(, ...$v)?/version = \"*\"/" \
  '';

  configurePhase = ''
    echo > OSDK.toml
  '';

  VDSO_LIBRARY_DIR = inputs.linux-vdso;
  nativeBuildInputs = [ grub2 xorriso ];

  buildPhase = ''
    cargo osdk build --release \
      --boot-method=grub-rescue-iso \
      --grub-boot-protocol=linux
  '';

  auditable = false;
  doCheck = false;

  installPhase = ''
    cp -R target/osdk/iso_root/boot $out
  '';
})

{ inputs, config, lib, pkgs, ... }:

let
  airgorah = pkgs.airgorah.overrideAttrs {
    src = inputs.airgorah;

    cargoDeps = pkgs.rustPlatform.importCargoLock {
      lockFile = inputs.airgorah + /Cargo.lock;
    };

    postPatch = ''
      cargo add nix --features user
      sed -i src/backend/app.rs -e '/sudo/c \
        if nix::unistd::setuid(nix::unistd::ROOT).is_err() {'
    '';

    postInstall = ''
      install -Dm644 icons/app_icon.png $out/share/pixmaps/airgorah.png
    '';

    preFixup = ''
      substituteInPlace $out/share/applications/airgorah.desktop \
        --replace-fail "pkexec " ""

      gappsWrapperArgs+=(
        --prefix XDG_DATA_DIRS : ${pkgs.adwaita-icon-theme}/share
        --prefix PATH : ${with pkgs; lib.makeBinPath [
          libuuid iproute2 iw gawk xterm aircrack-ng tshark macchanger
        ]}
      )
    '';
  };
in

{
  environment.systemPackages = [ airgorah ];
  security.wrappers.airgorah = {
    source = lib.getExe airgorah;
    owner = config.users.users.user.name;
    group = config.users.users.user.group;
    capabilities = "cap_setuid=p";
  };
}

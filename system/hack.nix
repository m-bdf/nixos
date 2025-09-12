{ config, lib, pkgs, ... }:

let
  airgorah = pkgs.airgorah.overrideAttrs {
    postPatch = ''
      cargo add nix --features user
      sed -i src/backend/app.rs -e '/sudo/c \
        if nix::unistd::setuid(nix::unistd::ROOT).is_err() {'
    '';

    postInstall = ''
      mkdir -p $out/share/{pixmaps,applications}
      cp icons/app_icon.png $out/share/pixmaps/airgorah.png
      substitute package/.desktop $out/share/applications/airgorah.desktop \
        --replace-fail "pkexec " "" --replace-fail /usr $out
    '';

    preFixup = ''
      gappsWrapperArgs+=(
        --prefix XDG_DATA_DIRS : ${pkgs.adwaita-icon-theme}/share
        --prefix PATH : ${with pkgs; lib.makeBinPath
          [ iw xterm aircrack-ng wireshark-cli macchanger ]}
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
    capabilities = "cap_setuid,cap_dac_override=p";
  };
}

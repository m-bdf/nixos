{ config, lib, pkgs, ... }:

let
  airgorah-xorg = pkgs.airgorah.overrideAttrs {
    postInstall = ''
      mkdir -p $out/share/{pixmaps,applications,polkit-1/actions}
      cp icons/app_icon.png $out/share/pixmaps/airgorah.png

      substitute package/.desktop $out/share/applications/airgorah.desktop \
        --replace-fail pkexec\ {airgorah,$out/bin/airgorah} \
        --replace-fail /usr $out

      filename="org.freedesktop.policykit.airgorah.policy"
      substitute package/.policy $out/share/polkit-1/actions/$filename \
        --replace-fail /usr $out
    '';

    preFixup = ''
      gappsWrapperArgs+=(
        --prefix XDG_DATA_DIRS : ${pkgs.adwaita-icon-theme}/share
        --prefix PATH : ${with pkgs; lib.makeBinPath
          [ iw xterm aircrack-ng wireshark-cli macchanger ]}
      )
    '';
  };

  airgorah-wayland =
    pkgs.writeShellScriptBin "airgorah-wayland" ''
      pkexec env \
        WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
        XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
        XDG_DATA_DIRS=$XDG_DATA_DIRS \
        ${lib.getExe airgorah-xorg}
    '';

  airgorah = pkgs.airgorah.overrideAttrs {
    postPatch = ''
      cargo add nix --features user
      sed -i '/AppError::NotRoot/ { a }
        i if nix::unistd::setuid(nix::unistd::ROOT).is_err() {
      }' src/backend/app.rs
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

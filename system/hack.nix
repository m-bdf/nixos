{ lib, pkgs, ... }:

let
  airgorah = pkgs.airgorah.overrideAttrs {
    postInstall = ''
      mkdir -p $out/share/{polkit-1/actions,pixmaps,applications}
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
        --prefix PATH : ${with pkgs; lib.makeBinPath
          [ iw xterm aircrack-ng wireshark-cli macchanger ]}
        --prefix XDG_DATA_DIRS : ${pkgs.adwaita-icon-theme}/share
      )
    '';
  };

  airgorah-wayland =
    pkgs.writeShellScriptBin "airgorah" ''
      pkexec env \
        WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
        XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
        XDG_DATA_DIRS=$XDG_DATA_DIRS \
        ${lib.getExe airgorah}
    '';
in

{
  environment.systemPackages = [ airgorah-wayland ];
}

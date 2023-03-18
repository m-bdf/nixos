{ pkgs, musnix, tidal, ... }:

{
  imports = [ musnix.nixosModules.musnix ];
  nixpkgs.overlays = [ tidal.overlays.default ];

  environment.systemPackages = with pkgs; [
    alsa-utils pavucontrol qjackctl
    superdirt-start pkgs.tidal
    qt5.qtwayland sonic-pi
  ];

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  musnix.enable = true;
  security.rtkit.enable = true;
  users.users.user.extraGroups = [ "audio" ];
}

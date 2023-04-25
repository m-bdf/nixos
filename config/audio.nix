{ pkgs, musnix, tidal, ... }:

{
  imports = [ musnix.nixosModules.musnix ];
  nixpkgs.overlays = [ tidal.overlays.default ];

  environment.systemPackages = with pkgs; [
    pkgs.tidal superdirt-start
    alsa-utils pavucontrol qjackctl
  ];

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  musnix.enable = true;
  security.rtkit.enable = true;
  users.users.user.extraGroups = [ "audio" ];

  xdg.dirs.data.SuperCollider.create = true;
}

{
    networking.hostName = "mae";

    nix = {
        cores = 0;
        trustedUsers = [ "root" "@wheel" ];
    };

    users.users.mae = {
        isNormalUser = true;
        extraGroups = [ "wheel" ]; 
    };

    services.cachix-agent.enable = true;
}

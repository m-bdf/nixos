{
    networking.hostName = "mae";

    nix.settings = {
        cores = 0;
        trusted-users = [ "root" "@wheel" ];
    };

    users.users.mae = {
        isNormalUser = true;
        extraGroups = [ "wheel" ]; 
    };

    services.cachix-agent.enable = true;
}

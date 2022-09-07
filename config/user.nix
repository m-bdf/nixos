{ lib, config, secrets, ... }:

{
    users = {
        mutableUsers = false;

        users.${config.system.name} = {
            isNormalUser = true;
            group = "wheel";
            password = secrets.password or "";
            home = "/home";
        };
    };
}

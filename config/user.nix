{ lib, secrets, ... }:

{
    users = {
        mutableUsers = false;

        users.mae = {
            isNormalUser = true;
            group = "wheel";
            password = secrets.password or "";
            home = "/home";
        };
    };
}

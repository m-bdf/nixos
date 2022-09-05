{ lib, const, ... }:

{
    users = {
        mutableUsers = false;

        users.${const.hostname} = {
            isNormalUser = true;
            group = "wheel";
            password = const.password or "";
            home = "/home";
        };
    };
}

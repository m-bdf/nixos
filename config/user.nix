{ lib, hostname, password ? "" }:

{
    users = {
        mutableUsers = false;

        ${hostname} = {
            isNormalUser = true;
            inherit password;
            home = "/home";
        };
    };
}

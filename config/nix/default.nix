{ pkgs, ... }:

{
    nix.settings = {
        allowed-impure-host-deps = [ "/sys" "/nix/var" ];
        narinfo-cache-negative-ttl = 0;
        auto-optimise-store = true;
        #repeat = 2;
        cores = 0;
        max-jobs = "auto";

        experimental-features = builtins.readFile
            (pkgs.runCommandCC "fetch-xp-features" {
                buildInputs = with pkgs; [ nix boost ];
            } ''
                $CXX ${./fetch-xp-features.cxx} -l nixutil
                echo fetching experimental features... >&2 && ./a.out > $out
            '');
    };
}

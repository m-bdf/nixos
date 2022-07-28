#include <nix/experimental-features.hh>
#include <iostream>

namespace nix {
    extern std::map<ExperimentalFeature, std::string> stringifiedXpFeatures;
}

int main() {
    for (const auto & [feature, name] : nix::stringifiedXpFeatures)
        if (name != "ca-derivations") std::cout << name << ' ';
}

{ inputs, config, pkgs, ... }:

let
  devirtualizeFile = ''
    URIForFile::URIForFile(std::string &&F) : File(std::move(F)) {
      try {
        static auto &State = AttrSetProvider().state();
        auto StorePath = State.store->toStorePath(File).first;
        auto Context = nix::NixStringContextElem::Opaque{StorePath};
        File = State.devirtualize(File, {Context});
      } catch (const nix::Error &) {}
    }
  '';

  nixd = (pkgs.callPackage inputs.nixd {
    nixComponents = inputs.nix.packages.${pkgs.stdenv.system};
  }).overrideAttrs (prev: {
    prePatch = ''
      sed -i 's/type(true)/type() - 1/' \
        nixd/lib/Eval/AttrSetProvider.cpp

      echo '${devirtualizeFile}' >> \
        nixd/lib/Eval/AttrSetProvider.cpp

      sed -i '/explicit URIForFile/ s/ :.*/;/' \
        nixd/lspserver/include/lspserver/Protocol.h

      mesonFlags='--default-library=static'
    '';

    postPatch = ''
      sed -i '1i #include <nixt/InitEval.h>
        /main/a nixt::initEval();' nixd/tools/nixd.cpp

      sed -Ei 's/ \w+ =$/ \&&/; /> .*getField\(/,/^\S/{
        s/std::nullopt/nullptr/; s/\*//; s/.+<(.+)> /\1 */
      }' libnixt/{include/nixt/Value.h,lib/Value.cpp}

      sed -i '1i #include <nixt/Value.h>
        /std::string expr/a nix::Value *value;
      ' nixd/include/nixd/Controller/Configuration.h

      sed -Ei 's/.+\*(.+), (.+).expr/(\1->Nixpkgs = *\2.value/
        /::fetchConfig/,$d' nixd/lib/Controller/Configuration.cpp

      sed -Ei 's/ (In|Out)/& = nullptr/; / State/i public: \
        static inline' nixd/include/nixd/Eval/AttrSetProvider.h

      sed -i '/::AttrSetProvider/,/ {/{
        s/ {/;/; s/),$/) {/; s/ State/if (!&) &.reset/
      }' nixd/lib/Eval/AttrSetProvider.cpp

      ln -sf ${./client.h} nixd/include/nixd/Eval/AttrSetClient.h
      > nixd/lib/Eval/AttrSetClient.cpp
    '';

    NIX_PATH = config.nix.nixPath ++ [ "config=${./config.nix}" ];

    checkPhase = null;

    nativeBuildInputs =
      prev.nativeBuildInputs ++ [ pkgs.makeBinaryWrapper ];

    postFixup = ''
      wrapProgram $out/bin/nixd --set NIX_PATH "$NIX_PATH"
    '';
  });
in

{
  home.packages = [ nixd ];
}

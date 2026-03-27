#ifndef ATTR_SET_CLIENT_H
#define ATTR_SET_CLIENT_H

#include "nixd/Eval/AttrSetProvider.h"

namespace nixd {

struct AttrSetClient : AttrSetProvider {
  static const char *getExe();

  #define evalExpr onEvalExpr
  #define attrpathInfo onAttrPathInfo
  #define attrpathComplete onAttrPathComplete
  #define optionInfo onOptionInfo
  #define optionComplete onOptionComplete
};

struct AttrSetClientProc : AttrSetClient {
  AttrSetClientProc(auto &&...) {}
  AttrSetClient *client() { return this; }
};

} // namespace nixd

#else // ATTR_SET_CLIENT_H

#include <boost/asio/post.hpp>

inline void nixd::Controller::fetchConfig() {
  boost::asio::post(Pool, [this]() {
    static AttrSetClient Client;
    static auto &State = Client.state();
    static auto &Value = Client.Nixpkgs;

    evalExprWithProgress(Client, R"(
      let config = import <config> ./.;
      in builtins.trace (builtins.toJSON config) config
    )", "generated config");

    auto nixpkgs = nixt::getField(State, Value, "nixpkgs");
    auto options = nixt::getField(State, Value, "options");

    Configuration NewConfig{
      .nixpkgs = {"nixpkgs entries", nixpkgs},
    };

    for (const auto &attr : *options->attrs()) {
      std::string key(State.symbols[attr.name]);
      NewConfig.options[key] = {key, attr.value};
    }

    updateConfig(std::move(NewConfig));
  });
}

#endif // ATTR_SET_CLIENT_H

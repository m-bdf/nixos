{ inputs, lib, ... }:

let
  settings = {
    "zen.welcome-screen.seen" = true;
    "startup.homepage_welcome_url" = "";
    "startup.homepage_welcome_url.additional" = "";
    "startup.homepage_override_url" = "";

    "privacy.userContext.enabled" = false;
    "zen.workspaces.separate-essentials" = false;
    "zen.workspaces.continue-where-left-off" = true;
    "zen.window-sync.enabled" = false;

    "zen.view.use-single-toolbar" = false;
    "zen.tabs.show-newtab-vertical" = false;
    "zen.view.show-newtab-button-top" = false;
    "zen.urlbar.behavior" = "normal";

    "browser.search.separatePrivateDefault" = false;
    "browser.search.suggest.enabled" = true;
    "browser.search.suggest.enabled.private" = true;
    "browser.urlbar.showSearchSuggestionsFirst" = false;

    "signon.rememberSignons" = false;
    "extensions.formautofill.addresses.enabled" = false;
    "extensions.formautofill.creditCards.enabled" = false;

    "findbar.highlightAll" = true;
  };
in

{
  home = {
    imports = [
      (lib.setDefaultModuleLocation
        (inputs.zen-browser + /hm-module.nix)
        inputs.zen-browser.homeModules.twilight
      )
    ];

    programs.zen-browser = {
      enable = true;
      setAsDefaultBrowser = true;

      profiles.default = {
        settings = settings // {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
        userChrome = ''
          .zen-current-workspace-indicator,
          [data-l10n-id*=workspace] {
            display: none !important;
          }
        '';
      };
    };

    xdg.configFile = {
      "zen".persist = true;
      "zen/default/prefs.js".text = "";
      # "zen/default/storage-sync-v2.sqlite".text = "";
    };
  };
}

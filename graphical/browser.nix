{ inputs, ... }:

let
  settings = {
    "zen.welcome-screen.seen" = true;
    "startup.homepage_welcome_url" = "";
    "startup.homepage_welcome_url.additional" = "";
    "startup.homepage_override_url" = "";

    "privacy.userContext.enabled" = false;
    "zen.workspaces.separate-essentials" = false;
    "zen.workspaces.continue-where-left-off" = true;

    "zen.view.use-single-toolbar" = false;
    "zen.tabs.show-newtab-vertical" = false;
    "zen.view.show-newtab-button-top" = false;
    "zen.urlbar.behavior" = "normal";

    "browser.search.separatePrivateDefault" = false;
    "browser.search.suggest.enabled" = true;
    "browser.search.suggest.enabled.private" = true;
    "browser.urlbar.showSearchSuggestionsFirst" = false;
  };
in

{
  imports = [ inputs.zen-browser.homeModules.twilight ];

  programs.zen-browser = {
    enable = true;
    profiles.profile = {
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

  home.file = {
    ".zen".persist = true;
    ".zen/profile/prefs.js".text = "";
    ".zen/profile/storage-sync-v2.sqlite".text = "";
  };
}

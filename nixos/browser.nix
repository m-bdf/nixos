{ inputs, config, lib, ... }:

let
  cfg = config.home.programs.zen-browser;

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
  home = {
    imports = [
      (lib.setDefaultModuleLocation
        (inputs.zen-browser + /hm-module.nix)
        inputs.zen-browser.homeModules.twilight
      )
    ];

    programs.zen-browser = {
      enable = true;
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

    home.file = {
      "${cfg.configPath}".persist = true;
      "${cfg.profilesPath}/default/prefs.js".text = "";
      # "${cfg.profilesPath}/default/storage-sync-v2.sqlite".text = "";
    };
  };
}

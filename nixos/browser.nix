{ inputs, config, pkgs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      inherit (inputs.zen-browser.packages.${final.stdenv.system}) zen-browser;
    })
  ];

  home = {
    imports = [ inputs.zen-browser-hm.homeModules.default ];

    programs.zen-browser = {
      enable = true;
      setAsDefaultBrowser = true;

      package = pkgs.wrapFirefox pkgs.zen-browser.unwrapped {
        inherit (config.home.programs.zen-browser) extraPrefs extraPrefsFiles;
        extraAutoConfig = "pref('general.config.sandbox_enabled', false);";
      };

      extraPrefs = ''
        Services.obs.addObserver(win => {
          win.document.addEventListener(
            'MozBeforeInitialXULLayout',
            () => {
              win.console.log('Disabling Zen workspaces.');
              win.gZenWorkspaces._shouldHaveWorkspaces = false;
            },
            { capture: true, once: true }
          );
        }, 'chrome-document-global-created');
      '';

      profiles.default.settings = {
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
    };

    xdg.configFile = {
      "zen".persist = true;
      "zen/default/prefs.js" = {
        text = "";
        force = true;
      };
    };
  };
}

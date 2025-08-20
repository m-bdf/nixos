{ inputs, lib, pkgs, ... }:

let
  settings = {
    bitwarden = {
      global_extensionInitialInstall_extensionInstalled = true;
    };

    darkreader = {
      schemeVersion = 2;
      previewNewDesign = true;
      previewNewestDesign = true;

      syncSitesFixes = true;
      enableForProtectedPages = true;
      disabledFor = [ "localhost" ];

      changeBrowserTheme = true;
      automation = {
        enabled = true;
        mode = "system";
      };
    };

    ublock-origin = {};
  };

  addons = inputs.firefox-addons.packages.${pkgs.stdenv.system};
  mapAddons = f: lib.concatMapAttrs
    (name: settings: with addons.${name}; {
      ${addonId} = f (src // { inherit settings; });
    }) settings;
in

{
  programs.zen-browser = {
    policies.ExtensionSettings =
      mapAddons (addon: {
        install_url = "file:" + addon;
        installation_mode = "force_installed";
        default_area = "navbar";
        private_browsing = true;
      });

    profiles.profile = {
      settings = {
        "extensions.webextensions.uuids" = mapAddons (addon: addon.outputHash);
        "extensions.webextensions.restrictedDomains" = "";
      };
      extensions = {
        settings = mapAddons (addon: { inherit (addon) settings; });
        force = true;
      };
    };
  };
}

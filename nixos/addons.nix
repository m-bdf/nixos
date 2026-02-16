{ inputs, lib, pkgs, ... }:

let
  settings = {
    darkreader = {
      syncSettings = false;
      previewNewDesign = true;
      previewNewestDesign = true;
      fetchNews = false;
      disabledFor = [ "localhost" ];
      syncSitesFixes = true;
    };

    ublock-origin = {};
    bitwarden = {};
  };

  addons = inputs.firefox-addons.packages.${pkgs.stdenv.system};
  mapAddons = f: lib.concatMapAttrs
    (name: settings: with addons.${name}; {
      ${addonId} = f (src // { inherit settings; });
    }) settings;
in

{
  home.programs.zen-browser = {
    policies.ExtensionSettings =
      mapAddons (addon: {
        install_url = "file:${addon}";
        installation_mode = "force_installed";
        default_area = "navbar";
        private_browsing = true;
      });

    profiles.default = {
      settings = {
        "extensions.webextensions.uuids" = mapAddons (addon: addon.outputHash);
        # "extensions.webextensions.restrictedDomains" = "";
      };
      extensions = {
        settings = mapAddons (addon: { inherit (addon) settings; });
        force = true;
      };
    };
  };
}

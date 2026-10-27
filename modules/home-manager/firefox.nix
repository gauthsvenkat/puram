{ flakeCfg, ... }:
let
  inherit (flakeCfg) domain;
in
{
  programs.firefox = {
    enable = true;

    profiles.default = {
      isDefault = true;
      settings = {
        "browser.download.useDownloadDir" = false;
        "browser.newtabpage.enabled" = false;
        "browser.startup.homepage" = "google.com";
        "browser.toolbars.bookmarks.visibility" = "always";
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
        "general.autoScroll" = true;
        "media.eme.enabled" = true;
        "privacy.clearOnShutdown_v2.formdata" = false;
        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = true;
        "sidebar.visibility" = "expand-on-hover";
        "ui.key.menuAccessKeyFocuses" = false;
      };
    };

    policies = {
      ExtensionSettings =
        let
          amo = slug: {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
            installation_mode = "force_installed";
          };
        in
        {
          "{036a55b4-5e72-4d05-a06c-cba2dfcc134a}" = amo "traduzir-paginas-web";
          "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = amo "return-youtube-dislikes";
          "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = amo "vimium-ff";
          "addon@darkreader.org" = amo "darkreader";
          "harper@writewithharper.com" = amo "private-grammar-checker-harper";
          "idcac-pub@guus.ninja" = amo "istilldontcareaboutcookies";
          "sponsorBlocker@ajay.app" = amo "sponsorblock";
          "uBlock0@raymondhill.net" = amo "ublock-origin";
        };

      Bookmarks = [
        {
          Title = "Calendar";
          URL = "https://calendar.google.com/calendar/u/0/r";
          Placement = "toolbar";
        }
        {
          Title = "Claude";
          URL = "https://claude.ai/new";
          Placement = "toolbar";
        }
        {
          Title = "Gmail";
          URL = "https://mail.google.com/mail/u/0/#inbox";
          Placement = "toolbar";
        }
        {
          Title = "Homepage";
          URL = "https://homepage.${domain}/";
          Placement = "toolbar";
        }
        {
          Title = "NixOS Packages";
          URL = "https://search.nixos.org/packages";
          Placement = "toolbar";
        }
      ];
    };
  };
}

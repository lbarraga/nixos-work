{
  perSystem =
    { pkgs, ... }:
    let
      # The only way to install an extension without a per-profile click;
      # force_installed also means it cannot be removed from about:addons.
      # Firefox fetches the xpi on first run, so a fresh profile needs network.
      firefox = pkgs.firefox.override {
        extraPolicies.ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
        };
      };

      # One Firefox per work account, so the two never share a cookie jar.
      #
      # The profile is addressed by path, not by name (`-P`): profiles.ini
      # stopped holding names in Firefox 154. --run creates it, so this works on
      # a machine that has never run Firefox.
      #
      # MOZ_APP_REMOTINGNAME becomes the wayland app id, which is what niri
      # window rules match on and what keeps the two from merging into one
      # process.
      mkProfile =
        key: label:
        pkgs.symlinkJoin {
          name = "firefox-${key}";
          paths = [ firefox ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            rm $out/bin/firefox
            makeWrapper ${firefox}/bin/firefox $out/bin/firefox-${key} \
              --set MOZ_APP_REMOTINGNAME "firefox-${key}" \
              --run 'mkdir -p "$HOME/.mozilla/firefox/${key}"' \
              --add-flags "--profile \"\$HOME/.mozilla/firefox/${key}\""

            # every copy ships firefox.desktop, so two would collide in
            # systemPackages -- and its Exec passes `--name firefox`, which would
            # override the app id set above
            rm -f $out/share/applications/firefox.desktop
            substitute ${firefox}/share/applications/firefox.desktop \
              $out/share/applications/firefox-${key}.desktop \
              --replace-fail "Name=Firefox" "Name=Firefox (${label})" \
              --replace-fail "--name firefox" "--name firefox-${key}" \
              --replace-fail "StartupWMClass=firefox" "StartupWMClass=firefox-${key}"
            sed -i "s|^Exec=firefox|Exec=$out/bin/firefox-${key}|" \
              $out/share/applications/firefox-${key}.desktop
          '';
          meta.mainProgram = "firefox-${key}";
        };
    in
    {
      packages.firefox-ugent = mkProfile "ugent" "UGent";
      packages.firefox-imec = mkProfile "imec" "imec";
    };

  flake.modules.nixos.work-apps = { pkgs, mine, ... }: {
    environment.systemPackages = [
      mine.firefox-ugent
      mine.firefox-imec
      pkgs.mattermost-desktop
    ];

    xdg.mime.defaultApplications = {
      "text/html" = "firefox-ugent.desktop";
      "x-scheme-handler/http" = "firefox-ugent.desktop";
      "x-scheme-handler/https" = "firefox-ugent.desktop";
    };
  };
}

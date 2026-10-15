{self, ...}: {
  flake.modules.nixos.desktop-apps = {pkgs, ...}: let
    mine = self.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    nixpkgs.config.allowUnfree = true;

    environment.systemPackages =
      [
        mine.firefox-ugent
        mine.firefox-imec
      ]
      ++ (with pkgs; [
        obsidian
        mattermost-desktop
        papers # gnome pdf viewer
      ]);

    # Obsidian and Mattermost are both Electron, and without this they start
    # under XWayland: blurry whenever the scale changes, and carrying the X11
    # cursor rather than the session.
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    xdg.mime.defaultApplications = {
      "text/html" = "firefox-ugent.desktop";
      "x-scheme-handler/http" = "firefox-ugent.desktop";
      "x-scheme-handler/https" = "firefox-ugent.desktop";
    };
  };
}

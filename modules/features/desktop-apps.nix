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
      ]);

    xdg.mime.defaultApplications = {
      "text/html" = "firefox-ugent.desktop";
      "x-scheme-handler/http" = "firefox-ugent.desktop";
      "x-scheme-handler/https" = "firefox-ugent.desktop";
    };
  };
}

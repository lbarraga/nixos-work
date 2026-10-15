{self, ...}: {
  flake.modules.nixos.work-apps = {pkgs, ...}: let
    mine = self.packages.${pkgs.stdenv.hostPlatform.system};
  in {
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
